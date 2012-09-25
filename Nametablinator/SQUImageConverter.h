//
//  SQUImageConverter.h
//  Nametablinator
//
//  Created by Tristan Seifert on 25/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SQUImageConverter : NSObject {
    
}

- (NSArray *) convertQuantatisedImageToMDData:(CGImageRef) dasImage;

@end
