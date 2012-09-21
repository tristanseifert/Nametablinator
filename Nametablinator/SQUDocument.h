//
//  SQUDocument.h
//  Nametablinator
//
//  Created by Tristan Seifert on 09/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JUInspectorView.h"
#import "BWTexturedSlider.h"

#import "SQUHexadecimalFormatter.h"
#import "SQUMDTileRenderView.h"
#import "SQUPaletteRenderView.h"

@interface SQUDocument : NSDocument <NSSplitViewDelegate> {
    IBOutlet JUInspectorViewContainer *inspectorContainer;
    IBOutlet JUInspectorView *sizeInspector;
    IBOutlet JUInspectorView *listOfTilesInspector;
    IBOutlet JUInspectorView *mapInspector;
    
    IBOutlet NSTextField *info_width;
    IBOutlet NSTextField *info_height;
    IBOutlet NSTextField *info_tileOffset;
    IBOutlet NSPopUpButton *info_palOffset;
    IBOutlet NSButton *info_priority;
    
    IBOutlet NSScrollView *mainScroller;
    IBOutlet SQUMDTileRenderView *mainView;
    IBOutlet SQUPaletteRenderView *palette;
    
    IBOutlet NSPopUpButton *palViewer_actionBtn;
    
    IBOutlet BWTexturedSlider *zoomSlider;
    
    BOOL liveResizeInProgress;
}

- (IBAction) palViewer_shadowHighlight:(id) sender;

- (IBAction) inspector_resize_reopenWSize:(id) sender;
- (IBAction) inspector_resize_resizeMap:(id) sender;

- (IBAction) doZoomSliderAction:(id) sender;

@end
