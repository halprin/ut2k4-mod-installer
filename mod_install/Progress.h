/* Progress */

#import <Cocoa/Cocoa.h>

@interface Progress : NSWindowController
{
    IBOutlet NSProgressIndicator *progress_bar;
    IBOutlet NSTextField *status_text;
	NSString *ut_path;
	NSString *mod_path;
	NSString *zip_umod;
}
-(void) windowDidLoad;
-(void) setUT: (NSString*) path;
-(void) setMod: (NSString*) path;
-(void) setZU: (NSString*) zu;
-(void) zip_install;
-(void) umod_install;
@end
