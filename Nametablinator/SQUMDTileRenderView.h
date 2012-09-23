//
//  SQUMDTileRenderView.h
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SQUPaletteRenderView.h"

@interface SQUMDTileRenderView : NSView {
    NSData *paletteData;
    NSData *tileData;
    NSData *mappingData;
    
    NSUInteger tileOffset;
    NSUInteger width;
    NSUInteger height;
    
    BOOL markPriority;
    
    SQUMDPaletteState paletteState;
    
    dispatch_queue_t drawingQueue;
    
    BOOL cacheValid;
    void *bitmapContextData;
    void *scaledBitmapContextData;
    CGContextRef prevBitmapContext;
    CGContextRef prevScaledBitmapContext;
    
    float renderedZoomFactor;
    float zoomFactor;
    
    NSUInteger currentlyPlacingTile;
}

@property (nonatomic, retain, readwrite) NSData *paletteData;
@property (nonatomic, retain, readwrite) NSData *tileData;
@property (nonatomic, retain, readwrite) NSData *mappingData;

@property (nonatomic) NSUInteger tileOffset;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@property (nonatomic) BOOL markPriority;

@property (nonatomic) SQUMDPaletteState paletteState;

@property (nonatomic, readonly) CGContextRef prevBitmapContext;
@property (nonatomic, readonly) CGContextRef prevScaledBitmapContext;

@property (nonatomic) NSUInteger currentlyPlacingTile;


- (NSImage *) renderImageForTile:(NSUInteger) tileIndex;
- (void) drawTileData:(const char*) data atPoint:(CGPoint) point;
- (void) purgeCache;

- (void) setZoomFactor:(float) factor;

@end
