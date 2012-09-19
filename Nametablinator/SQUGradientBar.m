//
//  SQUGradientBar.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUGradientBar.h"

@implementation SQUGradientBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    gradientEndColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
    gradientStartColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    
    NSGradient *gradient = [[NSGradient alloc]initWithStartingColor:gradientStartColor endingColor:gradientEndColor];
    
    [gradient drawInRect:NSRectFromCGRect(CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - 2)) angle:90];
    
    [NSBezierPath setDefaultLineWidth:1];
    
    [[NSColor colorWithDeviceWhite:0.5 alpha:1.0] set];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, 0)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, 0))];
    
    [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] set];
    [NSBezierPath strokeLineFromPoint:NSPointFromCGPoint(CGPointMake(0, self.frame.size.height)) toPoint:NSPointFromCGPoint(CGPointMake(self.frame.size.width, self.frame.size.height))];
}

@end
