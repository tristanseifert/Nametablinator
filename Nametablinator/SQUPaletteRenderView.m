//
//  SQUPaletteRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUPaletteRenderView.h"

@implementation SQUPaletteRenderView
@synthesize paletteData, numRows, paletteState;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
        
        paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
    }
    
    return self;
}

- (void) awakeFromNib {
    unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
    
    paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithDeviceWhite:0.1 alpha:1.0] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, 0)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 0))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, self.frame.size.height)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, 1)) toPoint:NSPointFromCGPoint(CGPointMake(0, self.frame.size.height))];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 1)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    
    [[NSColor redColor] set];
    
    for (int i = 1; i < 16; i++) {
        [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(i*17+1, 1)) toPoint:NSPointFromCGPoint(CGPointMake(i*17+1, self.frame.size.height-1))];
    }
    
    [[NSColor redColor] set];
    
    for(int i = 0; i < 16; i++) {
        
        const char *bytes;
        bytes = (const char *)[paletteData bytes];
        
        unsigned int redComponent = bytes[i*2 + 1] & 0x0F;
        unsigned int greenComponent = (bytes[i*2 + 1] & 0xF0) >> 4;
        unsigned int blueComponent = bytes[i*2 + 0] & 0x0F;
        
        NSLog(@"Colour data (rgb) before processing: 0x%X, 0x%X, 0x%0X", redComponent, greenComponent, blueComponent);
        
        NSUInteger redComponentProc = ((redComponent >> 1) * 36) & 0xFF;
        NSUInteger greenComponentProc = ((greenComponent >> 1) * 36) & 0xFF;
        NSUInteger blueComponentProc = ((blueComponent >> 1) * 36) & 0xFF;
        
        NSLog(@"Colour data (rgb) after processing: 0x%X, 0x%X, 0x%0X", redComponentProc, greenComponentProc, blueComponentProc);
     
        [[NSColor colorWithCalibratedRed:redComponentProc / 256.0f green:greenComponentProc / 256.0f blue:blueComponentProc / 256.0f alpha:1.0] set];
        
        NSRectFill(NSRectFromCGRect(CGRectMake(i*16+1, 1, 15, 16)));
    }
}

@end
