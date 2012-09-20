//
//  SQUMDTileRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMDTileRenderView.h"

@implementation SQUMDTileRenderView
@synthesize paletteData, tileData, mappingData, tileOffset, markPriority, height, width, paletteState;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
        paletteState = kSQUMDNormal;
        cacheValid = NO;
    }
    
    return self;
}

- (void) awakeFromNib {
    drawingQueue = dispatch_queue_create("co.squee.nametablinator.drawingqueue", NULL);
    paletteState = kSQUMDNormal;
    cacheValid = NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    if(!cacheValid) {
        if(bitmapContextData != NULL) {
            free(bitmapContextData); // free the old bitmap context data
            CGContextRelease(prevBitmapContext); // free old bitmap context
        }
        
        unsigned int bytesPerRow = (width * 8) * 4;
        unsigned int bytesPerPixel = 4;
        
        CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width * 8, height * 8, 8, bytesPerRow, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaNoneSkipLast);
        bitmapContextData = CGBitmapContextGetData(bitmapContext);
        prevBitmapContext = bitmapContext;
        
        if(bitmapContextData == NULL) {
            NSLog(@"Bitmap context is NULL!");
            
            [[NSColor redColor] set];
            NSRectFill(self.frame);
            
            return;
        }
        
        const char *map;
        const char *tileDatas;
        const char *currentTileData;
        map = (const char *)[mappingData bytes];
        tileDatas = (const char *)[tileData bytes];
        
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
        
        unsigned char *bitmapPointer;
        
        const char *paletteByteArr;
        paletteByteArr = (const char *)[paletteData bytes];
        
        unsigned int palOffset = 0x0;
        
        if(palOffset >= paletteData.length) {
            palOffset = 0;
            
            unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
            
            paletteByteArr = (const char *)emptyPalette;
        }
        
        for (int row = 0; row < height; row++) {
            for(int column = 0; column < width; column++) {
                mapOffset = (row * (width << 1)) + (column << 1);
                
                tileIndex = 0;
                currentTile = (map[mapOffset] << 0x08) + map[mapOffset + 1];
                
                //NSLog(@"Current tile offset for (0x%X, 0x%X) 0x%X. (Offset 0x%X)", column, row, currentTile, mapOffset);
                
                tileIndex = currentTile & 0x7FF;
                tileIndex -= tileOffset;
                
                palOffset = 0;
                palOffset = ((currentTile & 0x6000) >> 0xD) << 0x05;
                
                currentTileData = tileDatas;
                currentTileData += (tileIndex << 5);
                
                //unsigned char currentTileData[0x20] = {0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99, 0x11, 0x11, 0x11, 0x11, 0x99, 0x99, 0x99, 0x99};
                
                point = CGPointMake(column << 3, row << 3);
                
                for (int tile_row = 0; tile_row < 8; tile_row++) {
                    for (int tile_column = 0; tile_column < 8; tile_column++) {
                        tileDataOffset = (((tile_row) << 0x02) + (tile_column >> 0x01));
                        //NSLog(@"Tile offset for pixel at (%i, %i): 0x%X", tile_column, tile_row, tileDataOffset);
                        
                        if(tile_column % 2 == 0) {
                            currentPixel = (currentTileData[tileDataOffset] & 0xF0) >> 4;
                            //NSLog(@"Pixel data (even): 0x%X", currentPixel);
                        } else {
                            currentPixel = currentTileData[tileDataOffset] & 0x0F;
                        }
                        
                        //currentPixel = (paletteLUT[currentPixel]) << 0x1;
                        currentPixel = currentPixel << 0x1;
                        
                        if(currentPixel != 0x00) {
                            //NSLog(@"Pixel's palette offset: 0x%X", currentPixel);
                            
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
                            
                            //[[NSColor colorWithCalibratedRed:redComponentProc / 256.0f green:greenComponentProc / 256.0f blue:blueComponentProc / 256.0f alpha:1.0] set];
                            //NSRectFill(NSMakeRect(point.x + tile_column, point.y + tile_row, 1, 1));
                            
                            
                        }
                    }
                }
            }
        }
        
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        NSImage *nsimage = [[NSImage alloc] initWithCGImage:image size:self.frame.size];
        [nsimage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        
        cacheValid = YES;
    } else {        
        CGContextRef bitmapContext = CGBitmapContextCreate(bitmapContextData, width * 8, height * 8, 8, (width * 8) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaNoneSkipLast);
        
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        NSImage *nsimage = [[NSImage alloc] initWithCGImage:image size:self.frame.size];
        [nsimage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];     
        
        [nsimage release];
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

@end
