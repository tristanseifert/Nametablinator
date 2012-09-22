//
//  InstallAssistant.m
//  Demo
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

#import "InstallAssistant.h"
#import "Common.h"

@implementation InstallAssistant
- (NSArray *)orderedSteps
{
	return [NSArray arrayWithObject:@"Install"];
}

- (void)start
{
	[[controller prevButton] setEnabled:NO];
	[[controller nextButton] setEnabled:NO];
	[[controller nextButton] setTitle:@"Finish"];
	[progressBar startAnimation:self];
	[textField setStringValue:@"Installing... (don't worry, not actually don't anything)"];
	[self performSelector:@selector(done) withObject:nil afterDelay:2];
}

- (void)done
{
	[progressBar stopAnimation:self];
	[progressBar setIndeterminate:NO];
	[progressBar setDoubleValue:100];
	[textField setStringValue:@"Done!"];
	[[controller nextButton] setEnabled:YES];
}

@end
