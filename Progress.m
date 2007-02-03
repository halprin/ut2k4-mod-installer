#import "Progress.h"
#import "InstallEngine.h"

@implementation Progress
-(void) windowDidLoad
{
	//add ourself as an observer to find when this window is fully loadaed and when a mod is done installing
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowLoaded:) name: @"_NSWindowDidBecomeVisible" object: [self window]];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(installDone:) name: @"InstallDone" object: nil];
	
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
	[ut_path autorelease];
	ut_path=[path retain];
}

-(void) setMod: (NSString*) path
{
	[mod_path autorelease];
	mod_path=[path retain];
}

-(void) setZU: (NSString*) zu
{
	[zip_umod autorelease];
	zip_umod=[zu retain];
}

-(void) windowLoaded: (NSNotification*) notification
{
	NSTimer *starter=[NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(start:) userInfo: nil repeats: NO];
}


-(void) installDone: (NSNotification*) notification
{
	inst_done=YES;
	NSTimer *ender=[NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(end:) userInfo: nil repeats: NO];
	//NSRunLoop *theRL=[NSRunLoop currentRunLoop];
	//while([theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]);
}

-(void) start: (NSTimer*) timer
{	
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		//get the path to the unzip program
		NSString *zip_path=[[NSBundle mainBundle] bundlePath];
		zip_path=[zip_path stringByAppendingPathComponent: @"Contents"];
		zip_path=[zip_path stringByAppendingPathComponent: @"Resources"];
		zip_path=[zip_path stringByAppendingPathComponent: @"unzip"];
		
		//set up for finding out the files in the ZIP
		[task autorelease];
		task=[[NSTask alloc] init];
		[task setStandardOutput: [NSPipe pipe]];
		[task setStandardError: [task standardOutput]];
		NSFileHandle *file=[[task standardOutput] fileHandleForReading];
		[task setLaunchPath: zip_path];
		[task setArguments: [NSArray arrayWithObjects: @"-Z", mod_path, nil]];
		//execute and read
		[task launch];
		NSString *contents=[NSString stringWithUTF8String: [[file readDataToEndOfFile] bytes]];
		
		//find how many elements and set that to the max size of the progress bar
		[elements autorelease];
		elements=[[NSMutableArray arrayWithArray: [contents componentsSeparatedByString: @"\n"]] retain];
		[elements removeLastObject];
		[elements removeLastObject];
		[elements removeObjectAtIndex: 0];
		[progress_bar setIndeterminate: NO];
		[progress_bar setMaxValue: ((double)[elements count])];
		
		
		//time for the actual unstuffing
		[task autorelease];
		task=[[NSTask alloc] init];
		[task setStandardOutput: [NSPipe pipe]];
		[task setStandardError: [task standardOutput]];
		[task setLaunchPath: zip_path];
		[task setArguments: [NSArray arrayWithObjects: @"-o", mod_path, @"-d", ut_path, nil]];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reader:) name: @"NSFileHandleReadCompletionNotification" object: [[task standardOutput] fileHandleForReading]];
		[[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
		//execute unzip -o *mod_path* -d *ut_path*
		//that unzips the .zip at the mod_path and b/c of the -d it unzips it into ut_path and b/c of the -o overwrites everything
		install_index=0;
		[task launch];
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		
	}
}

-(void)reader: (NSNotification*) notification
{
	NSData *data=[[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
	if([data length])  //does the data have anything in it?
    {
		NSString *contents=[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		//[[[log textStorage] mutableString] appendString: contents];
		int num_items=[[contents componentsSeparatedByString: @"\n"] count]-1;
		//for how ever many items were just read in, display that many from the array
		int lcv;
		for(lcv=0; lcv<num_items; lcv++)
		{
			[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]]];
			[[[log textStorage] mutableString] appendString: @"\n"];
			install_index++;
		}
		
		//scroll to the bottom of the log and up the progress bar
		[log scrollRangeToVisible: NSMakeRange([[log string] length], [[log string] length])];
		[progress_bar incrementBy: ((double)num_items)];
	}
	else
	{
		[task terminate];
		NSData *data;
		while((data=[[[task standardOutput] fileHandleForReading] availableData]) && [data length])  //does the data have anything in it?
		{
			NSString *contents=[[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
			//[[[log textStorage] mutableString] appendString: contents];
			int num_items=[[contents componentsSeparatedByString: @"\n"] count]-1;
			//for how ever many items were just read in, display that many from the array
			int lcv;
			for(lcv=0; lcv<num_items; lcv++)
			{
				[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]]];
				[[[log textStorage] mutableString] appendString: @"\n"];
				install_index++;
			}
			
			//scroll to the bottom of the log and up the progress bar
			[log scrollRangeToVisible: NSMakeRange([[log string] length], [[log string] length])];
			[progress_bar incrementBy: ((double)num_items)];
		}
		//take us off the notification
		[[NSNotificationCenter defaultCenter] removeObserver: self name: @"NSFileHandleReadCompletionNotification" object: nil];
		
		//display the rest of the files in the array if there is any left
		for(; install_index<[elements count]; install_index++)
		{
			[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]]];
			[[[log textStorage] mutableString] appendString: @"\n"];
		}
		//scroll to the bottom of the log and up the progress bar
		[log scrollRangeToVisible: NSMakeRange([[log string] length], [[log string] length])];
		[progress_bar setDoubleValue: [progress_bar maxValue]];
		[status_text setStringValue: @"Cleaning up..."];
		
		//post a notification that the install is done
		[[NSNotificationCenter defaultCenter] postNotificationName: @"InstallDone" object: self];
	}
	[[notification object] readInBackgroundAndNotify];
}

-(void) end: (NSTimer*) timer
{
	//dismis the sheet
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[ut_path release];
	[mod_path release];
	[zip_umod release];
	[task release];
	[elements release];
	[super dealloc];
}

@end