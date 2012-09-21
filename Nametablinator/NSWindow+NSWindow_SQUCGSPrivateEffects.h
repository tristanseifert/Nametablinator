//
//  NSWindow+NSWindow_SQUCGSPrivateEffects.h
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CGSPrivate.h"

@interface NSWindow (NSWindow_SQUCGSPrivateEffects)

- (void) doCGAnimation:(CGSTransitionType) anim andOption:(CGSTransitionOption) opts withDuration: (float) duration fullScreen: (BOOL) fullScreen;

@end
