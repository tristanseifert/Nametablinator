//
//  NSColor_CheckerboardColor.m
//  AMGradientPanel
//
//  Created by Andreas on 18.01.10.
//  Copyright 2010 Andreas Mayer. All rights reserved.
//

#import "NSColor_CheckerboardColor.h"


@implementation NSColor (CheckerboardColor)

+ (NSColor *)checkerboardColorWithFirstColor:(NSColor *)firstColor secondColor:(NSColor *)secondColor squareWidth:(CGFloat)width
{
	NSColor *result = nil;
	NSSize bufferSize = NSMakeSize(width*2.0, width*2.0);
	NSRect rect = NSZeroRect;
	rect.size = bufferSize;
	NSImage *buffer = [[NSImage alloc] initWithSize:bufferSize];
	rect.size = NSMakeSize(width, width);
	[buffer lockFocus];

	[firstColor set];
	NSRectFill(rect);

	rect.origin.x = width;
	rect.origin.y = width;
	NSRectFill(rect);

	[secondColor set];
	rect.origin.x = 0.0;
	rect.origin.y = width;
	NSRectFill(rect);

	rect.origin.x = width;
	rect.origin.y = 0.0;
	NSRectFill(rect);
	
	[buffer unlockFocus];
	result = [NSColor colorWithPatternImage:buffer];
	[buffer release];
	return result;
}


@end
