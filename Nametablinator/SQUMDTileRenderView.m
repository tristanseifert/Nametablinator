//
//  SQUMDTileRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMDTileRenderView.h"

@implementation SQUMDTileRenderView
@synthesize paletteData, tileData, mappingData, tileOffset, markPriority, height, width, paletteState, prevScaledBitmapContext, prevBitmapContext, currentlyPlacingTile, editingModeDisable, delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
        paletteState = kSQUMDNormal;
        cacheValid = NO;
        zoomFactor = 1.0f;
        
        [self.window setAcceptsMouseMovedEvents:YES];
        
        mainTrackingRect = [self addTrackingRect:self.frame owner:self userData:nil assumeInside:NO];
        pointToHighlight.y = -1;
    }
    
    return self;
}

- (void) awakeFromNib {
    drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
    paletteState = kSQUMDNormal;
    cacheValid = NO;
    zoomFactor = 1.0f;
    
    [self.window setAcceptsMouseMovedEvents:YES];
    
    if(editingModeDisable) return;
    mainTrackingRect = [self addTrackingRect:self.frame owner:self userData:nil assumeInside:NO];
    pointToHighlight.y = -1;
}

- (NSImage *)rotateIndividualImage: (NSImage *)image clockwise: (BOOL)clockwise {
    NSImage *existingImage = image;
    NSSize existingSize;
    
    /**
     * Get the size of the original image in its raw bitmap format.
     * The bestRepresentationForDevice: nil tells the NSImage to just
     * give us the raw image instead of it's wacky DPI-translated version.
     */
    existingSize.width = [[existingImage bestRepresentationForDevice: nil] pixelsWide];
    existingSize.height = [[existingImage bestRepresentationForDevice: nil] pixelsHigh];
    
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];
    
    [rotatedImage lockFocus];
    
    /**
     * Apply the following transformations:
     *
     * - bring the rotation point to the centre of the image instead of
     *   the default lower, left corner (0,0).
     * - rotate it by 90 degrees, either clock or counter clockwise.
     * - re-translate the rotated image back down to the lower left corner
     *   so that it appears in the right place.
     */
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);
    
    [rotateTF translateXBy: centerPoint.x yBy: centerPoint.y];
    [rotateTF rotateByDegrees:180];
    [rotateTF scaleXBy:-1.0f yBy:1.0f];
    [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
    [rotateTF concat];
    
    /**
     * We have to get the image representation to do its drawing directly,
     * because otherwise the stupid NSImage DPI thingie bites us in the butt
     * again.
     */
    NSRect r1 = NSMakeRect(0, 0, newSize.height, newSize.width);
    [[existingImage bestRepresentationForDevice: nil] drawInRect: r1];
    
    [rotatedImage unlockFocus];
    
    return rotatedImage;
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
        
        for(int i = 0; i < ((width * 8) * (height * 8)); i++) {
            redComponent = paletteByteArr[1] & 0x0F;
            greenComponent = (paletteByteArr[1] & 0xF0) >> 4;
            blueComponent = paletteByteArr[0] & 0x0F;
            
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
            
            bitmapPointer = bitmapContextData + (i << 0x2);
            
            bitmapPointer[0] = redComponentProc;
            bitmapPointer[1] = greenComponentProc;
            bitmapPointer[2] = blueComponentProc;
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
        
            NSImage *nsimage = [self rotateIndividualImage:[[NSImage alloc] initWithCGImage:image size:self.frame.size] clockwise:NO];
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
            
            CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, ((height * 8) * zoomFactor));
            CGContextConcatCTM(prevScaledBitmapContext, flipVertical);
            
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
            
            NSImage *nsimage = [self rotateIndividualImage:[[NSImage alloc] initWithCGImage:image size:self.frame.size] clockwise:NO];
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
                
                //CGContextTranslateCTM(prevScaledBitmapContext, -90, -90);
                /*CGContextRotateCTM (prevScaledBitmapContext, M_PI_2);
                CGContextTranslateCTM(prevScaledBitmapContext, ((width * 8) * zoomFactor) / 2, ((height * 8) * zoomFactor) / 2);
                CGContextRotateCTM (prevScaledBitmapContext, M_PI_2);
                CGContextTranslateCTM(prevScaledBitmapContext, ((width * 8) * zoomFactor) / 2, ((height * 8) * zoomFactor) / 2);*/
                
                CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, ((height * 8) * zoomFactor));
                CGContextConcatCTM(prevScaledBitmapContext, flipVertical);
            
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
    
    if(pointToHighlight.y != -99999999) {
        NSUInteger xTile = floor(pointToHighlight.x / (8 * zoomFactor));
        NSUInteger yTile = floor(pointToHighlight.y / (8 * zoomFactor));
        
        NSRect highlightRect = NSMakeRect(xTile * (8 * zoomFactor), yTile * (8 * zoomFactor), 8 * zoomFactor, 8 * zoomFactor);
        
        [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5] set];
        [NSBezierPath fillRect: highlightRect];
    }
}

- (BOOL) isFlipped {
    return YES;
}

