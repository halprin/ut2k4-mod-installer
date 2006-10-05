#import "Progress.h"
#import "InstallEngine.h"

@implementation Progress
-(void) windowDidLoad
{
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
	NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(start:) userInfo: nil repeats: NO];
	/*
	NSArray *senter=[NSArray arrayWithObjects: mod_path, ut_path, progress_bar, nil];
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		NSLog(@"huzzah!");
		[NSThread detachNewThreadSelector: @selector(zip_install:) toTarget: [InstallEngine class] withObject: senter];
		NSRunLoop *theRL=[NSRunLoop currentRunLoop];
		while(inst_done==NO && [theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]);
		//[self zip_install];
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		[self umod_install];
	}
	
	//dismis the sheet
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
	*/
}

-(void) zip_install
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	printf("Hello!");
	NSLog(@"Start ZIP install");
	
	//get the path to the unzip program
	NSString *zip_path=[[NSBundle mainBundle] bundlePath];
	zip_path=[zip_path stringByAppendingPathComponent: @"Contents"];
	zip_path=[zip_path stringByAppendingPathComponent: @"Resources"];
	zip_path=[zip_path stringByAppendingPathComponent: @"unzip"];
	//[zip_path autorelease];
	
	//set up for finding out the files in the ZIP
	NSTask *task=[[NSTask alloc] init];
	[task setLaunchPath: zip_path];
	NSArray *args=[NSArray arrayWithObjects: @"-Z", mod_path, nil];
	[task setArguments: args];
	NSPipe *pipe=[NSPipe pipe];
	[task setStandardOutput: pipe];
	NSFileHandle *file=[pipe fileHandleForReading];
	//execute and read
	[task launch];
	NSData* data=[file readDataToEndOfFile];
	NSString *contents=[NSString stringWithUTF8String: [data bytes]];
	/*[task autorelease];
	[args autorelease];
	[pipe autorelease];
	[file autorelease];
	[data autorelease];
	[contents autorelease];*/
	
	//find how many elements and set that to the max size of the progress bar
	NSArray *elements=[contents componentsSeparatedByString: @"\n"];
	NSMutableArray *elem_temp=[NSMutableArray arrayWithArray: elements];
	[elem_temp removeLastObject];
	[elem_temp removeLastObject];
	[elem_temp removeObjectAtIndex: 0];
	elements=[NSArray arrayWithArray: elem_temp];
	[progress_bar setIndeterminate: NO];
	[progress_bar setMaxValue: ((double)[elements count])];
	/*[elements autorelease];
	[elem_temp autorelease];*/
	
	NSLog(@"Starting actual installation!");
	//time for the actual unstuffing
	task=[[NSTask alloc] init];
	[task setLaunchPath: zip_path];
	args=[NSArray arrayWithObjects: @"-o", mod_path, @"-d", ut_path, nil];
	[task setArguments: args];
	pipe=[NSPipe pipe];
	[task setStandardOutput: pipe];
	file=[pipe fileHandleForReading];
	//ececute
	[task launch];
	while([task isRunning]==YES)
	{
		//still running and update the progress bar
		[progress_bar incrementBy: ((double)[[[NSString stringWithUTF8String: [[file availableData] bytes]] componentsSeparatedByString: @"\n"] count])];
		
		//printf("%f\n", ((double)[[[NSString stringWithUTF8String: [[file availableData] bytes]] componentsSeparatedByString: @"\n"] count]));
	}
	
	[pool release];
}

-(void) umod_install
{
	NSLog(@"UMOD install not implemented yet");
}

-(void) installDone: (NSNotification*) notification
{
	inst_done=YES;
	NSLog([notification name]);
}

-(void) start: (NSTimer*) timer
{
	NSArray *senter=[NSArray arrayWithObjects: mod_path, ut_path, progress_bar, nil];
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		NSLog(@"huzzah!");
		[NSThread detachNewThreadSelector: @selector(zip_install:) toTarget: [InstallEngine class] withObject: senter];
		NSRunLoop *theRL=[NSRunLoop currentRunLoop];
		while(inst_done==NO && [theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]);
		//[self zip_install];
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		[self umod_install];
	}
	
	//dismis the sheet
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
}
@end