//
//  SQUPaletteRenderView.h
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "MAAttachedWindow.h"
#import "SQUMDColourPicker.h"

#define SQUDefaultMDPalette {0x0E, 0x0E, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x4E, 0x00, 0x8E, 0x00, 0xAE, 0x00, 0xEE, 0x00, 0xEA, 0x00, 0xE8, 0x00, 0xE0, 0x0E, 0xA0, 0x0E, 0x00, 0x0E, 0x08, 0x08, 0x0A, 0x0E, 0xEE, 0x08, 0x88}

typedef enum {
    kSQUMDHighlight,
    kSQUMDShadow,
    kSQUMDNormal
} SQUMDPaletteState;

@class SQUPaletteRenderView;

@protocol SQUPaletteRenderViewDelegate <NSObject>

- (void) paletteViewPaletteDidChange:(SQUPaletteRenderView *) view;

@end

@interface SQUPaletteRenderView : NSView {
    NSData *paletteData;
    
    SQUMDPaletteState paletteState;
    
    NSUInteger paletteLine;
    
    MAAttachedWindow *colourPickerWindow;
    SQUMDColourPicker *mdColourPicker;
    
    BOOL newFileMode;
    BOOL inMenuMode;
    
    IBOutlet id<SQUPaletteRenderViewDelegate> delegate;
    
    float zoomFactor;
}

@property (nonatomic, retain) NSData *paletteData;
@property (nonatomic) SQUMDPaletteState paletteState;

@property (nonatomic) BOOL inMenuMode;
@property (nonatomic) BOOL newFileMode;
@property (nonatomic) NSUInteger paletteLine;

@property (nonatomic, retain) id<SQUPaletteRenderViewDelegate> delegate;

@property (nonatomic) float zoomFactor;

- (NSColor *) colourForPaletteData:(const unsigned char*) data withState:(SQUMDPaletteState) state;
- (NSColor *) transparentColourForCurrentPaletteLine;
- (NSColor *) transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption; // this has to win the title for longest method name ever or something.

- (void) setUpTooltips;

@end
