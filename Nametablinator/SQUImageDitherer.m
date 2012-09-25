//
//  SQUImageDitherer.m
//  Nametablinator
//
//  Created by Tristan Seifert on 25/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUImageDitherer.h"

@implementation SQUImageDitherer

- (CGImageRef) ditherImageTo16Colours:(CGImageRef)image withDitheringMatrixType:(SQUBayerDitheringMatrix) matrix {
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(image), CGImageGetHeight(image), 8, (CGImageGetWidth(image)) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaLast);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image); // draw it
    CGImageRelease(image); // get rid of the image, we don't want it anymore.
    
    
    unsigned char *imageData = CGBitmapContextGetData(context);
    
    unsigned char ditheringModulusType[0x04] = {0x02, 0x03, 0x04, 0x08};
    unsigned char ditheringModulus = ditheringModulusType[matrix];
    uint32_t oldPixel;
    
    uint32_t *memoryBuffer;
    memoryBuffer = (uint32_t *) malloc((CGImageGetHeight(image) * CGImageGetWidth(image)) * 4);
    
    for(int y = 0; y < CGImageGetHeight(image); y++) {
        for(int x = 0; x < CGImageGetWidth(image); x++) {
            oldPixel = (imageData[((y * CGImageGetWidth(image)) * 4) + (x << 0x02) + 0] << 0x10) | (imageData[((y * CGImageGetWidth(image)) * 4) + (x << 0x02) + 1] << 0x8) | imageData[((y * CGImageGetWidth(image)) * 4) + (x << 0x02) + 2];
            
            // do the dithery shit here
            
            memoryBuffer[(y * CGImageGetWidth(image)) + x] = find_closest_palette_colour(oldPixel);
        }
    }
    
    CGContextRelease(context);
    context = CGBitmapContextCreate(memoryBuffer, CGImageGetWidth(image), CGImageGetHeight(image), 8, (CGImageGetWidth(image)) * 4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaLast);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
    return result;
}

uint32_t find_closest_palette_colour(uint32_t rgbPixel) {
    uint32_t result = rgbPixel;
    
    return result;
}

@end
