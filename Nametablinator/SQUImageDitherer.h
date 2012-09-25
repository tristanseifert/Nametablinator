//
//  SQUImageDitherer.h
//  Nametablinator
//
//  Created by Tristan Seifert on 25/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <stdint.h>

typedef enum {
    kSQUBayer15 = 0,
    kSQUBayer110 = 1,
    kSQUBayer117 = 2,
    kSQUBayer165 = 3
} SQUBayerDitheringMatrix;

static const unsigned char SQUBayer15_matrix[2][2] = {{1, 3}, {4, 2}};

static const unsigned char SQUBayer110_matrix[3][3] = {{3, 7, 4}, {6, 1, 9}, {2, 8, 5}};

static const unsigned char SQUBayer117_matrix[4][4] = {{1, 9, 3, 11}, {13, 5, 15, 7}, {4, 12, 2, 10}, {16, 8, 14, 6}};

static const unsigned char SQUBayer165_matrix[8][8] = {{1, 49, 13, 61, 4, 52, 16, 64}, {33, 17, 45, 29, 36, 20, 48, 32}, {9, 57, 5, 53, 12, 60, 8, 56}, {41, 25, 37, 21, 44, 28, 40, 24}, {3, 51, 15, 63, 2, 50, 14, 62}, {35, 19, 47, 31, 34, 18, 46, 30}, {11, 59, 7, 55, 10, 58, 6, 54}, {43, 27, 39, 23, 42, 26, 38, 22}};

@interface SQUImageDitherer : NSObject {
    
}

- (CGImageRef) ditherImageTo16Colours:(CGImageRef)image withDitheringMatrixType:(SQUBayerDitheringMatrix) matrix;

uint32_t find_closest_palette_colour(unsigned int rgbPixel);

@end
