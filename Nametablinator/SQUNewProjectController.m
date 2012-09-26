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
    window.delegate = self;
    
    NSDictionary *defaultPalData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SQUProjectPaletteDefaults" ofType:@"plist"]];
    pal_defaults = [[defaultPalData objectForKey:@"defaults"] retain];
    
    NSDictionary *defaultArtData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SQUProjectArtTileDefaults" ofType:@"plist"]];
    art_defaults = [[defaultArtData objectForKey:@"defaults"] retain];
    
    NSMutableData *artTileViewMap = [[NSMutableData alloc] initWithCapacity:0x800 * 0x2];
    
    unsigned short *array = NULL;
    
    for(int i = 0; i < 0x800; i++) {
        unsigned short currentSphere[0x1] = {swap_uint16(i)};
        
        array = currentSphere;
        
        [artTileViewMap appendBytes:(const char*)array length:0x2];
    }
    
    art_tileViewer.mappingData = [artTileViewMap retain];
    
    NSMenuItem *item = nil;
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Shadow", nil);
    item.tag = -2000;
    [[art_actionMenu menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Normal", nil);
    item.tag = -2001;
    item.state = NSOnState;
    [[art_actionMenu menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Highlight", nil);
    item.tag = -2002;
    [[art_actionMenu menu] addItem:item];
    
    [[art_actionMenu menu] addItem:[NSMenuItem separatorItem]];
    
    for (NSDictionary *defaultArt in art_defaults) {
        if([[defaultArt objectForKey:@"name"] isEqualToString:@"%%sep%%"]) {
            [[art_actionMenu menu] addItem:[NSMenuItem separatorItem]];
        } else {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.title = [defaultArt objectForKey:@"name"];
            item.tag = [art_defaults indexOfObject:defaultArt];
            
            [[art_actionMenu menu] addItem:item];
        }
    }
    
    [[art_actionMenu menu] addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Open File...", nil);
    item.tag = -1000;
    [[art_actionMenu menu] addItem:item];
    
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Shadow", nil);
    item.tag = -2000;
    [[map_options menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Normal", nil);
    item.tag = -2001;
    item.state = NSOnState;
    [[map_options menu] addItem:item];
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Highlight", nil);
    item.tag = -2002;
    [[map_options menu] addItem:item];
    
    [[map_options menu] addItem:[NSMenuItem separatorItem]];
    
    item = [[NSMenuItem alloc] init];
    item.title = NSLocalizedString(@"Open File...", nil);
    item.tag = -1000;
    [[map_options menu] addItem:item];
    
    art_tileViewer.editingModeDisable = YES;
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
                meeper.paletteData = [(NSData *)[defaultPal objectForKey:@"data"] retain];
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
    
    currentView = 0;
    [self updateView];
    
    // re-set art panel
    art_tileViewer.width = 22;
    art_tileViewer.height = ceil(0x20 / art_tileViewer.width);
    
    art_zoomSlider.intValue = 1;
    NSUInteger newZoomLevel = 0;
    [art_scrollView.documentView setFrame:NSMakeRect(0, 0, (art_tileViewer.width * 8) * newZoomLevel, (art_tileViewer.height * 8) * newZoomLevel)];
    [art_tileViewer setZoomFactor:newZoomLevel];
    [art_tileViewer setNeedsDisplay:YES];
    
    [window center];
    [[NSApplication sharedApplication] runModalForWindow:window];
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

#pragma mark art view specific

- (IBAction) art_presetChanged:(id) sender {
    NSInteger selectedPalette = [art_actionMenu selectedItem].tag;
    
    if(selectedPalette <= -2000 && selectedPalette > - 2004) {
        [[[art_actionMenu menu] itemWithTag:-2000] setState:NSOffState];
        [[[art_actionMenu menu] itemWithTag:-2001] setState:NSOffState];
        [[[art_actionMenu menu] itemWithTag:-2002] setState:NSOffState];
        
        
        switch (selectedPalette) {
            case -2000:
                art_tileViewer.paletteState = kSQUMDShadow;
                [[[art_actionMenu menu] itemWithTag:-2000] setState:NSOnState];
                
                break;
                
            case -2001:
                art_tileViewer.paletteState = kSQUMDNormal;
                [[[art_actionMenu menu] itemWithTag:-2001] setState:NSOnState];
                
                break;
                
            case -2002:
                art_tileViewer.paletteState = kSQUMDHighlight;
                [[[art_actionMenu menu] itemWithTag:-2002] setState:NSOnState];
                
                break;
                
            default:
                break;
        }
        
        [art_tileViewer purgeCache];
        [art_tileViewer setNeedsDisplay:YES];
    } else if(selectedPalette >= 0) {
        NSDictionary *theArt = [[art_defaults objectAtIndex:selectedPalette] retain];
        
        NSData *dasData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:[theArt objectForKey:@"filename"] withExtension:@"mdart"]];
        
        art_tileViewer.height = ceil([[theArt objectForKey:@"tiles"] intValue] / art_tileViewer.width) + 1;
        art_origHeight = art_tileViewer.height;
        art_tileViewer.tileData = dasData;
        
        NSUInteger newZoomLevel = [art_zoomSlider integerValue];
        
        [art_scrollView.documentView setFrame:NSMakeRect(0, 0, (art_tileViewer.width * 8) * newZoomLevel, (art_tileViewer.height * 8) * newZoomLevel)];
        [art_tileViewer setZoomFactor:newZoomLevel];
        [art_tileViewer purgeCache];
        [art_tileViewer setNeedsDisplay:YES];
    } else if(selectedPalette <= -1000 && selectedPalette > - 1999) {
        NSOpenPanel *panel;
        
        switch (selectedPalette) {
            case -1000:
                panel = [NSOpenPanel openPanel];
                
                [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
                    if (result == NSFileHandlingPanelOKButton) {
                        NSURL *urlOfFile = [panel URL];
                        
                        art_tileViewer.tileData = [[NSData dataWithContentsOfURL:urlOfFile] retain];
                        NSUInteger numTiles = ceil(art_tileViewer.tileData.length / 0x20);
                        
                        art_tileViewer.height = ceil(numTiles / art_tileViewer.width) + 1;
                        art_origHeight = art_tileViewer.height;
                        
                        [art_scrollView.documentView setFrame:NSMakeRect(0, 0, (art_tileViewer.width * 8) * 1, (art_tileViewer.height * 8) * 1)];
                        [art_tileViewer setZoomFactor:1];
                        [art_tileViewer purgeCache];
                        [art_tileViewer setNeedsDisplay:YES];
                    }
                }];
                
                break;
                
            default:
                break;
        }        
    }
}

- (IBAction) art_zoomSliderChanged:(id) sender {    
    NSUInteger newZoomLevel = [art_zoomChooser selectedSegment];
    NSLog(@"New tiles zoom level: %u", newZoomLevel);
    
    //144px viewable area
    //float zoomFactorMap[0x08] = {1.0f, 2.0f, 3.0f, 4.1f, 5.1f, 6.0f, 7.2f, 8.1f};
    float zoomFactorMap[0x03] = {1.0f, 2.0f, 4.0f};
    unsigned short tilesPerLineForZoom[0x03] = {24, 12, 8};
    float zoomFactor = zoomFactorMap[(newZoomLevel)];
    
    art_tileViewer.width = tilesPerLineForZoom[(newZoomLevel)];
    NSUInteger newHeight = art_origHeight * zoomFactor;
    NSLog(@"New height: %i", newHeight);
    
    art_tileViewer.height = newHeight;
    
    [art_scrollView.documentView setFrame:NSMakeRect(0, 0, [art_scrollView.documentView frame].size.width, (art_tileViewer.height * 8) * zoomFactor)];
    [art_tileViewer setZoomFactor:zoomFactor];
    [art_tileViewer purgeCache];
    [art_tileViewer setNeedsDisplay:YES];
}

#pragma mark Map pane

- (IBAction) map_sizeChanged:(id) sender {
    NSLog(@"Changing to width %i, height %i", map_width.integerValue, map_height.integerValue);
    
    map_viewinator.width = map_width.integerValue;
    map_viewinator.height = map_height.integerValue;
    
    map_height2.integerValue = map_height.integerValue;
    map_width2.integerValue = map_width.integerValue;
    
    
    [map_scrollView.documentView setFrame:NSMakeRect(0, 0, (map_viewinator.width * 8), (map_viewinator.height * 8))];
    [map_viewinator purgeCache];
    [map_viewinator setNeedsDisplay:YES];
}

- (IBAction) map_optionSelected:(id) sender {
    NSInteger selectedPalette = [map_options selectedItem].tag;
    
    if(selectedPalette >= 0) {
        
    } else if(selectedPalette <= -2000 && selectedPalette > - 2004) {
        [[[map_options menu] itemWithTag:-2000] setState:NSOffState];
        [[[map_options menu] itemWithTag:-2001] setState:NSOffState];
        [[[map_options menu] itemWithTag:-2002] setState:NSOffState];
        
        
        switch (selectedPalette) {
            case -2000:
                map_viewinator.paletteState = kSQUMDShadow;
                [[[map_options menu] itemWithTag:-2000] setState:NSOnState];
                
                break;
                
            case -2001:
                map_viewinator.paletteState = kSQUMDNormal;
                [[[map_options menu] itemWithTag:-2001] setState:NSOnState];
                
                break;
                
            case -2002:
                map_viewinator.paletteState = kSQUMDHighlight;
                [[[map_options menu] itemWithTag:-2002] setState:NSOnState];
                
                break;
                
            default:
                break;
        }
        
        [map_viewinator purgeCache];
        [map_viewinator setNeedsDisplay:YES];
    } else if(selectedPalette < 0 && selectedPalette >= -1000) {
        NSOpenPanel *panel;
        
        switch (selectedPalette) {
            case -1000:
                panel = [NSOpenPanel openPanel];
                
                [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
                    if (result == NSFileHandlingPanelOKButton) {
                        NSURL *urlOfFile = [panel URL];
                        
                        map_viewinator.mappingData = [NSData dataWithContentsOfURL:urlOfFile];
                        
                        [map_viewinator purgeCache];
                        [map_viewinator setNeedsDisplay:YES];
                    }
                }];
                
                break;
                
            default:
                break;
        }
    }    
}

#pragma mark View Exchanging

- (IBAction) nextView:(id)sender {
    if(currentView < 2) {
        currentView++;
        [self updateView];
        [window doCGAnimation:CGSCube andOption:0x01 withDuration:1.0 fullScreen:NO];
    } else {
        NSSavePanel *saveProjectPanel = [NSSavePanel savePanel];
        saveProjectPanel.allowedFileTypes = [NSArray arrayWithObject:@"nameproj"];
        
        [saveProjectPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
            if(result == NSFileHandlingPanelOKButton) {
                NSURL *urlOfFile = [saveProjectPanel URL];
                
                NSError *err = nil;
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
                [dict setObject:[NSNumber numberWithInteger:map_width.integerValue] forKey:@"width"];
                [dict setObject:[NSNumber numberWithInteger:map_height.integerValue] forKey:@"height"];
                [dict setObject:[NSDate new] forKey:@"date"];
                
                NSMutableData *data = [[NSMutableData alloc]init];
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
                [archiver encodeObject:[NSNumber numberWithFloat:1.0] forKey:@"format"];
                [archiver encodeObject:dict forKey: @"infoDict"];
                [archiver encodeObject:map_viewinator.paletteData forKey:@"palette"];
                [archiver encodeObject:map_viewinator.tileData forKey:@"art"];
                [archiver encodeObject:map_viewinator.mappingData forKey:@"map"];
                [archiver finishEncoding];
                
                [data writeToURL:urlOfFile atomically:YES];
                
                if(err) {
                    [[NSAlert alertWithError:err] beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                } else {
                    [self cancelNew:sender];
                    
                    [[NSWorkspace sharedWorkspace] openURL:urlOfFile];
                }
            }
        }];
        
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
            art_tileViewer.paletteData = pal_palView.paletteData;
            art_scrollView.backgroundColor = [pal_palView transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption];
            art_zoomChooser.selectedSegment = 0;
            [self art_zoomSliderChanged:nil];
            
            currentPaneTitle.stringValue = NSLocalizedString(@"Art Tiles", nil);
            
            view_art.frame = NSMakeRect(0, 0, 560, 300);
            [magicalContainer addSubview:view_art];
            break;
        case 2:
            map_viewinator.tileData = art_tileViewer.tileData;
            map_viewinator.paletteData = art_tileViewer.paletteData;
            map_viewinator.mappingData = art_tileViewer.mappingData;
            map_scrollView.backgroundColor = [pal_palView transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption];
            
            map_viewinator.width = 8;
            map_viewinator.height = 8;
            map_height.integerValue = 8;
            map_height2.integerValue = 8;
            map_width.integerValue = 8;
            map_width2.integerValue = 8;
            
            [map_scrollView.documentView setFrame:NSMakeRect(0, 0, (map_viewinator.width * 8), (map_viewinator.height * 8))];
            [map_viewinator purgeCache];
            [map_viewinator setNeedsDisplay:YES];
            
            currentPaneTitle.stringValue = NSLocalizedString(@"Nametable", nil);
            
            view_map.frame = NSMakeRect(0, 0, 560, 300);
            [magicalContainer addSubview:view_map];
            
            [nextBtn setTitle:NSLocalizedString(@"Finish", nil)];
            break;
            
        default:
            NSLog(@"Invalid view number %u", currentView);
            break;
    }
}

- (IBAction) cancelNew:(id)sender {
    [window orderOut:sender];
    
    currentView = 0;
    [self updateView];
    
    [[NSApplication sharedApplication] abortModal];
}

- (void) windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] abortModal];
}

@end
