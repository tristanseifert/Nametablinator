//
//  SQUPaletteRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUPaletteRenderView.h"

@implementation SQUPaletteRenderView
@synthesize paletteData, paletteState, paletteLine;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
        
        paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
        paletteState = kSQUMDNormal;
        paletteLine = 0;
    }
    
    return self;
}

- (void) awakeFromNib {
    unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
    
    paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
    paletteState = kSQUMDNormal;
    paletteLine = 0;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithDeviceWhite:0.25 alpha:1.0] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height));
    
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, 0)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 0))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, self.frame.size.height)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, 1)) toPoint:NSPointFromCGPoint(CGPointMake(0, self.frame.size.height))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 1)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    
    [NSBezierPath setDefaultLineWidth:0.0];
    
    for(int i = 0; i < 16; i++) {
        const char *bytes;
        bytes = (const char *)[paletteData bytes];
        
        unsigned int palOffset = paletteLine * 0x20;
        
        if(palOffset >= paletteData.length) {
            palOffset = 0;
            
            unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
            
            bytes = (const char *)emptyPalette;
        }
        
        bytes += palOffset + i*2;
        
        [[self colourForPaletteData:bytes withState:self.paletteState] set];
        
        NSRectFill(NSRectFromCGRect(CGRectMake(i*16+1, 1, 15, 16)));
    }
}

#pragma mark Actual conversion routines

- (NSColor *) colourForPaletteData:(const char*) data withState:(SQUMDPaletteState) state {
    unsigned int redComponent = data[1] & 0x0F;
    unsigned int greenComponent = (data[1] & 0xF0) >> 4;
    unsigned int blueComponent = data[0] & 0x0F;
    
    //NSLog(@"Colour data (rgb) before processing: 0x%X, 0x%X, 0x%0X", redComponent, greenComponent, blueComponent);
    
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
    
    NSUInteger redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
    NSUInteger greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
    NSUInteger blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
    
    //NSLog(@"Colour data (rgb) after processing: 0x%X, 0x%X, 0x%0X", redComponentProc, greenComponentProc, blueComponentProc);
    
    return [NSColor colorWithCalibratedRed:redComponentProc / 256.0f green:greenComponentProc / 256.0f blue:blueComponentProc / 256.0f alpha:1.0];
}

- (NSColor *) transparentColourForCurrentPaletteLine {
    const char *bytes;
    bytes = (const char *)[paletteData bytes];
    
    unsigned int palOffset = paletteLine * 0x20;
    
    if(palOffset >= paletteData.length) {
        palOffset = 0;
        
        unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
        
        bytes = (const char *)emptyPalette;
    }
    
    return [self colourForPaletteData:bytes withState:self.paletteState];
}

@end
