/* Logger */

#import <Cocoa/Cocoa.h>
#import "LoggerDataSource.h"
#import "FileList.h"

@interface Logger : NSWindowController
{
    IBOutlet NSTableView *table;
    IBOutlet NSButton *uninstallButton;
    IBOutlet NSButton *viewButton;
	LoggerDataSource *data;
	IBOutlet FileList *lister;
	NSArray *log;
}
-(Logger*)init;
- (IBAction)uninstall:(id)sender;
- (IBAction)view:(id)sender;
-(void)tableViewSelectionDidChange: (NSNotification*)notification;
-(void) windowLoaded: (NSNotification*) notification;
-(void)dealloc;
@end
