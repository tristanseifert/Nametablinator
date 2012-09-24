//
//  SQUImportImageController.m
//  Nametablinator
//
//  Created by Tristan Seifert on 24/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUImportImageController.h"

@implementation SQUImportImageController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.delegate = self;
}

- (void) showImageImporter {
    [self.window center];
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}

- (void) windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] abortModal];
}

@end
