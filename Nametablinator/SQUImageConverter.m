//
//  SQUImageConverter.m
//  Nametablinator
//
//  Created by Tristan Seifert on 25/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUImageConverter.h"

@implementation SQUImageConverter

- (NSArray *) convertQuantatisedImageToMDData:(CGImageRef) dasImage {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(dasImage), CGImageGetHeight(dasImage), 8, (CGImageGetWidth(dasImage)) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaLast);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(dasImage), CGImageGetHeight(dasImage)), dasImage); // draw it
    CGImageRelease(dasImage); // get rid of the image, we don't want it anymore.
    
    
    
    CGContextRelease(context);
    return [result autorelease];
}

@end
