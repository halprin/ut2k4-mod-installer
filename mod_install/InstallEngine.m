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
	NSTextField *status_text=[info objectAtIndex: 3];
	
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
	[status_text setStringValue: @"Cleaning up..."];
	
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
	NSTextField *status_text=[info objectAtIndex: 3];
	
	//get the path to the ucc-bin program
	NSString *ucc_path=[ut_path stringByAppendingPathComponent: @"System"];
	ucc_path=[ucc_path stringByAppendingPathComponent: @"ucc-bin"];
	
	//If there spaces to the UMOD, we need to rectify that by moving it to the home folder and then back afterward
	NSFileManager *manager=[NSFileManager defaultManager];
	BOOL moved=NO;
	NSString *old_mod=[NSString string];
	NSArray *spaces=[mod_path componentsSeparatedByString: @" "];
	if([spaces count]>1)  //we have spaces!
	{
		[manager movePath: mod_path toPath: [NSHomeDirectory() stringByAppendingPathComponent: [mod_path lastPathComponent]] handler: self];
		old_mod=[NSString stringWithString: mod_path];
		mod_path=[NSHomeDirectory() stringByAppendingPathComponent: [mod_path lastPathComponent]];
		moved=YES;
	}
	
	//set up for finding out the files in the UMOD
	NSTask *task=[[NSTask alloc] init];
	[task setLaunchPath: ucc_path];
	NSArray *args=[NSArray arrayWithObjects: @"umodunpack", @"-l", mod_path, @"-nohomedir", nil];
	[task setArguments: args];
	//execute and read
	[task launch];
	[task waitUntilExit];
	NSString *contents=[NSString stringWithContentsOfFile: [ut_path stringByAppendingString: @"/System/ucc.log"]];
		
	//parse the string and set the progress bar to the size
	NSArray *elements=[contents componentsSeparatedByString: @"\n"];
	NSMutableArray *elem_temp=[NSMutableArray arrayWithArray: elements];
	int lcv=0;
	for(lcv=0; lcv<12; lcv++)
	{
		[elem_temp removeLastObject];
	}
	for(lcv=0; lcv<12; lcv++)
	{
		[elem_temp removeObjectAtIndex: 0];
	}
	for(lcv=0; lcv<[elem_temp count]; lcv++)
	{
		if([[[elem_temp objectAtIndex: lcv] substringToIndex: 6] isEqualToString: @"Log: ."]==YES)  //it isn't installed in System
		{
			[elem_temp replaceObjectAtIndex: lcv withObject: [[elem_temp objectAtIndex: lcv] substringFromIndex: 8]];
		}
		else
		{
			[elem_temp replaceObjectAtIndex: lcv withObject: [@"System/" stringByAppendingString: [[elem_temp objectAtIndex: lcv] substringFromIndex: 5]]];
		}
	}
	elements=[NSArray arrayWithArray: elem_temp];
	[progress_bar setIndeterminate: NO];
	[progress_bar setMaxValue: 2*((double)[elements count])+5];  //2 times because once is determining changed files and the other for actuall installation and +5 for extra lines in the installation log
	
	//if a folder doesn't exist, make it.  if a file exists, delete it
	[status_text setStringValue: @"Determining changed files:"];
	NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString: @"/"];
	for(lcv=0; lcv<[elem_temp count]; lcv++)
	{
		NSScanner *sc=[NSScanner scannerWithString: [elements objectAtIndex: lcv]];
		NSString *item=[NSString string];
		NSString *traverse=[NSString string];
		BOOL work=YES;
		while(work==YES && [sc isAtEnd]!=YES)  //keep doing this if work keeps returning meaningfull stuff and it isn't at the end
		{
			work=[sc scanUpToCharactersFromSet: set intoString: &item];
			[sc scanString: @"/" intoString: nil];
			traverse=[traverse stringByAppendingPathComponent: item];
			//check if the item is a folder or item
			BOOL isDir;
			BOOL exist=[manager fileExistsAtPath: [[ut_path stringByAppendingString: @"/"] stringByAppendingString: traverse] isDirectory: &isDir];
			if(exist==YES)  //the file does exit and tests if it is a directory or not
			{
				if(isDir==NO)  //it is a file
				{
					//need to delete the file so the umodunpack doesn't through a fit
					[manager removeFileAtPath: [[ut_path stringByAppendingString: @"/"] stringByAppendingString: traverse] handler: self];
				}
			}
			else  //the file does not exist
			{
				if([sc isAtEnd]==NO)  //isDir isn't edited if it doesn't even exist so we test if the Scanner is at the end (and if it is, that means it is a file, not a directory)
				{
					//need to create the directory so the umodunpack doesn't through a fit
					[manager createDirectoryAtPath: [[ut_path stringByAppendingString: @"/"] stringByAppendingString: traverse] attributes: nil];
				}
			}
		}
		[progress_bar incrementBy: 1.0];
	}
	
	//now actually do the umodunpack
	[status_text setStringValue: @"Installing:"];
	task=[[NSTask alloc] init];
	[task setLaunchPath: ucc_path];
	args=[NSArray arrayWithObjects: @"umodunpack", @"-x", mod_path, @"-nohomedir", nil];
	[task setArguments: args];
	NSPipe *pipe=[NSPipe pipe];
	[task setStandardOutput: pipe];
	NSFileHandle *file=[pipe fileHandleForReading];
	NSData *data=[NSData data];
	//execute
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
	[status_text setStringValue: @"Cleaning up..."];
	if(moved==YES)  //we need to move the mod file back to the original place
	{
		[manager movePath: mod_path toPath: old_mod handler: self];
	}
	
	//post a notification that the install is done
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center postNotificationName: @"InstallDone" object: self];
	
	[pool release];
}

@end
