//
//  InstallEngine.m
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall on 10/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "InstallEngine.h"


@implementation InstallEngine
+(void) zip_install: (id) info
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSString *mod_path=[info objectAtIndex: 0];
	NSString *ut_path=[info objectAtIndex: 1];
	NSProgressIndicator *progress_bar=[info objectAtIndex: 2];
	printf("Hello!\n");
	//NSLog(@"Start ZIP install");
	
	//get the path to the unzip program
	NSString *zip_path=[[NSBundle mainBundle] bundlePath];
	zip_path=[zip_path stringByAppendingPathComponent: @"Contents"];
	zip_path=[zip_path stringByAppendingPathComponent: @"Resources"];
	zip_path=[zip_path stringByAppendingPathComponent: @"unzip"];
	
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
	
	//find how many elements and set that to the max size of the progress bar
	NSArray *elements=[contents componentsSeparatedByString: @"\n"];
	NSMutableArray *elem_temp=[NSMutableArray arrayWithArray: elements];
	[elem_temp removeLastObject];
	[elem_temp removeLastObject];
	[elem_temp removeObjectAtIndex: 0];
	elements=[NSArray arrayWithArray: elem_temp];
	[progress_bar setIndeterminate: NO];
	[progress_bar setMaxValue: ((double)[elements count])];
	printf("%f\n", ((double)[elements count]));
	
	//NSLog(@"Starting actual installation!");
	printf("Starting actual installation!\n");
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
	[progress_bar setDoubleValue: 0.0];
	//NSRunLoop *theRL=[NSRunLoop currentRunLoop];
	while([task isRunning]==YES/* && [theRL runMode: NSDefaultRunLoopMode beforeDate: [NSDate dateWithTimeIntervalSinceNow: 5.0]]*/)
	{
		//still running and update the progress bar
		//printf("running task begin...\n");
		data=[file availableData];
		//printf("%i\n", [data length]);
		if([data length]!=0 && [data length]!=1)
		{
			contents=[NSString stringWithUTF8String: [data bytes]];
			NSLog(contents);
			[progress_bar incrementBy: ((double)[[contents componentsSeparatedByString: @"\n"] count])];
		}
		//printf("%f\n", ((double)[[[NSString stringWithUTF8String: [[file availableData] bytes]] componentsSeparatedByString: @"\n"] count]));
		//printf("%f\n", [progress_bar doubleValue]);
		//printf("running task end...\n");
	}
	//printf("%f\n", ((double)[[[NSString stringWithUTF8String: [[file availableData] bytes]] componentsSeparatedByString: @"\n"] count]));
	NSLog(@"DONE!");
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center postNotificationName: @"InstallDone" object: self];
	[pool release];
}
@end
