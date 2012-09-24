//
//  SQUMainMenuController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SQUNewProjectController.h"
#import "SQUPreferenceController.h"
#import "SQUImportImageController.h"

@interface SQUMainMenuController : NSObject {
    SQUNewProjectController *newProjCtrlr;
    SQUPreferenceController *prefCtrlr;
    SQUImportImageController *importController;
}

- (IBAction) createNewFile:(id) sender;
- (IBAction) showPrefCtrlr:(id) sender;
- (IBAction) showImportController:(id) sender;

@end
