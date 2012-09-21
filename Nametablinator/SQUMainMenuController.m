//
//  SQUMainMenuController.m
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUMainMenuController.h"

@implementation SQUMainMenuController 

- (IBAction) createNewFile:(id)sender {
    if(!newProjCtrlr) {
        newProjCtrlr = [[[SQUNewProjectController alloc] init] retain];
        [NSBundle loadNibNamed:@"SQUNewProjectController" owner:newProjCtrlr];
    }
    
    [newProjCtrlr openNewProjWindow];
}

@end
