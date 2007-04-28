/* PreferencesManager */

#import <Cocoa/Cocoa.h>

@interface PreferencesManager : NSWindowController
{
    IBOutlet NSPopUpButton *color;
	IBOutlet NSButton *check;
	NSString  **labelColor;
}
-(PreferencesManager*)initWithWindowNibName: (NSString*)nibName withPrefVar: (NSString**)colorLabel;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)enableColor:(id)sender;
-(void)windowDidLoad;
-(void)dealloc;
@end
