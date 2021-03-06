//
//  SQUImportImageController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 24/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SQUImageDitherer.h"
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
    
    IBOutlet NSImageView *imgView;
    
    dispatch_queue_t processingQueue;
    
    SQUImageDitherer *defaultDitherer;
}

- (void) showImageImporter;

- (IBAction) loading_cancel:(id)sender;

- (IBAction) cancelImport:(id) sender;
- (IBAction) goImport:(id) sender;
- (IBAction) selectDifferentImage:(id) sender;

CGImageRef SQU_CGImageCreateWithNSImage(NSImage *image);

@end
