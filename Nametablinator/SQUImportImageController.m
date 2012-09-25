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
    processingQueue = dispatch_queue_create("co.squee.nametablinator.importQueue", NULL);
    
    defaultDitherer = [[[SQUImageDitherer alloc] init] retain];
}

- (void) showImageImporter {
    [self.window center];
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}

- (void) windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] abortModal];
}

- (IBAction) loading_cancel:(id)sender {
    
}

- (IBAction) cancelImport:(id) sender {
    [[NSApplication sharedApplication] abortModal];
    [self.window orderOut:sender];
}

- (IBAction) goImport:(id) sender {
    
}

- (IBAction) selectDifferentImage:(id) sender {
    [loading_bar setIndeterminate:YES];
    [loading_bar setDoubleValue:0.0];
    [loading_bar startAnimation:sender];
    [loading_bold setStringValue:NSLocalizedString(@"Reading Image Data...", nil)];
    [loading_desc setStringValue:@""];
    [loading_cancel setEnabled:NO];
    
    [loading_bar setUsesThreadedAnimation:YES];
    
    [[NSApplication sharedApplication] beginSheet:loading_panel modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    dispatch_async(processingQueue, ^{
        sleep(1);
        
        [loading_bold setStringValue:NSLocalizedString(@"Processing Image Data...", nil)];
        [loading_desc setStringValue:NSLocalizedString(@"Padding image...", nil)];
        [loading_cancel setEnabled:YES];
        
        [loading_bar setIndeterminate:NO];
        
        usleep(1000 * 100);
        
        [loading_desc setStringValue:NSLocalizedString(@"Quantatising image to MD colours", nil)];
        
        for (int i = 0; i < 50; i++) {
            usleep(1000 * 5);
            [loading_bar incrementBy:0.5];
        }
        
        [loading_desc setStringValue:NSLocalizedString(@"Configuring Dithering", nil)];
        
        sleep(2);
        
        [loading_desc setStringValue:NSLocalizedString(@"Applying Dithering", nil)];
        
        for (int i = 0; i < 75; i++) {
            usleep(1000 * 15);
            [loading_bar incrementBy:0.5];
        }
        
        sleep(1);
        
        [loading_desc setStringValue:NSLocalizedString(@"Converting to MD tile data", nil)];
        
        for (int i = 0; i < 75; i++) {
            usleep(1000 * 10);
            [loading_bar incrementBy:0.5];
        }
        
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSApplication sharedApplication] endSheet:loading_panel returnCode:0]; 
            [loading_panel orderOut:self];
        });
    });
}

@end
