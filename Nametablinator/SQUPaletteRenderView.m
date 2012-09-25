//
//  SQUPaletteRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUPaletteRenderView.h"
#import "NSColor_CheckerboardColor.h"

@implementation SQUPaletteRenderView
@synthesize paletteData, paletteState, paletteLine, newFileMode, inMenuMode, delegate, zoomFactor;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
        
        paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
        paletteState = kSQUMDNormal;
        paletteLine = 0;
        
        [self setUpTooltips];
        
        newFileMode = NO;
        inMenuMode = NO;
    }
    
    return self;
}

- (void) awakeFromNib {
    unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
    
    paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
    paletteState = kSQUMDNormal;
    paletteLine = 0;
    
    [self setUpTooltips];
    
    newFileMode = NO;
    inMenuMode = NO;
}

- (void) setUpTooltips {
    for(int i = 0; i < 16; i++) {
        [self addToolTipRect:NSMakeRect(i*16+1, 1, 15, 16) owner:self userData:[[NSNumber numberWithInt:i] retain]];
    }
}

- (void)drawRect:(NSRect)dirtyRect {    
    [[NSColor colorWithDeviceWhite:0.25 alpha:1.0] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    
    NSUInteger offset = (inMenuMode) ? 1 : 0;
    
    NSRectFill(NSMakeRect(0 + offset, 0, self.frame.size.width, self.frame.size.height));
    
    //[NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0 + offset, 0)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 0))];
    //[NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0 + offset, self.frame.size.height)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    //[NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0 + offset, 1)) toPoint:NSPointFromCGPoint(CGPointMake(0 + offset, self.frame.size.height))];
    //[NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 1)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
    
    [NSBezierPath setDefaultLineWidth:0.0];
    
    for(int i = 0; i < 16; i++) {
        const unsigned char *bytes;
        bytes = (const unsigned char *)[paletteData bytes];
        
        unsigned int palOffset = paletteLine * 0x20;
        
        if(palOffset >= paletteData.length) {
            palOffset = 0;
            
            unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
            
            bytes = (const unsigned char *)emptyPalette;
        }
        
        bytes += palOffset + i*2;
        
        [[self colourForPaletteData:bytes withState:self.paletteState] set];
        
        NSRectFill(NSRectFromCGRect(CGRectMake(i*16+1 + offset, 1, 15, 16)));
    }
}

#pragma mark Actual conversion routines

- (NSColor *) colourForPaletteData:(const unsigned char*) data withState:(SQUMDPaletteState) state {
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
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"transparentRender"] == 1) {
        const unsigned char *bytes;
        bytes = (const unsigned char *)[paletteData bytes];
        
        unsigned int palOffset = paletteLine * 0x20;
        
        if(palOffset >= paletteData.length) {
            palOffset = 0;
            
            unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
            
            bytes = (const unsigned char *)emptyPalette;
        }
        
        return [self colourForPaletteData:bytes withState:self.paletteState];
    } else {
        if(zoomFactor < 1) {
            zoomFactor = 1.0f;
        }
        
        return [NSColor checkerboardColorWithFirstColor:[NSColor whiteColor] secondColor:[NSColor lightGrayColor] squareWidth:8.0 * zoomFactor];
    }
}

- (NSColor *) transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption {
    const unsigned char *bytes;
    bytes = (const unsigned char *)[paletteData bytes];
    
    unsigned int palOffset = paletteLine * 0x20;
    
    if(palOffset >= paletteData.length) {
        palOffset = 0;
        
        unsigned char emptyPalette[0x20] = {0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
        
        bytes = (const unsigned char *)emptyPalette;
    }
    
    return [self colourForPaletteData:bytes withState:self.paletteState];
}

#pragma mark Tooltip stuffsors

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData {
    if(inMenuMode) return nil; // hide tooltips and ignore clicks in menu mode
    
    NSNumber *dasNumber = (NSNumber *) userData;
    
    const char *data;
    data = (const char *)[paletteData bytes];
    data += [dasNumber intValue] * 2;
    
    NSString *toolTip = @"";
    toolTip = [toolTip stringByAppendingFormat:@"Palette Entry $%X\n\n", [dasNumber intValue]];
    
    unsigned int redComponent = data[1] & 0x0F;
    unsigned int greenComponent = (data[1] & 0xF0) >> 4;
    unsigned int blueComponent = data[0] & 0x0F;
    
    toolTip = [toolTip stringByAppendingFormat:@"Normal: $0%X%X%0X\n", redComponent, greenComponent, blueComponent];
    
    //NSLog(@"Colour data (rgb) before processing: 0x%X, 0x%X, 0x%0X", redComponent, greenComponent, blueComponent);
    
    redComponent = data[1] & 0x0F;
    greenComponent = (data[1] & 0xF0) >> 4;
    blueComponent = data[0] & 0x0F;
    
    redComponent = redComponent >> 1;
    greenComponent = greenComponent >> 1;
    blueComponent = blueComponent >> 1;
    
    toolTip = [toolTip stringByAppendingFormat:@"Shadowed: $0%X%X%0X\n", redComponent, greenComponent, blueComponent];
    
    redComponent = data[1] & 0x0F;
    greenComponent = (data[1] & 0xF0) >> 4;
    blueComponent = data[0] & 0x0F;
    
    redComponent = redComponent >> 1;
    greenComponent = greenComponent >> 1;
    blueComponent = blueComponent >> 1;
    
    redComponent += 0x7;
    greenComponent += 0x7;
    blueComponent += 0x7;
    
    toolTip = [toolTip stringByAppendingFormat:@"Highlighted: $0%X%X%0X", redComponent, greenComponent, blueComponent];
    
    return toolTip;
}

#pragma mark Mouse/editing 

- (void)mouseDown:(NSEvent *)theEvent {
    if(inMenuMode) return; // hide tooltips and ignore clicks in menu mode
    
    NSPoint curPoint;
    
    if(newFileMode) {
        curPoint = [theEvent locationInWindow];
        curPoint.y = self.window.frame.size.height - 32;
        curPoint.x = (ceil(curPoint.x / 16) * 16) - 3;
    } else {
        curPoint = [theEvent locationInWindow];        
    }
    
    NSLog(@"%@", NSStringFromPoint(curPoint));
    
    if(!mdColourPicker) {
        mdColourPicker = [[[SQUMDColourPicker alloc] init] retain];
        
        if(![NSBundle loadNibNamed:@"SQUMDColourPicker" owner:mdColourPicker]) {
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Can't Load Colour Picker", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The NIB file could not be loaded for some reason. Please re-install the application.", nil)] runModal];
            
            [mdColourPicker release];
            mdColourPicker = nil;
            
            return;
        }
    }
    
    if(colourPickerWindow) {
        [colourPickerWindow orderOut:self];
        [colourPickerWindow release];
    }
    
    colourPickerWindow = [[[MAAttachedWindow alloc] initWithView:mdColourPicker.pickerView attachedToPoint:curPoint inWindow:self.window onSide:MAPositionAutomatic atDistance:5.0] retain];
    
    [colourPickerWindow makeKeyAndOrderFront:self];
}

@end
