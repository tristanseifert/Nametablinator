//
//  SQUImageDitherer.m
//  Nametablinator
//
//  Created by Tristan Seifert on 25/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUImageDitherer.h"

@implementation SQUImageDitherer

- (CGImageRef) ditherImageTo16Colours:(CGImageRef)image  {
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(image), CGImageGetHeight(image), 8, (CGImageGetWidth(image)) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaLast);
    
    
    CGImageRef result = CGBitmapContextCreateImage(context);
    return result;
}

@end
