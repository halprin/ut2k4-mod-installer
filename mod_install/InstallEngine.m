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
	NSData *data=[file readDataToEndOfFile];
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
	
	NSLog(@"Starting actual installation!");
	//time for the actual unstuffing
	task=[[NSTask alloc] init];
	[task setLaunchPath: zip_path];
	args=[NSArray arrayWithObjects: @"-o", mod_path, @"-d", ut_path, nil];
	[task setArguments: args];
	pipe=[NSPipe pipe];
	[task setStandardOutput: pipe];
	file=[pipe fileHandleForReading];
	//execute unzip -o *mod_path* -d *ut_path*
	//that unzips the .zip at the mod_path and b/c of the -d it unzips it into ut_path and b/c of the -o overwrites everything
	[task launch];
	while([task isRunning]==YES)
	{
		//still running and update the progress bar
		data=[file availableData];
		if([data length]!=0 && [data length]!=1)  //the buffer isn't empty and there isn't just a wierd space thingy
		{
			contents=[NSString stringWithUTF8String: [data bytes]];
			NSLog(contents);
			[progress_bar incrementBy: ((double)[[contents componentsSeparatedByString: @"\n"] count])];
		}
	}
	
	[progress_bar setDoubleValue: [progress_bar maxValue]];
	
	//post a notification that the install is done
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center postNotificationName: @"InstallDone" object: self];
	
	[pool release];
}

+(void) umod_install: (id) info
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSString *mod_path=[info objectAtIndex: 0];
	NSString *ut_path=[info objectAtIndex: 1];
	NSProgressIndicator *progress_bar=[info objectAtIndex: 2];
	
	//get the path to the ucc-bin program
	NSString *ucc_path=[ut_path stringByAppendingPathComponent: @"System"];
	ucc_path=[ucc_path stringByAppendingPathComponent: @"ucc-bin"];
	
	//set up for finding out the files in the UMOD
	NSTask *task=[[NSTask alloc] init];
	[task setLaunchPath: ucc_path];
	NSArray *args=[NSArray arrayWithObjects: @"umodunpack", @"-l", mod_path, @"-nohomedir", nil];
	[task setArguments: args];
	//execute and read
	[task launch];
	[task waitUntilExit];
	NSString *contents=[NSString stringWithContentsOfFile: [ut_path stringByAppendingString: @"/System/ucc.log"]];
	
	NSLog(contents);
	
	//find how many elements and set that to the max size of the progress bar
	NSArray *elements=[contents componentsSeparatedByString: @"\n"];
	NSMutableArray *elem_temp=[NSMutableArray arrayWithArray: elements];
	//for(
	[elem_temp removeLastObject];
	//for(
	[elem_temp removeObjectAtIndex: 0];
	elements=[NSArray arrayWithArray: elem_temp];
	[progress_bar setIndeterminate: NO];
	[progress_bar setMaxValue: ((double)[elements count])];
	NSLog([elements objectAtIndex: [elements count]-1]);
	
	
	
	[progress_bar setDoubleValue: [progress_bar maxValue]];
	
	//post a notification that the install is done
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center postNotificationName: @"InstallDone" object: self];
	
	[pool release];
}

@end
