//
//  SQUDocument.m
//  Nametablinator
//
//  Created by Tristan Seifert on 09/09/2012.
//  Copyright (c) 2012 Tristan Seifert. All rights reserved.
//

#import "SQUDocument.h"

@implementation SQUDocument

- (id)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SQUDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    SQUHexadecimalFormatter *formatter = [[SQUHexadecimalFormatter alloc] init];
    [info_tileOffset setFormatter:formatter];
    
    [zoomSlider setIndicatorIndex:2];
    
    [NSRulerView registerUnitWithName:@"pixels" abbreviation:@"px" unitToPointsConversionFactor:1.0 stepUpCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:2.0f]] stepDownCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:0.1f]]];
    
    [mainScroller setHasHorizontalRuler:YES];
    [mainScroller setHasVerticalRuler:YES];
    
    [mainScroller.horizontalRulerView setMeasurementUnits:@"pixels"];
    [mainScroller.verticalRulerView setMeasurementUnits:@"pixels"];
    
    [mainScroller setRulersVisible:YES];
    
    NSPoint zero = [mainScroller.documentView convertPoint:[mainView bounds].origin fromView:mainView];
    [mainScroller.horizontalRulerView setOriginOffset:zero.x - [mainScroller.documentView bounds].origin.x];
    
    info_tileListScroll.backgroundColor = [palette transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption];
    info_tileList.tileData = palette.paletteData;
    info_tileList.paletteData = palette.paletteData;
    
    NSMutableData *artTileViewMap = [[NSMutableData alloc] initWithCapacity:0x800 * 0x2];
    
    unsigned short *array = NULL;
    
    for(int i = 0; i < 0x800; i++) {
        unsigned short currentSphere[0x1] = {swap_uint16(i)};
        array = currentSphere;
        [artTileViewMap appendBytes:(const char*)array length:0x2];
    }
    
    info_tileList.editingModeDisable = YES;
    info_tileList.mappingData = [artTileViewMap retain];
    info_tileList.width = 23;
    info_tileList.height = ceil(0x7FF / info_tileList.width);
    
    [inspectorContainer addInspectorView:sizeInspector expanded:YES];
    [inspectorContainer addInspectorView:mapInspector expanded:YES];
    [inspectorContainer addInspectorView:listOfTilesInspector expanded:YES];
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
    
    [dict2 setObject:[NSNumber numberWithInteger:mainView.width] forKey:@"width"];
    [dict2 setObject:[NSNumber numberWithInteger:mainView.height] forKey:@"height"];
    [dict2 setObject:[NSDate new] forKey:@"lastModified"];
    
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:[NSNumber numberWithFloat:1.0] forKey:@"format"];
    [archiver encodeObject:dict2 forKey: @"infoDict"];
    [archiver encodeObject:mainView.paletteData forKey:@"palette"];
    [archiver encodeObject:mainView.tileData forKey:@"art"];
    [archiver encodeObject:mainView.mappingData forKey:@"map"];
    [archiver finishEncoding];
    
    hasChanged = NO;
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];

    dict = [[unarchiver decodeObjectForKey:@"infoDict"] retain];
    
    doc_art = [[unarchiver decodeObjectForKey:@"art"] retain];
    doc_map = [[unarchiver decodeObjectForKey:@"map"] retain];
    doc_palDat = [[unarchiver decodeObjectForKey:@"palette"] retain];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    [self performSelector:@selector(loadMeeper) withObject:nil afterDelay:0.1];
    
    hasChanged = NO;
    
    return YES;
}

