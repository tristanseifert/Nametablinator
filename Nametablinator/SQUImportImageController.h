//
//  SQUImportImageController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 24/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SQUPaletteRenderView.h"
#import "SQUMDTileRenderView.h"
#import "CGSPrivate.h"
#import "utils.h"

@interface SQUImportImageController : NSWindowController <NSWindowDelegate> {
    IBOutlet NSPanel *loading_panel;
    IBOutlet NSProgressIndicator *loading_bar;
    IBOutlet NSTextField *loading_bold;
    IBOutlet NSTextField *loading_desc;
    IBOutlet NSButton *loading_cancel;
    
    IBOutlet NSScrollView *mainScroll;
    IBOutlet SQUMDTileRenderView *mainView;
    IBOutlet SQUPaletteRenderView *palView;
    
    dispatch_queue_t processingQueue;
}

- (void) showImageImporter;

- (IBAction) loading_cancel:(id)sender;

- (IBAction) cancelImport:(id) sender;
- (IBAction) goImport:(id) sender;
- (IBAction) selectDifferentImage:(id) sender;

@end
