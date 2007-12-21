/* Progress */

#import <Cocoa/Cocoa.h>

@interface Progress : NSWindowController
{
    IBOutlet NSProgressIndicator *progress_bar;
    IBOutlet NSTextField *status_text;
	IBOutlet NSTextView *log;
	NSString *ut_path;
	NSString *mod_path;
	NSString *old_mod;
	NSString *zip_umod;
	NSTask *task;
	NSMutableArray *elements;
	int install_index;
	BOOL moved;
	NSString *colorLabel;
	NSString *installTime;
}
-(void) windowDidLoad;
-(void) setUT: (NSString*) path;
-(void) setMod: (NSString*) path;
-(void) setZU: (NSString*) zu;
-(void) setColorLabel: (NSString*) cl;
-(void) windowLoaded: (NSNotification*) notification;
-(void) installDone: (NSNotification*) notification;
-(void) start: (NSTimer*) timer;
-(void)reader: (NSNotification*) notification;
-(void) end: (NSTimer*) timer;
-(void)dealloc;
@end
