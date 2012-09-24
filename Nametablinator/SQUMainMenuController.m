//
//  SQUMainMenuController.m
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMainMenuController.h"

@implementation SQUMainMenuController 

- (IBAction) createNewFile:(id) sender {
    if(!newProjCtrlr) {
        newProjCtrlr = [[[SQUNewProjectController alloc] init] retain];
        if(![NSBundle loadNibNamed:@"SQUNewProjectController" owner:newProjCtrlr]) {
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Can't Load New Project UI", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The NIB file could not be loaded for some reason. Please re-install the application.", nil)] runModal];
            newProjCtrlr = nil;
            return;
        }
    }
    
    [newProjCtrlr openNewProjWindow];
}

- (IBAction) showPrefCtrlr:(id) sender {
    if(!prefCtrlr) {
        prefCtrlr = [[[SQUPreferenceController alloc] init] retain];
        
        if(![NSBundle loadNibNamed:@"SQUPreferenceController" owner:prefCtrlr]) {
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Can't Load Preferences UI", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The NIB file could not be loaded for some reason. Please re-install the application.", nil)] runModal];
            newProjCtrlr = nil;
            return;
        }
    }
    
    [prefCtrlr showPreferences:sender];
}

- (IBAction) showImportController:(id) sender {
    if(!importController) {
        importController = [[[SQUImportImageController alloc] initWithWindowNibName:@"SQUImportImageController"] retain];
        
        if(!importController) {
            [[NSAlert alertWithMessageText:NSLocalizedString(@"Can't Load Image Importing UI", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The NIB file could not be loaded for some reason. Please re-install the application.", nil)] runModal];
            return;
        }
    }
    
    [importController showImageImporter];
}

@end