- (void) loadMeeper {    
    mainView.tileData = [doc_art retain];
    mainView.mappingData = [doc_map retain];
    mainView.paletteData = [doc_palDat retain];
    
    palette.paletteData = mainView.paletteData;
    
    info_tileList.paletteData = [mainView.paletteData retain];
    info_tileList.tileData = [mainView.tileData retain];
    
    [info_tileList purgeCache];
    [info_tileList setNeedsDisplay:YES];
    [info_tileList setZoomFactor:2.0f];
    [info_tileListScroll.documentView setFrame:NSMakeRect(0, 0, (info_tileList.width * 16), (info_tileList.height * 16))];
    info_tileListScroll.backgroundColor = [palette transparentColourForCurrentPaletteLineRegardlessOfCheckerboardUserUIOption];
    
    info_tileList.width = 10;
    info_tileList.height = ceil(0x7FF / info_tileList.width);
    
    mainView.width = [[dict objectForKey:@"width"] integerValue];
    mainView.height = [[dict objectForKey:@"height"] integerValue];
    
    [mainView purgeCache];
    [palette setNeedsDisplay:YES];
    [mainView setNeedsDisplay:YES];
    [mainScroller.documentView setFrame:NSMakeRect(0, 0, (mainView.width * 8) * round(zoomSlider.floatValue), (mainView.height * 8) * round(zoomSlider.floatValue))];
    mainScroller.backgroundColor = [palette transparentColourForCurrentPaletteLine];
    
    info_width.stringValue = [NSString stringWithFormat:@"%li tiles", mainView.width];
    info_height.stringValue = [NSString stringWithFormat:@"%li tiles", mainView.height];
}

/*- (BOOL)isDocumentEdited {
    return hasChanged;
}*/

- (IBAction) palViewer_shadowHighlight:(id) sender {
    NSInteger selectedItem = [palViewer_actionBtn selectedItem].tag;
    
    switch (selectedItem) {
        case 1:
            [palette setPaletteState:kSQUMDShadow];
            break;
            
        case 2:
            [palette setPaletteState:kSQUMDNormal];
            break;
            
        case 3:
            [palette setPaletteState:kSQUMDHighlight];
            break;
            
        case 10:
            palette.paletteLine = 0;
            break;
        case 11:
            palette.paletteLine = 1;            
            break;
        case 12:
            palette.paletteLine = 2;            
            break;
        case 13:
            palette.paletteLine = 3;
            break;
            
        default:
            break;
    }
    
    mainView.paletteState = palette.paletteState;
    info_tileList.paletteState = palette.paletteState;
    
    mainScroller.backgroundColor = [palette transparentColourForCurrentPaletteLine];
    info_tileListScroll.backgroundColor = [palette transparentColourForCurrentPaletteLine];
    
    [palette setNeedsDisplay:YES];
    [mainView purgeCache];
    [info_tileList purgeCache];
    
//    [mainView renderImageForTile:0xB020]; // Tile 0x20, priority, palette 0x01, vertical flip
}

#pragma mark Resize inspector 
- (IBAction) inspector_resize_reopenWSize:(id) sender {
    
}

- (IBAction) inspector_resize_resizeMap:(id) sender {
    
}

#pragma mark Split View delegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    NSView* rightView = [[splitView subviews] objectAtIndex:1];
    return ([subview isEqual:rightView]);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    NSView* rightView = [[splitView subviews] objectAtIndex:1];
    return ([subview isEqual:rightView]);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    return self.windowForSheet.frame.size.width - 180;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    return self.windowForSheet.frame.size.width - 250;    
}

- (void)splitViewWillResizeSubviews:(NSNotification *)aNotification {
    [mainScroller.documentView setFrame:NSMakeRect(0, 0, (mainView.width * 8) * round(zoomSlider.floatValue), (mainView.height * 8) * round(zoomSlider.floatValue))];    
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    NSView* rightView = [[splitView subviews] objectAtIndex:1];
    
    if([subview isEqual:rightView]) {
        return !liveResizeInProgress;
    }
    
    return YES;
}

- (void) splitViewDidResizeSubviews:(NSNotification *)notification {
    NSView* rightView = [[mainSplitView subviews] objectAtIndex:1];
    NSUInteger width = rightView.frame.size.width;
    
    info_tileList.width = floor((width - 15) / 16.0f);
    info_tileList.height = ceil(0x7FF / info_tileList.width);
    
    [info_tileList purgeCache];
    [info_tileList setNeedsDisplay:YES];
}

#pragma mark Zoom support

- (IBAction) doZoomSliderAction:(id) sender {    
    [NSRulerView registerUnitWithName:@"pixels" abbreviation:@"px" unitToPointsConversionFactor:(1.0f * round(zoomSlider.floatValue)) stepUpCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:2.0f]] stepDownCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:0.1f]]];
    [mainScroller.horizontalRulerView setMeasurementUnits:@"pixels"];
    [mainScroller.verticalRulerView setMeasurementUnits:@"pixels"];
    
    [mainScroller.documentView setFrame:NSMakeRect(0, 0, (mainView.width * 8) * round(zoomSlider.floatValue), (mainView.height * 8) * round(zoomSlider.floatValue))];
    [mainView setZoomFactor:round(zoomSlider.floatValue)];
    
    palette.zoomFactor = round(zoomSlider.floatValue);
    mainScroller.backgroundColor = [palette transparentColourForCurrentPaletteLine];
}

