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
    [inspectorContainer addInspectorView:sizeInspector expanded:YES];
    [inspectorContainer addInspectorView:mapInspector expanded:YES];
    [inspectorContainer addInspectorView:listOfTilesInspector expanded:YES];
    
    SQUHexadecimalFormatter *formatter = [[SQUHexadecimalFormatter alloc] init];
    [info_tileOffset setFormatter:formatter];
    
    mainScroller.backgroundColor = [palette transparentColourForCurrentPaletteLine];
    
    [zoomSlider setIndicatorIndex:2];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return YES;
}

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
    
    mainScroller.backgroundColor = [palette transparentColourForCurrentPaletteLine];
    
    [palette setNeedsDisplay:YES];
    [mainView purgeCache];
    
//    [mainView renderImageForTile:0xB020]; // Tile 0x20, priority, palette 0x01, vertical flip
}

- (void) awakeFromNib {
    mainView.tileData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/BeachArt.bin"];
    mainView.mappingData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/BeachMap.bin"];
    mainView.paletteData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/BeachPal.bin"];
    //mainView.tileData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/Test2_Art.bin"];
//    mainView.mappingData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/Test2_Map.bin"];
//    mainView.paletteData = [NSData dataWithContentsOfFile:@"/Users/tristanseifert/Nametablinator/Test Files/Test2_Pal.bin"];
    
    //unsigned char defaultPalette[0x20] = SQUDefaultMDPalette;
    //mainView.paletteData = [[NSData dataWithBytes:defaultPalette length:0x20] retain];
    
    //mainView.height = 0x18;
    //mainView.width = 0x20;
//    mainView.tileOffset = 0x00ED;
    
    mainView.height = 22;
    mainView.width = 64;
    
    palette.paletteData = [mainView.paletteData copy];
    
    [palette setNeedsDisplay:YES];
    [mainView setNeedsDisplay:YES];
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

#pragma mark Zoom support

- (IBAction) doZoomSliderAction:(id) sender {
    NSLog(@"Current zoom factor: %f", round(zoomSlider.floatValue));
    
    [mainScroller.documentView setFrame:NSMakeRect(0, 0, (mainView.width * 8) * round(zoomSlider.floatValue), (mainView.height * 8) * round(zoomSlider.floatValue))];
    [mainView setZoomFactor:round(zoomSlider.floatValue)];
}

@end
