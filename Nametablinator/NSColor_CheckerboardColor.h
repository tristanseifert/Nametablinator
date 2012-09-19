//
//  NSColor_CheckerboardColor.h
//  AMGradientPanel
//
//  Created by Andreas on 18.01.10.
//  Copyright 2010 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (CheckerboardColor)

+ (NSColor *)checkerboardColorWithFirstColor:(NSColor *)firstColor secondColor:(NSColor *)secondColor squareWidth:(CGFloat)width;
// Returns a pattern-color usable to draw a checkerboard pattern:
// Four squares with sides of width 'width'.
// First and third quadrant in firstColor, second and fourth quadrant in secondColor.
// Both colors 


@end
