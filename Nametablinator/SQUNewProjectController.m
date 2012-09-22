//
//  SQUNewProjectController.m
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUNewProjectController.h"
#import "NSWindow+NSWindow_SQUCGSPrivateEffects.h"

@implementation SQUNewProjectController

- (void) awakeFromNib {
    [magicalContainer setWantsLayer:YES];

    NSData *data = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/BeachPal.bin"];
    NSLog(@"Datas: %@", data);
    
    NSDictionary *defaultPalData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SQUProjectPaletteDefaults" ofType:@"plist"]];
    
    pal_defaults = [[defaultPalData objectForKey:@"defaults"] retain];
    
    [pal_defaultChooser removeAllItems];
    
    for (NSDictionary *defaultPal in pal_defaults) {
        [pal_defaultChooser addItemWithTitle:[defaultPal objectForKey:@"name"]];
    }
}

- (void) openNewProjWindow {
    currentView = 0;
    [self updateView];
    
    [window center];
    [window makeKeyAndOrderFront:self];
}

#pragma mark View Exchanging

- (IBAction) nextView:(id)sender {
    if(currentView < 2) {
        currentView++;
        [self updateView];
        [window doCGAnimation:CGSCube andOption:0x01 withDuration:1.0 fullScreen:NO];
    }
}

- (IBAction) prevView:(id)sender {
    if(currentView != 0) {
        currentView--;
        [self updateView];
        [window doCGAnimation:CGSCube andOption:0x02 withDuration:1.0 fullScreen:NO];
    }
}

- (void) updateView {
    [view_pal removeFromSuperviewWithoutNeedingDisplay];
    [view_art removeFromSuperviewWithoutNeedingDisplay];
    [view_map removeFromSuperviewWithoutNeedingDisplay];
    
    [nextBtn setEnabled:YES];
    [prevBtn setEnabled:YES];
    [nextBtn setTitle:NSLocalizedString(@"Next", nil)];
    
    switch (currentView) {
        case 0:
            pal_palView.newFileMode = YES;
            
            currentPaneTitle.stringValue = NSLocalizedString(@"Palette", nil);
            
            view_pal.frame = NSMakeRect(0, 0, 560, 300);
            [magicalContainer addSubview:view_pal];

            [nextBtn setEnabled:YES];
            [prevBtn setEnabled:NO];
            break;
        case 1:
            currentPaneTitle.stringValue = NSLocalizedString(@"Art Tiles", nil);
            
            view_art.frame = NSMakeRect(0, 0, 560, 300);
            [magicalContainer addSubview:view_art];
            break;
        case 2:
            currentPaneTitle.stringValue = NSLocalizedString(@"Nametable", nil);
            
            view_map.frame = NSMakeRect(0, 0, 560, 300);
            [magicalContainer addSubview:view_map];
            
            [nextBtn setTitle:NSLocalizedString(@"Finish", nil)];
            break;
            
        default:
            NSLog(@"Invalid view number %i", currentView);
            break;
    }
}

- (IBAction) cancelNew:(id)sender {
    
}

@end