#pragma mark Mouse shenanigans

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (void) mouseMoved:(NSEvent *)theEvent {
    if(editingModeDisable) return;
    
    pointToHighlight = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(pointToHighlight.y < 0 || pointToHighlight.x < 0 || pointToHighlight.y > self.frame.size.height || pointToHighlight.x > self.frame.size.width) {
        pointToHighlight.y = -99999999;
    }
    
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent {
    unsigned char *map;
    map = (unsigned char *)[mappingData bytes];
    
    NSPoint derPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger xTile = floor(derPoint.x / (8 * zoomFactor));
    NSUInteger yTile = floor(derPoint.y / (8 * zoomFactor));
    NSUInteger currentTileOffset = (xTile << 1) + ((yTile * width) << 1);
    NSUInteger theTile = (map[currentTileOffset] << 0x08) + map[currentTileOffset + 1];
    
    if(editingModeDisable && [delegate respondsToSelector:@selector(tileRenderView:tileIndexWasSelected:)]) {
        [delegate tileRenderView:self tileIndexWasSelected:theTile];
    } else {        
        map[currentTileOffset] = (currentlyPlacingTile >> 0x08) & 0xFF;
        map[currentTileOffset + 1] = (currentlyPlacingTile) & 0xFF;
        
        mappingData = [[NSData dataWithBytes:map length:mappingData.length] retain];
        
        [self purgeCache];
        [self setNeedsDisplay:YES];
    }
}

- (void) rightMouseDown:(NSEvent *)theEvent {
    if(editingModeDisable) return;
    
    pointToHighlight = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(pointToHighlight.y < 0 || pointToHighlight.x < 0 || pointToHighlight.y > self.frame.size.height || pointToHighlight.x > self.frame.size.width) {
        pointToHighlight.y = -99999999;
    }
    
    [self setNeedsDisplay:YES];
    
    const unsigned char *map;
    map = (const unsigned char *)[mappingData bytes];
    
    NSPoint derPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSUInteger xTile = floor(derPoint.x / (8 * zoomFactor));
    NSUInteger yTile = floor(derPoint.y / (8 * zoomFactor));
    NSUInteger currentTileOffset = (xTile << 1) + ((yTile * width) << 1);
    NSUInteger theTile = (map[currentTileOffset] << 0x08) + map[currentTileOffset + 1];
    
    unsigned int tileIndex = theTile & 0x7FF;
    unsigned int isMirrored = (theTile & 0x800) >> 0xB;
    unsigned int isFlipped = (theTile & 0x1000) >> 0xC;
    unsigned int palOffset = (theTile & 0x6000) >> 0xD;
    unsigned int priority = (theTile & 0x8000) >> 0xF;
    
    NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Offset 0x%X", nil), currentTileOffset]];
    NSMenuItem *item = nil;
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Priority", nil) action:@selector(contextMenuDidSomething:) keyEquivalent:@""];
    [item setState:(priority == 1) ? NSOnState : NSOffState];
    item.tag = 1 | (currentTileOffset << 3);
    [contextMenu addItem:item];
    
    [contextMenu addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Flipped", nil) action:@selector(contextMenuDidSomething:) keyEquivalent:@""];
    [item setState:(isFlipped == 1) ? NSOnState : NSOffState];
    item.tag = 2 | (currentTileOffset << 3);
    [contextMenu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Mirrored", nil) action:@selector(contextMenuDidSomething:) keyEquivalent:@""];
    [item setState:(isMirrored == 1) ? NSOnState : NSOffState];
    item.tag = 3 | (currentTileOffset << 3);
    [contextMenu addItem:item];
    
    [contextMenu addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy Tile", nil) action:@selector(contextMenuDidSomething:) keyEquivalent:@""];
    item.tag = 4 | (currentTileOffset << 3);
    [contextMenu addItem:item];
    
    [NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
}

- (void) contextMenuDidSomething:(id) sender {
    NSMenuItem *item = (NSMenuItem *) sender;
    NSUInteger tag = (item.tag & 0x07);
    
    NSUInteger currentTileOffset = (item.tag >> 0x03);
    
    unsigned char *map;
    map = (unsigned char *)[mappingData bytes];
    NSUInteger theTile = (map[currentTileOffset] << 0x08) + map[currentTileOffset + 1];
    
    switch (tag) {
        // Priority
        case 1:
            theTile = theTile ^ 0x8000;
            break;
            
        // Flip
        case 2:
            theTile = theTile ^ 0x1000;            
            break;
            
        // Mirror
        case 3:
            theTile = theTile ^ 0x800;            
            break;
            
        // Copy
        case 4:
            currentlyPlacingTile = theTile;
            break;
            
        default:
            break;
    }
    
    map[currentTileOffset] = (theTile >> 0x08) & 0xFF;
    map[currentTileOffset + 1] = (theTile) & 0xFF;
    
    mappingData = [[NSData dataWithBytes:map length:mappingData.length] retain];
    
    if([delegate respondsToSelector:@selector(tileRenderViewMapDidChange:)]) {
        [delegate tileRenderViewMapDidChange:self];
    }
    
    [self purgeCache];
    [self setNeedsDisplay:YES];
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
    
    if(editingModeDisable) return;
    [self removeTrackingRect:mainTrackingRect];
    mainTrackingRect = [self addTrackingRect:NSMakeRect(0, 0, self.frame.size.width * factor, self.frame.size.height * factor) owner:self userData:nil assumeInside:NO];
}

@end
