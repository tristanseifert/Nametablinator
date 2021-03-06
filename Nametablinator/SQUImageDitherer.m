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
    if(image == NULL) {
        NSLog(@"Image is NULL!");
        return NULL;
    }
    
    unsigned int imageWidth = CGImageGetWidth(image);
    unsigned int imageHeight = CGImageGetHeight(image);
    
    NSLog(@"Image size: %u x %u", imageWidth, imageHeight);
    
    CGContextRef context = CGBitmapContextCreate(NULL, 
                                                 imageWidth, 
                                                 imageHeight, 
                                                 8, 
                                                 4 * (imageWidth), 
                                                 CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), 
                                                 kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image); // draw it
    CGImageRelease(image); // get rid of the image, we don't want it anymore.
    
    
    unsigned char *imageData = CGBitmapContextGetData(context);
    
    unsigned char ditheringModulusType[0x04] = {0x02, 0x03, 0x04, 0x08};
    unsigned char ditheringModulus = ditheringModulusType[matrix];
    
    unsigned int red;
    unsigned int green;
    unsigned int blue;
    
    uint32_t *memoryBuffer;
    memoryBuffer = (uint32_t *) malloc((imageHeight * imageWidth) * 4);
    
    unsigned int thresholds[0x03] = {256/8, 256/8, 256/8};
    
    for(int y = 0; y < imageHeight; y++) {
        for(int x = 0; x < imageWidth; x++) {
            // fetch the colour components, add the dither value to them
            red = (imageData[((y * imageWidth) * 4) + (x << 0x02)]);
            green = (imageData[((y * imageWidth) * 4) + (x << 0x02) + 1]);
            blue = (imageData[((y * imageWidth) * 4) + (x << 0x02) + 2]);

            if(red > 36 && red < 238) {
                red += SQUBayer117_matrix[x % ditheringModulus][y % ditheringModulus];
            } if(green > 36 && green < 238) {
                green += SQUBayer117_matrix[x % ditheringModulus][y % ditheringModulus];
            } if(blue > 36 && blue < 238) {
                blue += SQUBayer117_matrix[x % ditheringModulus][y % ditheringModulus];
            }
            
//            memoryBuffer[(y * imageWidth) + x] = (0xFF0000 + ((x >> 0x1) << 0x08) + (y >> 2));
            memoryBuffer[(y * imageWidth) + x] = find_closest_palette_colour(((red & 0xFF) << 0x10) | ((green & 0xFF) << 0x08) | (blue & 0xFF));
        }
    }
    
    //CGContextRelease(context);
    context = CGBitmapContextCreate(memoryBuffer, 
                                    imageWidth, 
                                    imageHeight, 
                                    8, 
                                    4 * (imageWidth), 
                                    CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), 
                                    kCGImageAlphaNoneSkipLast);
    
    NSLog(@"Created context from buffer: %@", context);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
    return result;
}

uint32_t find_closest_palette_colour(uint32_t rgbPixel) {
    uint32_t result = 0x00000000; // BGRA8
    
    unsigned char red = (rgbPixel & 0xFF0000) >> 0x10;
    unsigned char green = (rgbPixel & 0x00FF00) >> 0x08;
    unsigned char blue = (rgbPixel & 0x0000FF);
    
    red = red & 0xFF;
    green = green & 0xFF;
    blue = blue & 0xFF;
    
    
    result = red + (green << 0x08) + (blue << 0x10);
    
    //result = 0xFF;
    
    return result;
}

@end
