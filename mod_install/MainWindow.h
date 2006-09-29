/* MainWindow */

#import <Cocoa/Cocoa.h>

@interface MainWindow : NSObject
{
    IBOutlet NSTextField *mod_path;
    IBOutlet NSTextField *ut_path;
    IBOutlet NSMatrix *zip_umod;
}
- (IBAction)findMod:(id)sender;
- (IBAction)findUT:(id)sender;
- (IBAction)installMod:(id)sender;
@end
