//
//  SQUMainMenuController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SQUNewProjectController.h"

@interface SQUMainMenuController : NSObject {
    SQUNewProjectController *newProjCtrlr;
}

- (IBAction) createNewFile:(id)sender;

@end
