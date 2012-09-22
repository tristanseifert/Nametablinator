//
//  SQUNewProjectController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SQUPaletteRenderView.h"
#import "SQUMDTileRenderView.h"
#import "CGSPrivate.h"

@interface SQUNewProjectController : NSObject {
    IBOutlet NSWindow *window;
    
    CATransition *transition;
    
    IBOutlet NSButton *nextBtn;
    IBOutlet NSButton *prevBtn;
    IBOutlet NSButton *cancelBtn;
    
    NSUInteger currentView;
    
    IBOutlet NSTextField *currentPaneTitle;
    IBOutlet NSView *view_pal;
    IBOutlet NSView *view_map;
    IBOutlet NSView *view_art;
    
    IBOutlet NSBox *magicalContainer;
    
    IBOutlet NSPopUpButton *pal_defaultChooser;
    IBOutlet SQUPaletteRenderView *pal_palView;
    
    IBOutlet SQUMDTileRenderView *map_viewinator;
    IBOutlet NSScrollView *map_scrollView;
    
    NSArray *pal_defaults;
}

- (void) openNewProjWindow;
- (void) updateView;

- (IBAction) nextView:(id)sender;
- (IBAction) prevView:(id)sender;
- (IBAction) cancelNew:(id)sender;

@end
