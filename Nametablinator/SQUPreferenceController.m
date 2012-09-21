//
//  SQUPreferenceController.m
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUPreferenceController.h"

#define TOOLBAR_GENERAL     @"TOOLBAR_GENERAL"
#define TOOLBAR_APPEARANCE	@"TOOLBAR_APPEARANCE"
#define TOOLBAR_UPDATES		@"TOOLBAR_UPDATES"
#define TOOLBAR_ADVANCED    @"TOOLBAR_ADVANCED"

@implementation SQUPreferenceController

- (void) awakeFromNib {
	@try {
		[window setDelegate:self];
	}
	@catch (NSException * e) {
		NSLog(@"We can't do window delegates.");
	}
	
	NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier: @"Preferences Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    [toolbar setSelectedItemIdentifier: TOOLBAR_GENERAL];
    [window setToolbar: toolbar];
    [toolbar release];
    
    [self setPrefView: nil];
}

- (IBAction) showPreferences:(id) sender {
	[window center];
	[window makeKeyAndOrderFront:sender];
}

- (void)windowWillClose:(NSNotification *)notification {
    
}

// pref window googags

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) ident willBeInsertedIntoToolbar: (BOOL) flag {
    NSToolbarItem * item = [[NSToolbarItem alloc] initWithItemIdentifier: ident];
	
    if ([ident isEqualToString: TOOLBAR_GENERAL]) {
        [item setLabel: NSLocalizedString(@"General", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed:NSImageNamePreferencesGeneral]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    } else if ([ident isEqualToString: TOOLBAR_APPEARANCE]) {
        [item setLabel: NSLocalizedString(@"Appearance", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: NSImageNameFontPanel]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    } else if ([ident isEqualToString:TOOLBAR_UPDATES]) {
        [item setLabel: NSLocalizedString(@"Updates", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed:@"prefs-update"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    } else if ([ident isEqualToString:TOOLBAR_ADVANCED]) {
        [item setLabel: NSLocalizedString(@"Advanced", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed:NSImageNameAdvanced]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    } else {
        [item release];
        return nil;
    }
	
    return [item autorelease];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects: TOOLBAR_GENERAL, TOOLBAR_APPEARANCE, TOOLBAR_UPDATES, TOOLBAR_ADVANCED, nil];
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar {
    return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (void) setPrefView: (id) sender {
    NSString * identifier;
    if (sender)
    {
        identifier = [sender itemIdentifier];
        [[NSUserDefaults standardUserDefaults] setObject: identifier forKey: @"SelectedPrefView"];
    }
    else
        identifier = [[NSUserDefaults standardUserDefaults] stringForKey: @"SelectedPrefView"];
    
    NSView * view;
    /*if ([identifier isEqualToString: TOOLBAR_GENERAL])
     view = fGeneral;*/
    if ([identifier isEqualToString: TOOLBAR_APPEARANCE]) {
        view = fAppearance;
	}else if ([identifier isEqualToString: TOOLBAR_ADVANCED]) {
        view = fAdvanced;
    } else if ([identifier isEqualToString: TOOLBAR_UPDATES]) {
        view = fUpdates;
	} else {
        identifier = TOOLBAR_GENERAL; //general view is the default selected
        view = fGeneral;
    }
    
    [[window toolbar] setSelectedItemIdentifier: identifier];
    
    //NSWindow * window = [self window];
    if ([window contentView] == view)
        return;
    
    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
	windowRect.size.width = [view frame].size.width;
	//windowRect.origin.x = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    
    [view setHidden: YES];
    [window setContentView: view];
    [window setFrame: windowRect display: YES animate: YES];
    [view setHidden: NO];
    
    //set title label
    if (sender) {
        [window setTitle: [sender label]];
	} else {
        NSToolbar * toolbar = [window toolbar];
        NSString * itemIdentifier = [toolbar selectedItemIdentifier];
        for (NSToolbarItem * item in [toolbar items]) {
            if ([[item itemIdentifier] isEqualToString: itemIdentifier]) {
                [window setTitle: [item label]];
                break;
            }
		}
    }
}



@end
