/* MainWindow */

#import <Cocoa/Cocoa.h>
#import "Progress.h"
#import "Logger.h"
#import "PreferencesManager.h"

@interface MainWindow : NSObject
{
    IBOutlet NSButton *install;
    IBOutlet NSTextField *mod_path;
    IBOutlet NSTextField *ut_path;
    IBOutlet NSWindow *window;
    IBOutlet NSMatrix *zip_umod;
	Progress *controller;
	Logger *loggerage;
	PreferencesManager *preffer;
	NSString *colorLabel;
}
-(MainWindow*) init;
- (IBAction)findMod:(id)sender;
- (IBAction)findUT:(id)sender;
- (IBAction)installMod:(id)sender;
- (IBAction)displayLogs:(id)sender;
- (IBAction)displayPrefs:(id)sender;
-(void) textChange: (NSNotification*) notification;
-(void) finishLoad: (NSNotification*) notification;
-(void) applicationWillTerminate: (NSNotification*) notification;
-(BOOL) application: (NSApplication*) theApp openFile: (NSString*) filepath;
-(void)dealloc;
@end
