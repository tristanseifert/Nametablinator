//
//  SQUMDTileRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMDTileRenderView.h"

@implementation SQUMDTileRenderView
@synthesize paletteData, tileData, mappingData, tileOffset, markPriority, height, width, paletteState, prevScaledBitmapContext, prevBitmapContext, currentlyPlacingTile;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
        paletteState = kSQUMDNormal;
        cacheValid = NO;
        zoomFactor = 1.0f;
    }
    
    return self;
}

- (void) awakeFromNib {
    drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
    paletteState = kSQUMDNormal;
    cacheValid = NO;
    zoomFactor = 1.0f;
}

- (void)drawRect:(NSRect)dirtyRect {    
	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
    [[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationNone];
    
    if(!cacheValid) {
        if(prevBitmapContext != NULL) {
            CGContextRelease(prevBitmapContext); // free old bitmap context, as well as it's buffery thing
        }
        
        unsigned int bytesPerRow = (width * 8) * 4;
        unsigned int bytesPerPixel = 4;
        
        CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width * 8, height * 8, 8, bytesPerRow, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaNoneSkipLast);
        bitmapContextData = CGBitmapContextGetData(bitmapContext);
        prevBitmapContext = bitmapContext;
        
        CGContextSetAllowsAntialiasing(bitmapContext, false);
        
        if(bitmapContextData == NULL) {
            NSLog(@"Bitmap context is NULL!");
            
            [[NSColor redColor] set];
            NSRectFill(self.frame);
            
            return;
        }
        
        const unsigned char *map;
        const unsigned char *tileDatas;
        const unsigned char *currentTileData;
        map = (const unsigned char *)[mappingData bytes];
        tileDatas = (const unsigned char *)[tileData bytes];
        
        unsigned int currentTile;
        unsigned int tileIndex;
        
        unsigned int mapOffset;
        
        unsigned int tileDataOffset = 0;
        
        NSUInteger redComponentProc;
        NSUInteger greenComponentProc;
        NSUInteger blueComponentProc;
        unsigned int redComponent;
        unsigned int greenComponent;
        unsigned int blueComponent;
        unsigned int currentPixel;
        unsigned int currentPixelBitmapOffset;
        CGPoint point;
        
        unsigned int actualTileCol;
        unsigned int actualTileRow;
        unsigned int isMirrored;
        unsigned int isFlipped;
        
        unsigned char *bitmapPointer;
        
        const unsigned char *paletteByteArr;
        paletteByteArr = (const unsigned char *)[paletteData bytes];
        
        unsigned int palOffset = 0x0;
        
        if(palOffset >= paletteData.length) {
            palOffset = 0;
            
            unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
            
            paletteByteArr = (const unsigned char *)emptyPalette;
        }
        
        for (int row = 0; row < height; row++) {
            for(int column = 0; column < width; column++) {
                mapOffset = (row * (width << 1)) + (column << 1);
                
                tileIndex = 0x00;
                currentTile = 0x00000000;
                currentTile = (map[mapOffset] << 0x08) + map[mapOffset + 1];
                
                //NSLog(@"Current tile offset for (0x%X, 0x%X) 0x%X. (Offset 0x%X)", column, row, currentTile, mapOffset);
                
                tileIndex = currentTile & 0x7FF;
                tileIndex -= tileOffset;
                
                palOffset = 0x00;
                //palOffset = ((currentTile & 0x6000) >> 0xD) << 0x05;
                
                currentTileData = tileDatas;
                currentTileData += (tileIndex << 5);
                
                if((tileIndex << 5) > tileData.length) {
                    unsigned char arses[0x20] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
                    
                    currentTileData = arses;
                    
                    //NSLog(@"Tile 0x%X is out of bounds (starting at 0x%X of 0x%lX, map offset 0x%X, tile 0x%X)", tileIndex, (tileIndex << 5), tileData.length, mapOffset, currentTile);
                    //NSLog(@"It's map value is 0x%X %X", map[mapOffset], map[mapOffset+1]);
                }
                
                //unsigned char currentTileData[0x20] = {0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99};
                
                point = CGPointMake(column << 3, row << 3);
                
                isMirrored = (currentTile & 0x800) >> 0xB;
                isFlipped = (currentTile & 0x1000) >> 0xC;
                
                if(isMirrored == 0 && isFlipped == 0) {
                    for (int tile_row = 0; tile_row < 8; tile_row++) {
                        for (int tile_column = 0; tile_column < 8; tile_column++) {
                            tileDataOffset = (((tile_row) << 0x02) + (tile_column >> 0x01));
                            
                            if(tile_column % 2 == 0) {
                                currentPixel = (currentTileData[tileDataOffset] & 0xF0) >> 4;
                            } else {
                                currentPixel = currentTileData[tileDataOffset] & 0x0F;
                            }
                            currentPixel = currentPixel << 0x1;
                            
                            if(currentPixel != 0x00) {                            
                                redComponent = paletteByteArr[1 + palOffset + currentPixel] & 0x0F;
                                greenComponent = (paletteByteArr[1 + palOffset + currentPixel] & 0xF0) >> 4;
                                blueComponent = paletteByteArr[0 + palOffset + currentPixel] & 0x0F;
                                
                                if(self.paletteState == kSQUMDShadow) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                } else if(self.paletteState == kSQUMDHighlight) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                    
                                    redComponent += 0x7;
                                    greenComponent += 0x7;
                                    blueComponent += 0x7;
                                }
                                
                                redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
                                greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
                                blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
                                
                                currentPixelBitmapOffset = ((point.y + tile_row) * bytesPerRow) + ((point.x + tile_column) * bytesPerPixel);
                                bitmapPointer = bitmapContextData + currentPixelBitmapOffset;
                                
                                bitmapPointer[0] = redComponentProc;
                                bitmapPointer[1] = greenComponentProc;
                                bitmapPointer[2] = blueComponentProc;
                            }
                        }
                    }
                } else if(isMirrored == 1 && isFlipped == 0) {
                    for (int tile_row = 0; tile_row < 8; tile_row++) {
                        for (int tile_column = 7; tile_column >= 0; tile_column--) {
                            tileDataOffset = (((tile_row) << 0x02) + (tile_column >> 0x01));
                            
                            if(tile_column % 2 == 0) {
                                currentPixel = (currentTileData[tileDataOffset] & 0xF0) >> 4;
                            } else {
                                currentPixel = currentTileData[tileDataOffset] & 0x0F;
                            }
                            currentPixel = currentPixel << 0x1;
                            
                            if(currentPixel != 0x00) {                            
                                redComponent = paletteByteArr[1 + palOffset + currentPixel] & 0x0F;
                                greenComponent = (paletteByteArr[1 + palOffset + currentPixel] & 0xF0) >> 4;
                                blueComponent = paletteByteArr[0 + palOffset + currentPixel] & 0x0F;
                                
                                if(self.paletteState == kSQUMDShadow) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                } else if(self.paletteState == kSQUMDHighlight) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                    
                                    redComponent += 0x7;
                                    greenComponent += 0x7;
                                    blueComponent += 0x7;
                                }
                                
                                redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
                                greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
                                blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
                                
                                currentPixelBitmapOffset = ((point.y + actualTileRow) * bytesPerRow) + ((point.x + actualTileCol) * bytesPerPixel);
                                bitmapPointer = bitmapContextData + currentPixelBitmapOffset;
                                
                                bitmapPointer[0] = redComponentProc;
                                bitmapPointer[1] = greenComponentProc;
                                bitmapPointer[2] = blueComponentProc;
                            }
                            
                            actualTileCol++;
                        }
                        
                        actualTileCol = 0;
                        actualTileRow++;
                    }
                } else if(isMirrored == 0 && isFlipped == 1) {
                    for (int tile_row = 7; tile_row >= 0; tile_row--) {
                        for (int tile_column = 0; tile_column < 8; tile_column++) {
                            tileDataOffset = (((tile_row) << 0x02) + (tile_column >> 0x01));
                            
                            if(tile_column % 2 == 0) {
                                currentPixel = (currentTileData[tileDataOffset] & 0xF0) >> 4;
                            } else {
                                currentPixel = currentTileData[tileDataOffset] & 0x0F;
                            }
                            currentPixel = currentPixel << 0x1;
                            
                            if(currentPixel != 0x00) {                            
                                redComponent = paletteByteArr[1 + palOffset + currentPixel] & 0x0F;
                                greenComponent = (paletteByteArr[1 + palOffset + currentPixel] & 0xF0) >> 4;
                                blueComponent = paletteByteArr[0 + palOffset + currentPixel] & 0x0F;
                                
                                if(self.paletteState == kSQUMDShadow) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                } else if(self.paletteState == kSQUMDHighlight) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                    
                                    redComponent += 0x7;
                                    greenComponent += 0x7;
                                    blueComponent += 0x7;
                                }
                                
                                redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
                                greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
                                blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
                                
                                currentPixelBitmapOffset = ((point.y + actualTileRow) * bytesPerRow) + ((point.x + actualTileCol) * bytesPerPixel);
                                bitmapPointer = bitmapContextData + currentPixelBitmapOffset;
                                
                                bitmapPointer[0] = redComponentProc;
                                bitmapPointer[1] = greenComponentProc;
                                bitmapPointer[2] = blueComponentProc;
                            }
                            
                            actualTileCol++;
                        }
                        
                        actualTileCol = 0;
                        actualTileRow++;
                    }
                } else if(isMirrored == 1 && isFlipped == 1) {
                    for (int tile_row = 7; tile_row >= 0; tile_row--) {
                        for (int tile_column = 7; tile_column >= 0; tile_column--) {
                            tileDataOffset = (((tile_row) << 0x02) + (tile_column >> 0x01));
                            
                            if(tile_column % 2 == 0) {
                                currentPixel = (currentTileData[tileDataOffset] & 0xF0) >> 4;
                            } else {
                                currentPixel = currentTileData[tileDataOffset] & 0x0F;
                            }
                            currentPixel = currentPixel << 0x1;
                            
                            if(currentPixel != 0x00) {                            
                                redComponent = paletteByteArr[1 + palOffset + currentPixel] & 0x0F;
                                greenComponent = (paletteByteArr[1 + palOffset + currentPixel] & 0xF0) >> 4;
                                blueComponent = paletteByteArr[0 + palOffset + currentPixel] & 0x0F;
                                
                                if(self.paletteState == kSQUMDShadow) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                } else if(self.paletteState == kSQUMDHighlight) {
                                    redComponent = redComponent >> 1;
                                    greenComponent = greenComponent >> 1;
                                    blueComponent = blueComponent >> 1;
                                    
                                    redComponent += 0x7;
                                    greenComponent += 0x7;
                                    blueComponent += 0x7;
                                }
                                
                                redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
                                greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
                                blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
                                
                                currentPixelBitmapOffset = ((point.y + actualTileRow) * bytesPerRow) + ((point.x + actualTileCol) * bytesPerPixel);
                                bitmapPointer = bitmapContextData + currentPixelBitmapOffset;
                                
                                bitmapPointer[0] = redComponentProc;
                                bitmapPointer[1] = greenComponentProc;
                                bitmapPointer[2] = blueComponentProc;
                            }
                            
                            actualTileCol++;
                        }
                        
                        actualTileCol = 0;
                        actualTileRow++;
                    }
                }
                
                actualTileRow = 0;                
            }
        }
        
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        
        if(zoomFactor == 1.0f) {
            NSRect imageRect = NSMakeRect(0, 0, width * 8, height * 8);
        
            NSImage *nsimage = [[NSImage alloc] initWithCGImage:image size:self.frame.size];
            [nsimage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        } else {
            if(prevScaledBitmapContext) {
                CGContextRelease(prevScaledBitmapContext);
            }
            
            prevScaledBitmapContext = CGBitmapContextCreate(NULL,
                                                            (width * 8) * zoomFactor, // Changed this
                                                            (height * 8) * zoomFactor, // Changed this
                                                            8,
                                                            4 * ((width * 8) * zoomFactor), // Changed this
                                                            CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),
                                                            CGImageGetAlphaInfo(image));
            
            
            CGContextSetShouldAntialias(prevScaledBitmapContext, false);
            CGContextSetAllowsAntialiasing(prevScaledBitmapContext, false);
            CGContextSetAllowsFontSubpixelPositioning(prevScaledBitmapContext, false);
            CGContextSetInterpolationQuality(prevScaledBitmapContext, kCGInterpolationNone);
            
            CGContextDrawImage(prevScaledBitmapContext, CGContextGetClipBoundingBox(prevScaledBitmapContext), image);
            CGImageRef imgRef = CGBitmapContextCreateImage(prevScaledBitmapContext);
            
            NSRect imageRect = NSMakeRect(0, 0, (width * 8) * zoomFactor, (height * 8) * zoomFactor);        
            
            NSImage *nsimage = [[NSImage alloc] initWithCGImage:imgRef size:self.frame.size];
            [nsimage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];     
            
            [nsimage release];
            CGImageRelease(imgRef);
            
            scaledBitmapContextData = CGBitmapContextGetData(prevScaledBitmapContext);
            
            renderedZoomFactor = zoomFactor;
        }
        
        cacheValid = YES;
    } else {        
        CGContextRef bitmapContext = CGBitmapContextCreate(bitmapContextData, width * 8, height * 8, 8, (width * 8) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaNoneSkipLast);
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        
        if(zoomFactor == 1.0f) {
            NSRect imageRect = NSMakeRect(0, 0, width * 8, height * 8);        
            
            NSImage *nsimage = [[NSImage alloc] initWithCGImage:image size:self.frame.size];
            [nsimage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];     
            
            [nsimage release];
        } else {
            if(renderedZoomFactor != zoomFactor || !prevScaledBitmapContext) {
                if(prevScaledBitmapContext) {
                    CGContextRelease(prevScaledBitmapContext);
                }
            
                prevScaledBitmapContext = CGBitmapContextCreate(NULL,
                                                         (width * 8) * zoomFactor, // Changed this
                                                         (height * 8) * zoomFactor, // Changed this
                                                         8,
                                                         4 * ((width * 8) * zoomFactor), // Changed this
                                                         CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),
                                                         CGImageGetAlphaInfo(image));
            
                CGContextSetShouldAntialias(prevScaledBitmapContext, false);
                CGContextSetAllowsAntialiasing(prevScaledBitmapContext, false);
                CGContextSetAllowsFontSubpixelPositioning(prevScaledBitmapContext, false);
                CGContextSetInterpolationQuality(prevScaledBitmapContext, kCGInterpolationNone);
                
                CGContextDrawImage(prevScaledBitmapContext, CGContextGetClipBoundingBox(prevScaledBitmapContext), image);
                CGImageRef imgRef = CGBitmapContextCreateImage(prevScaledBitmapContext);
            
                NSRect imageRect = NSMakeRect(0, 0, (width * 8) * zoomFactor, (height * 8) * zoomFactor);        
            
                NSImage *nsimage = [[NSImage alloc] initWithCGImage:imgRef size:self.frame.size];
                [nsimage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];     
            
                [nsimage release];
                CGImageRelease(imgRef);
            
                scaledBitmapContextData = CGBitmapContextGetData(prevScaledBitmapContext);
                
                renderedZoomFactor = zoomFactor;
            } else {
                //NSLog(@"Scaled image being drawn from cache.");
                
                CGImageRef imgRef = CGBitmapContextCreateImage(prevScaledBitmapContext);
                
                NSRect imageRect = NSMakeRect(0, 0, (width * 8) * zoomFactor, (height * 8) * zoomFactor);        
                
                NSImage *nsimage = [[NSImage alloc] initWithCGImage:imgRef size:self.frame.size];
                [nsimage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];     
                
                [nsimage release];
                CGImageRelease(imgRef);             
            }
        }
        
        
        CGImageRelease(image);
    }
}

#pragma mark rendering

- (NSImage *) renderImageForTile:(NSUInteger) theTile {
    unsigned int tileIndex = theTile & 0x7FF;
    unsigned int isMirrored = (theTile & 0x800) >> 0xB;
    unsigned int isFlipped = (theTile & 0x1000) >> 0xC;
    unsigned int palOffset = (theTile & 0x6000) >> 0xD;
    unsigned int priority = (theTile & 0x8000) >> 0xF;
    
    NSLog(@"Rendering tile 0x%X (0x%X) as: Mirrored: 0x%X, Flipped: 0x%X, Palette Offset: 0x%X, Priority: 0x%X", tileIndex, theTile, isMirrored, isFlipped, palOffset, priority);
    
    return nil;
}

#pragma mark Miscellaneous convenience methods

- (void) purgeCache {
    cacheValid = NO;
    [self setNeedsDisplay:YES];
}

#pragma mark Zooming stuffs

- (void) setZoomFactor:(float) factor {
    zoomFactor = factor;
    [self setNeedsDisplay:YES];
}

@end
