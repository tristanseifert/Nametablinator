//
//  NSWindow+NSWindow_SQUCGSPrivateEffects.m
//  Nametablinator
//
//  Created by Tristan Seifert on 21/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "NSWindow+NSWindow_SQUCGSPrivateEffects.h"

@implementation NSWindow (NSWindow_SQUCGSPrivateEffects)

- (void) doCGAnimation:(CGSTransitionType) anim andOption:(CGSTransitionOption) opts withDuration: (float) duration fullScreen: (BOOL) fullScreen {
    [self.contentView setNeedsDisplay:YES];
    
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    
    CGEventFlags flags = (kCGEventFlagMaskShift);
    
    if((modifiers & flags) == flags) {
        duration = duration * 5;
    }
    
    CGSTransitionSpec spec;
    CGSTransitionHandle transitionHandle;
    CGSConnection cid = CGSDefaultConnection;
    
    spec.type = anim;
    spec.option = 0x80 | opts;
    spec.wid = (fullScreen  ? 0 : [self windowNumber]);
    spec.backColor = nil;
    
    transitionHandle = -1;
    CGSNewTransition(cid, &spec, &transitionHandle);
    CGSInvokeTransition(cid, transitionHandle, duration);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: duration]];
    CGSReleaseTransition(cid, transitionHandle);
}

@end
