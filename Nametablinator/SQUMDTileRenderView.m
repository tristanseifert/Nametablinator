//
//  SQUMDTileRenderView.m
//  Nametablinator
//
//  Created by Tristan Seifert on 18/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMDTileRenderView.h"

@implementation SQUMDTileRenderView
@synthesize paletteData, tileData, mappingData, tileOffset, markPriority, height, width;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

@end
