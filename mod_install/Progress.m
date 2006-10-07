#import "Progress.h"
#import "InstallEngine.h"

@implementation Progress
-(void) windowDidLoad
{
	//add ourself as an observer to find when this window is fully loadaed and when a mod is done installing
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(windowLoaded:) name: @"_NSWindowDidBecomeVisible" object: [self window]];
	[center addObserver: self selector: @selector(installDone:) name: @"InstallDone" object: nil];
	
	//start animate the barber pole and tell the animation to be threaded so it updates durring intense computation
	[progress_bar startAnimation: self];
	[progress_bar setUsesThreadedAnimation: YES];
	
	inst_done=NO;
	
	//set the initial status info
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		[status_text setStringValue: @"Unzipping and installing:"];
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		[status_text setStringValue: @"Reading umod:"];
	}
}

-(void) setUT: (NSString*) path
{
	ut_path=path;
}

-(void) setMod: (NSString*) path
{
	mod_path=path;
}

-(void) setZU: (NSString*) zu
{
	zip_umod=zu;
}

-(void) windowLoaded: (NSNotification*) notification
{
	NSTimer *starter=[NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(start:) userInfo: nil repeats: NO];
}


-(void) installDone: (NSNotification*) notification
{
	inst_done=YES;
}

-(void) start: (NSTimer*) timer
{
	NSArray *senter=[NSArray arrayWithObjects: mod_path, ut_path, progress_bar, status_text, nil];
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		[NSThread detachNewThreadSelector: @selector(zip_install:) toTarget: [InstallEngine class] withObject: senter];
		NSRunLoop *theRL=[NSRunLoop currentRunLoop];
		while(inst_done==NO && [theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]);
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		[NSThread detachNewThreadSelector: @selector(umod_install:) toTarget: [InstallEngine class] withObject: senter];
		NSRunLoop *theRL=[NSRunLoop currentRunLoop];
		while(inst_done==NO && [theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]);
	}
	
	//show that the process has finished at least for tiny bit
	NSTimer *ender=[NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(end:) userInfo: nil repeats: NO];
}

-(void) end: (NSTimer*) timer
{
	//dismis the sheet
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
}

@end