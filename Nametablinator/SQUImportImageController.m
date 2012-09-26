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
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *urlOfFile = [panel URL];
            
            [loading_bar setIndeterminate:YES];
            [loading_bar setDoubleValue:0.0];
            [loading_bar startAnimation:sender];
            [loading_bold setStringValue:NSLocalizedString(@"Reading Image Data...", nil)];
            [loading_desc setStringValue:@""];
            [loading_cancel setEnabled:NO];
            
            [loading_bar setUsesThreadedAnimation:YES];
            
            //[[NSApplication sharedApplication] beginSheet:loading_panel modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
            
            dispatch_async(processingQueue, ^{
                CGImageRef ref = SQU_CGImageCreateWithNSImage([[NSImage alloc] initWithContentsOfURL:urlOfFile]);
                
                sleep(1);
                
                [loading_desc setStringValue:NSLocalizedString(@"Applying Dithering", nil)];
                
                CGImageRef resultinator = [defaultDitherer ditherImageTo16Colours:ref withDitheringMatrixType:kSQUBayer117];
                
                [loading_bar setDoubleValue:100.0];
                
                imgView.image = [[NSImage alloc] initWithCGImage:resultinator size:NSMakeSize(CGImageGetWidth(ref), CGImageGetHeight(ref))];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[[NSApplication sharedApplication] endSheet:loading_panel returnCode:0]; 
                    [loading_panel orderOut:self];
                });
            });
        }
    }];
    
    
}

CGImageRef SQU_CGImageCreateWithNSImage(NSImage *image) {
    NSSize imageSize = [image size];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapContext flipped:NO]];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
}

@end
