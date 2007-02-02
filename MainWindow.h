/* MainWindow */

#import <Cocoa/Cocoa.h>
#import "Progress.h"

@interface MainWindow : NSObject
{
    IBOutlet NSButton *install;
    IBOutlet NSTextField *mod_path;
    IBOutlet NSTextField *ut_path;
    IBOutlet NSWindow *window;
    IBOutlet NSMatrix *zip_umod;
	Progress *controller;
}
-(MainWindow*) init;
- (IBAction)findMod:(id)sender;
- (IBAction)findUT:(id)sender;
- (IBAction)installMod:(id)sender;
-(void) textChange: (NSNotification*) notification;
-(void) finishLoad: (NSNotification*) notification;
-(BOOL) application: (NSApplication*) theApp openFile: (NSString*) filepath;
-(void)dealloc;
@end
