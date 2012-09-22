//
//  TEInstallStepView.h
//
//  Copyright (c) 2010 Tao Effect LLC
// 	
//  You are free to use this software and associated materials
//  (the "Software") however you like so long as you:
// 	
//  1) Provide attribution to the original author and include
//     a hyperlink to original website of the Software in any
//     application using the Software.
//  2) Include the above copyright notice and this agreement in
//     all copies or substantial portions of the Software.
// 	
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Cocoa/Cocoa.h>
#import "TEInstallStepCell.h"
#import "Common.h"

@interface TEInstallStepView : NSView {
	NSArray *steps;
	NSString *currentStep;
	
	TEInstallStepCell *cell;
	
	CGFloat calculatedSpacing;
	CGFloat cellHeight;
    
    CGFloat desiredSpacing;
    CGFloat verticalTextOffset;
    NSImage *prevStepImg;
    NSImage *currStepImg;
    NSImage *nextStepImg;
    NSDictionary *prevStepTextAttrs;
    NSDictionary *currStepTextAttrs;
    NSDictionary *nextStepTextAttrs;
}

@property (nonatomic, readonly) CGFloat desiredSpacing;
@property (nonatomic) CGFloat verticalTextOffset;
@property (nonatomic, strong) NSImage *prevStepImg;
@property (nonatomic, strong) NSImage *currStepImg;
@property (nonatomic, strong) NSImage *nextStepImg;
@property (nonatomic, strong) NSDictionary *prevStepTextAttrs;
@property (nonatomic, strong) NSDictionary *currStepTextAttrs;
@property (nonatomic, strong) NSDictionary *nextStepTextAttrs;

- (void)clearSteps;
- (void)setSteps:(NSArray *)theSteps;
- (OSStatus)selectStep:(NSString *)stepName;
- (NSString*)currentStep;

@end
