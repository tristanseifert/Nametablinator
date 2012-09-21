//
//  SQUPreferenceController.h
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQUPreferenceController : NSObject <NSWindowDelegate, NSToolbarDelegate> {
    IBOutlet NSWindow *window;
    
	IBOutlet NSView *fGeneral;
	IBOutlet NSView *fAppearance;
	IBOutlet NSView *fUpdates; 
	IBOutlet NSView *fAdvanced;   
}

- (IBAction) showPreferences:(id) sender;

- (void) setPrefView: (id) sender;

@end
