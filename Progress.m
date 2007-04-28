//
//  Progress.m
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall
//  Copyright @PAK software 2007. All rights reserved.
//

#import "Progress.h"

@implementation Progress
-(void) windowDidLoad
{
	//add ourself as an observer to find when this window is fully loadaed and when a mod is done installing
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowLoaded:) name: @"_NSWindowDidBecomeVisible" object: [self window]];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(installDone:) name: @"InstallDone" object: nil];
	
	//start animate the barber pole and tell the animation to be threaded so it updates durring intense computation
	[progress_bar startAnimation: self];
	[progress_bar setUsesThreadedAnimation: YES];
	
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

-(void) setColorLabel: (NSString*) cl
{
	[colorLabel autorelease];
	colorLabel=[cl retain];
}

-(void) windowLoaded: (NSNotification*) notification
{
	NSTimer *starter=[NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(start:) userInfo: nil repeats: NO];
}


-(void) installDone: (NSNotification*) notification
{
	NSTimer *ender=[NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(end:) userInfo: nil repeats: NO];
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
		
		//even though it isn't used, set it to no anyway
		moved=NO;
		
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
		task=[[[NSTask alloc] init] retain];
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
		//get the path to the ucc-bin program
		NSString *ucc_path=[ut_path stringByAppendingPathComponent: @"System"];
		ucc_path=[ucc_path stringByAppendingPathComponent: @"ucc-bin"];
		
		//If there spaces to the UMOD, we need to rectify that by moving it to the home folder and then back afterward
		NSFileManager *manager=[NSFileManager defaultManager];
		moved=NO;
		[old_mod autorelease];
		old_mod=[NSString string];
		NSArray *spaces=[mod_path componentsSeparatedByString: @" "];
		if([spaces count]>1)  //we have spaces!
		{
			[manager movePath: mod_path toPath: [NSHomeDirectory() stringByAppendingPathComponent: [mod_path lastPathComponent]] handler: self];
			[old_mod autorelease];
			old_mod=[[NSString stringWithString: mod_path] retain];
			[mod_path autorelease];
			mod_path=[NSHomeDirectory() stringByAppendingPathComponent: [mod_path lastPathComponent]];
			moved=YES;
		}
		
		//set up for finding out the files in the UMOD
		[task autorelease];
		task=[[NSTask alloc] init];
		[task setLaunchPath: ucc_path];
		[task setArguments: [NSArray arrayWithObjects: @"umodunpack", @"-l", mod_path, @"-nohomedir", nil]];
		[task launch];
		[task waitUntilExit];
		NSString *contents=[NSString stringWithContentsOfFile: [ut_path stringByAppendingString: @"/System/ucc.log"]];
		
		//parse the string and set the progress bar to the size
		[elements autorelease];
		elements=[[NSMutableArray arrayWithArray: [contents componentsSeparatedByString: @"\n"]] retain];
		int lcv=0;
		for(lcv=0; lcv<12; lcv++)
		{
			[elements removeLastObject];
		}
		for(lcv=0; lcv<12; lcv++)
		{
			[elements removeObjectAtIndex: 0];
		}
		for(lcv=0; lcv<[elements count]; lcv++)
		{
			if([[[elements objectAtIndex: lcv] substringToIndex: 6] isEqualToString: @"Log: ."]==YES)  //it isn't installed in System
			{
				[elements replaceObjectAtIndex: lcv withObject: [[elements objectAtIndex: lcv] substringFromIndex: 8]];
			}
			else
			{
				[elements replaceObjectAtIndex: lcv withObject: [@"System/" stringByAppendingString: [[elements objectAtIndex: lcv] substringFromIndex: 5]]];
			}
		}
		
		[progress_bar setIndeterminate: NO];
		[progress_bar setMaxValue: 2*((double)[elements count])+5];  //2 times because once is determining changed files and the other for actuall installation and +5 for extra lines in the installation log
		
		//if a folder doesn't exist, make it.  if a file exists, delete it
		[status_text setStringValue: @"Determining changed files:"];
		NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString: @"/"];
		for(lcv=0; lcv<[elements count]; lcv++)
		{
			NSScanner *sc=[NSScanner scannerWithString: [elements objectAtIndex: lcv]];
			NSString *item=[NSString string];
			NSString *traverse=[NSString string];
			BOOL work=YES;
			while(work==YES && [sc isAtEnd]!=YES)  //keep doing this if work keeps returning meaningfull stuff and it isn't at the end
			{
				//[item autorelease];
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
				else
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
		[task autorelease];
		task=[[[NSTask alloc] init] retain];
		[task setStandardOutput: [NSPipe pipe]];
		[task setStandardError: [task standardOutput]];
		[task setLaunchPath: ucc_path];
		[task setArguments: [NSArray arrayWithObjects: @"umodunpack", @"-x", mod_path, @"-nohomedir", nil]];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reader:) name: @"NSFileHandleReadCompletionNotification" object: [[task standardOutput] fileHandleForReading]];
		[[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
		install_index=0;
		//execute umodunpack -x *mod_path* -nohomedir
		[task launch];
	}
}

