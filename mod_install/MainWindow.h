/* MainWindow */

#import <Cocoa/Cocoa.h>

@interface MainWindow : NSObject
{
    IBOutlet NSButton *install;
    IBOutlet NSTextField *mod_path;
    IBOutlet NSTextField *ut_path;
    IBOutlet NSMatrix *zip_umod;
}
-(MainWindow*) init;
- (IBAction)findMod:(id)sender;
- (IBAction)findUT:(id)sender;
- (IBAction)installMod:(id)sender;
-(void) textChange: (NSNotification*) notification;
-(void) finishLoad: (NSNotification*) notification;
@end
