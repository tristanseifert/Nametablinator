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

#define SQUDefaultMDPalette {0x0E, 0x0E, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x4E, 0x00, 0x8E, 0x00, 0xAE, 0x00, 0xEE, 0x00, 0xEA, 0x00, 0xE8, 0x00, 0xE0, 0x0E, 0xA0, 0x0E, 0x00, 0x0E, 0x08, 0x08, 0x0A, 0x0E, 0xEE, 0x08, 0x88}

typedef enum {
    kSQUMDHighlight,
    kSQUMDShadow,
    kSQUMDNormal
} SQUMDPaletteState;

@interface SQUPaletteRenderView : NSView {
    NSData *paletteData;
    
    NSUInteger numRows;
    SQUMDPaletteState paletteState;
}

@property (nonatomic, retain) NSData *paletteData;
@property (nonatomic) NSUInteger numRows;
@property (nonatomic) SQUMDPaletteState paletteState;

@end
