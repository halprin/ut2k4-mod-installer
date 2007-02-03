/* Logger */

#import <Cocoa/Cocoa.h>

@interface Logger : NSObject
{
    IBOutlet NSTableView *table;
    IBOutlet NSButton *uninstallButton;
    IBOutlet NSButton *viewButton;
}
- (IBAction)uninstall:(id)sender;
- (IBAction)view:(id)sender;
@end
