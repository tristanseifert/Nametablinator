//
//  SQUDocument.h
//  Nametablinator
//
//  Created by Tristan Seifert on 09/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUInspectorView.h"
#import "SQUHexadecimalFormatter.h"

@interface SQUDocument : NSDocument {
    IBOutlet JUInspectorViewContainer *inspectorContainer;
    IBOutlet JUInspectorView *sizeInspector;
    IBOutlet JUInspectorView *listOfTilesInspector;
    IBOutlet JUInspectorView *mapInspector;
    
    IBOutlet NSTextField *info_width;
    IBOutlet NSTextField *info_height;
    IBOutlet NSTextField *info_tileOffset;
    IBOutlet NSPopUpButton *info_palOffset;
    IBOutlet NSButton *info_priority;
}

@end
