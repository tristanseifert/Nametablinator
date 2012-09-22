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
    
    NSDictionary *defaultPalData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SQUProjectPaletteDefaults" ofType:@"plist"]];
    
    pal_defaults = [[defaultPalData objectForKey:@"defaults"] retain];
}

- (void) openNewProjWindow {
    [pal_defaultChooser removeAllItems];
    
    [pal_defaultChooser addItemWithTitle:NSLocalizedString(@"Default Palettes", nil)];
    
    for (NSDictionary *defaultPal in pal_defaults) {
        if([[defaultPal objectForKey:@"name"] isEqualToString:@"%%sep%%"]) {
            [[pal_defaultChooser menu] addItem:[NSMenuItem separatorItem]];
        } else {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.title = [defaultPal objectForKey:@"name"];
            item.tag = [pal_defaults indexOfObject:defaultPal];
            
            [[pal_defaultChooser menu] addItem:item];
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"showColourPreview"]) {
                NSMenuItem *item2 = [[NSMenuItem alloc] init];
                SQUPaletteRenderView *meeper = [[SQUPaletteRenderView alloc] initWithFrame:NSMakeRect(0, 0, 258, 18)];
                meeper.paletteData = (NSData *)[defaultPal objectForKey:@"data"];
                meeper.inMenuMode = YES;
                [item2 setView:meeper];
                
                [[pal_defaultChooser  menu] addItem:item2];
            }
        }
    }
    
    NSMenuItem *item;
    
    [[pal_defaultChooser menu] addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Shadow", nil);
    item.tag = -2000;
    [[pal_defaultChooser menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Normal", nil);
    item.tag = -2001;
    item.state = NSOnState;
    [[pal_defaultChooser menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Highlight", nil);
    item.tag = -2002;
    [[pal_defaultChooser menu] addItem:item];
    
    [[pal_defaultChooser menu] addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Open File...", nil);
    item.tag = -1000;
    [[pal_defaultChooser menu] addItem:item];
    
    currentView = 1;
    [self updateView];
    
    [window center];
    [window makeKeyAndOrderFront:self];
}

#pragma mark Palette view specific

- (IBAction) pal_presetChanged:(id) sender {
    NSInteger selectedPalette = [pal_defaultChooser selectedItem].tag;

    if(selectedPalette >= 0) {
        NSDictionary *palInfo = [pal_defaults objectAtIndex:selectedPalette];
        
        if([palInfo objectForKey:@"data"]) {
            pal_palView.paletteData = (NSData *) [palInfo objectForKey:@"data"];
            [pal_palView setNeedsDisplay:YES];
        }
        
    } else if(selectedPalette <= -2000 && selectedPalette > - 2004) {
        [[[pal_defaultChooser menu] itemWithTag:-2000] setState:NSOffState];
        [[[pal_defaultChooser menu] itemWithTag:-2001] setState:NSOffState];
        [[[pal_defaultChooser menu] itemWithTag:-2002] setState:NSOffState];
        
        
        switch (selectedPalette) {
            case -2000:
                pal_palView.paletteState = kSQUMDShadow;
                [[[pal_defaultChooser menu] itemWithTag:-2000] setState:NSOnState];
                
                break;
                
            case -2001:
                pal_palView.paletteState = kSQUMDNormal;
                [[[pal_defaultChooser menu] itemWithTag:-2001] setState:NSOnState];
                
                break;
                
            case -2002:
                pal_palView.paletteState = kSQUMDHighlight;
                [[[pal_defaultChooser menu] itemWithTag:-2002] setState:NSOnState];
                
                break;
                
            default:
                break;
        }
        
        [pal_palView setNeedsDisplay:YES];
    } else if(selectedPalette < 0 && selectedPalette >= -1000) {
        NSOpenPanel *panel;
        
        switch (selectedPalette) {
            case -1000:
                panel = [NSOpenPanel openPanel];
                
                [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
                    if (result == NSFileHandlingPanelOKButton) {
                        NSURL *urlOfFile = [panel URL];
                        
                        pal_palView.paletteData = [NSData dataWithContentsOfURL:urlOfFile];
                        [pal_palView setNeedsDisplay:YES];
                    }
                }];
                
                break;
                
            default:
                break;
        }
    }
    
    //NSLog(@"Chose item: %li", selectedPalette);
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
            NSLog(@"Invalid view number %li", currentView);
            break;
    }
}

- (IBAction) cancelNew:(id)sender {
    [window orderOut:sender];
    
    currentView = 0;
    [self updateView];
}

@end
