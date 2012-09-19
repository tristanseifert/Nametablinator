//
//  SQUMDTileRenderView.h
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SQUMDTileRenderView : NSView {
    NSData *paletteData;
    NSData *tileData;
    NSData *mappingData;
    
    NSUInteger tileOffset;
    NSUInteger width;
    NSUInteger height;
    
    BOOL markPriority;
    
}

@property (nonatomic, retain, readwrite) NSData *paletteData;
@property (nonatomic, retain, readwrite) NSData *tileData;
@property (nonatomic, retain, readwrite) NSData *mappingData;

@property (nonatomic) NSUInteger tileOffset;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@property (nonatomic) BOOL markPriority;

@end