#pragma mark window delegate

- (void)windowDidResize:(NSNotification *)notification {
    [mainScroller.documentView setFrame:NSMakeRect(0, 0, (mainView.width * 8) * round(zoomSlider.floatValue), (mainView.height * 8) * round(zoomSlider.floatValue))];
}

- (void)windowWillStartLiveResize:(NSNotification *)notification {
    liveResizeInProgress = YES;
}

- (void)windowDidEndLiveResize:(NSNotification *)notification {
    liveResizeInProgress = NO;
}

#pragma mark Exporting 'n shit

- (IBAction) exportDocument:(id) sender {
    if(!exportPanel) {
        exportPanel = [[NSSavePanel savePanel] retain];
    }
    
    exportPanel.allowedFileTypes = [NSArray arrayWithObjects:@"png", @"jpg", @"tiff", @"gif", nil];
    exportPanel.accessoryView = export_accessory;
    exportPanel.canSelectHiddenExtension = NO;
    
    [exportPanel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            CFURLRef url = (CFURLRef) [exportPanel URL];
            
            CGImageRef imageRef;
            CGImageDestinationRef dest;
            
            if([export_size selectedTag] == 0) {
                imageRef = CGBitmapContextCreateImage(mainView.prevBitmapContext);
            } else if([export_size selectedTag] == 1) {
                imageRef = CGBitmapContextCreateImage(mainView.prevScaledBitmapContext);
            }
            
            switch ([export_type indexOfSelectedItem]) {
                case 0:
                    dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
                    break;
                    
                case 1:
                    dest = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
                    break;
                    
                case 2:
                    dest = CGImageDestinationCreateWithURL(url, kUTTypeTIFF, 1, NULL);
                    break;
                    
                case 3:
                    dest = CGImageDestinationCreateWithURL(url, kUTTypeGIF, 1, NULL);
                    break;
                    
                default:
                    break;
            }
            
            NSDictionary *extraInfo = nil;
            
            if([export_type indexOfSelectedItem] == 1) {
                extraInfo = [NSDictionary dictionaryWithObject:(NSString *) kCGImageDestinationLossyCompressionQuality forKey:[NSNumber numberWithFloat:(export_quality.floatValue / 100)]];
            }
            
            CGImageDestinationAddImage(dest, imageRef, (CFDictionaryRef) extraInfo);
            
            if (!CGImageDestinationFinalize(dest)) {
                NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Can't Save File", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The image could not be saved to the specified location due to an unknown error. Check that the destination is writable and has free space, then try again.", nil)];
                [alert beginSheetModalForWindow:self.windowForSheet modalDelegate:nil didEndSelector:nil contextInfo:nil];
            }
            
            CFRelease(dest);
        }
    }];
}

- (IBAction) export_typeChanged:(id) sender {
    if([export_type indexOfSelectedItem] == 1) {
        [export_quality setEnabled:YES];
    } else {
        [export_quality setEnabled:NO];
    }
    
    NSArray *extensions = [NSArray arrayWithObjects:@"png", @"jpg", @"tiff", @"gif", nil];
    [exportPanel setRequiredFileType:[extensions objectAtIndex:[export_type indexOfSelectedItem]]];
}

#pragma mark Tile view delegate 

- (void) tileRenderViewMapDidChange:(SQUMDTileRenderView *)renderView {
    hasChanged = YES;
    [self updateChangeCount:NSChangeDone]; // increment change count, mark document dirty
}

- (void) tileRenderView:(SQUMDTileRenderView *)view tileIndexWasSelected:(NSUInteger)idx {
    mainView.currentlyPlacingTile = idx;
    
    [self.windowForSheet makeFirstResponder:mainView];
}

#pragma mark Palette view delegate

- (void) paletteViewPaletteDidChange:(SQUPaletteRenderView *) view {
    hasChanged = YES;
    [self updateChangeCount:NSChangeDone]; // increment change count, mark document dirty
    
    mainView.paletteData = palette.paletteData;
    [mainView purgeCache];
    [mainView setNeedsDisplay:YES];
}

@end