-(void)reader: (NSNotification*) notification
{
	NSData *data=[[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
	if([data length])  //does the data have anything in it?
    {
		NSString *contents=[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		int num_items=[[contents componentsSeparatedByString: @"\n"] count]-1;
		//for how ever many items were just read in, display that many from the array
		int lcv;
		for(lcv=0; lcv<num_items; lcv++)
		{
			if([zip_umod isEqualToString: @"zip"])
			{
				if(install_index<[elements count])
				{
					if([colorLabel isEqualToString: @"0"]==NO)  //if we have a label wanted, lets add it!
					{
						//crazy go nuts CoreFoundation code thanks to CocoaDev that gets me the exact HFS file path
						CFURLRef posixURL=CFURLCreateWithFileSystemPath(NULL, (CFStringRef)[[ut_path stringByAppendingString: @"/"] stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]], kCFURLPOSIXPathStyle, false);
						CFStringRef asPath=CFURLCopyFileSystemPath(posixURL, kCFURLHFSPathStyle);
						CFRelease(posixURL);
						
						//make the command and execute AppleScript
						NSString *asCommand=[NSString stringWithFormat: @"tell application \"Finder\"\nset label index of alias \"%@\" to %@\nend tell", asPath, colorLabel];
						CFRelease(asPath);
						NSAppleScript *script=[[NSAppleScript alloc] initWithSource: asCommand];
						[script executeAndReturnError: nil];
						[script autorelease];
					}
					
					[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]]];
					[[[log textStorage] mutableString] appendString: @"\n"];
				}
			}
			else
			{
				if(install_index<[elements count])
				{
					if([colorLabel isEqualToString: @"0"]==NO)  //if we have a label wanted, lets add it!
					{
						//crazy go nuts CoreFoundation code thanks to CocoaDev that gets me the exact HFS file path
						CFURLRef posixURL=CFURLCreateWithFileSystemPath(NULL, (CFStringRef)[[ut_path stringByAppendingString: @"/"] stringByAppendingString: [elements objectAtIndex: install_index]], kCFURLPOSIXPathStyle, false);
						CFStringRef asPath=CFURLCopyFileSystemPath(posixURL, kCFURLHFSPathStyle);
						CFRelease(posixURL);
						
						//make the command and execute AppleScript
						NSString *asCommand=[NSString stringWithFormat: @"tell application \"Finder\"\nset label index of alias \"%@\" to %@\nend tell", asPath, colorLabel];
						CFRelease(asPath);
						NSAppleScript *script=[[NSAppleScript alloc] initWithSource: asCommand];
						[script executeAndReturnError: nil];
						[script autorelease];
					}
					
					[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [elements objectAtIndex: install_index]]];
					[[[log textStorage] mutableString] appendString: @"\n"];
				}
			}
			install_index++;
		}
		
		//scroll to the bottom of the log and up the progress bar
		[log scrollRangeToVisible: NSMakeRange([[log string] length], [[log string] length])];
		[progress_bar incrementBy: ((double)num_items)];
		
		[contents release];
	}
	else
	{
		[task terminate];
		NSData *data;
		while((data=[[[task standardOutput] fileHandleForReading] availableData]) && [data length])  //does the data have anything in it?
		{
			NSString *contents=[[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
			int num_items=[[contents componentsSeparatedByString: @"\n"] count]-1;
			//for how ever many items were just read in, display that many from the array
			int lcv;
			for(lcv=0; lcv<num_items; lcv++)
			{
				if([zip_umod isEqualToString: @"zip"])
				{
					if(install_index<[elements count])
					{
						[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [[[[elements objectAtIndex: install_index] componentsSeparatedByString: @":"] objectAtIndex: 1] substringFromIndex: 3]]];
						[[[log textStorage] mutableString] appendString: @"\n"];
					}
				}
				else
				{
					if(install_index<[elements count])
					{
						[[[log textStorage] mutableString] appendString: [@"Installing:  " stringByAppendingString: [elements objectAtIndex: install_index]]];
						[[[log textStorage] mutableString] appendString: @"\n"];
					}
				}
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
		
		if(moved==YES)  //we need to move the mod file back to the original place
		{
			[[NSFileManager defaultManager] movePath: mod_path toPath: old_mod handler: self];
		}
		
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
	[old_mod release];
	[super dealloc];
}

@end
