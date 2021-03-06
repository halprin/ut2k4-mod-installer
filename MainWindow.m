//
//  Progress.m
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall
//  Copyright @PAK software 2007. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow

-(MainWindow*) init
{
	if(self=[super init])
	{
		//get notification if one of the text boxes contents changes and set it to textChange:
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChange:) name: @"NSControlTextDidChangeNotification" object: mod_path];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChange:) name: @"NSControlTextDidChangeNotification" object: ut_path];
		
		//get notification once the app has fully loaded
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(finishLoad:) name: @"NSApplicationDidFinishLaunchingNotification" object: nil];
		
		colorLabel=[[NSString stringWithString: @"0"] retain];
	}
	return self;
}

- (IBAction)findMod:(id)sender
{
	NSButtonCell *zip=[zip_umod cellAtRow: 0 column: 0];
	NSButtonCell *umod=[zip_umod cellAtRow: 0 column: 1];
	NSString *path=[NSString stringWithString: @"-1"];
	if([zip state]==1)  //ZIP is selected in the Radio control
	{
		//setup and display the open dialog box
		NSArray *fileTypes=[NSArray arrayWithObject: @"zip"];
		NSOpenPanel *oPanel=[NSOpenPanel openPanel];
		int result=[oPanel runModalForDirectory: nil file: nil types: fileTypes];
		if(result==NSOKButton)
		{
			NSArray *file=[oPanel filenames];
			path=[file objectAtIndex: 0];
		}
	}
	else if([umod state]==1)  //UMOD is selected in the Radio control
	{
		//setup and display the open dialog box
		NSArray *fileTypes=[NSArray arrayWithObjects: @"ut4mod", @"umod", nil];
		NSOpenPanel *oPanel=[NSOpenPanel openPanel];
		int result=[oPanel runModalForDirectory: nil file: nil types: fileTypes];
		if(result==NSOKButton)
		{
			NSArray *file=[oPanel filenames];
			path=[file objectAtIndex: 0];
		}
	}
	else  //This should never execute, if so, BUG!
	{
		NSLog(@"Bugzor!");
	}
	if([path isEqualToString: @"-1"]==NO)  //If the user clicked Cancel in the open dialog box
	{
		//set the mod location text box to the path
		[mod_path setStringValue: path];
		//send a notification that the text changed b/c the text box doesn't do it
		[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: mod_path];
	}
}

- (IBAction)findUT:(id)sender
{
	NSString *path=[NSString stringWithString: @"-1"];
	//setup and display the open dialog box
	NSArray *fileTypes=[NSArray arrayWithObject: @"app"];
	NSOpenPanel *oPanel=[NSOpenPanel openPanel];
	int result=[oPanel runModalForDirectory: nil file: nil types: fileTypes];
	if(result==NSOKButton)
	{
		NSArray *file=[oPanel filenames];
		path=[file objectAtIndex: 0];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path];
		//send a notification that the text changed b/c the text box doesn't do it
		[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
}

- (IBAction)installMod: (id)sender
{
	[controller autorelease];
	controller=[[Progress alloc] initWithWindowNibName: @"ProgressWindow"];
	
	//need to make sure that UT2k4 and the mod really exist as the user could
	//of entered the path manually
	NSFileManager *exists=[NSFileManager defaultManager];
	if([exists fileExistsAtPath: [ut_path stringValue]]==NO)  //UT2k4 does not exist
	{
		NSBeginAlertSheet(@"UT2k4 does not exist!", @"OK", nil, nil, window, self, nil, nil, nil, @"UT2k4 does not exist at that location.  A way to make sure that it exists is by selecting it through the \"Browse...\" button.");
	}
	else  //UT2k4 does exist
	{
		if([exists fileExistsAtPath: [mod_path stringValue]]==NO)  //the mod does not exist
		{
			NSBeginAlertSheet(@"Mod does not exist!", @"OK", nil, nil, window, self, nil, nil, nil, @"The mod file that you specified does not exist.  A way to make sure that it exists is by selecting it through the \"Browse...\" button.");
		}
		else  //the mod does exist
		{
			BOOL nope=NO;
			//tell the new progress window weather it is a zip or a umod we are doing
			if([[zip_umod cellAtRow: 0 column: 0] state]==1)  //ZIP is selected in the Radio control
			{
				[controller setZU: @"zip"];
				//make sure we have the correct kind of file to install
				if([[[[mod_path stringValue] pathExtension] lowercaseString] isEqualToString: @"zip"]==NO)  //it isn't a zip file
				{
					NSBeginAlertSheet(@"Mod file is not a ZIP!", @"OK", nil, nil, window, self, nil, nil, nil, @"You selected to install a ZIP but the mod file does not appear to be a ZIP file.");
					nope=YES;
				}
			}
			else if([[zip_umod cellAtRow: 0 column: 1] state]==1)  //UMOD is selected in the Radio control
			{
				[controller setZU: @"umod"];
				//The program takes care of spaces in the file path but we are not allowed to have spaces in the UMOD file itself w/o actually changing the name (and I don't want to do that)
				NSArray *spaces=[[[mod_path stringValue] lastPathComponent] componentsSeparatedByString: @" "];
				if([spaces count]>1)  //we have spaces!
				{
					NSBeginAlertSheet(@"Spaces in UMOD file!", @"OK", nil, nil, window, self, nil, nil, nil, @"Please remove the spaces in the UMOD file before continuing.");
					nope=YES;
				}
				//make sure we have the correct kind of file to install
				if([[[[mod_path stringValue] pathExtension] lowercaseString] isEqualToString: @"umod"]==NO  && [[[[mod_path stringValue] pathExtension] lowercaseString] isEqualToString: @"ut4mod"]==NO)  //it isn't a UMOD file
				{
					NSBeginAlertSheet(@"Mod file is not a UMOD!", @"OK", nil, nil, window, self, nil, nil, nil, @"You selected to install a UMOD but the mod file does not appear to be a UMOD file.");
					nope=YES;
				}
			}
			else  //This should never execute, if so, BUG!
			{
				NSLog(@"Bugzor!");
			} 
			
			//display the sheet!
			if(nope!=YES)  //UMOD file doesn't have spaces
			{
				//pass the UT2k4 and mod path to the new progress window and color to label new files
				[controller setUT: [ut_path stringValue]];
				[controller setMod: [mod_path stringValue]];
				[controller setColorLabel: colorLabel];
				[NSApp beginSheet: [controller window] modalForWindow: window modalDelegate: self didEndSelector: nil contextInfo: nil];
			}
		}
	}
}

- (IBAction)displayLogs:(id)sender
{
	[loggerage autorelease];
	loggerage=[[Logger alloc] init];
	[loggerage showWindow: self];
}

- (IBAction)displayPrefs:(id)sender
{
	[preffer autorelease];
	preffer=[[PreferencesManager alloc] initWithWindowNibName: @"Preferences" withPrefVar: &colorLabel];
	[preffer showWindow: self];
}

-(void) textChange: (NSNotification*) notification
{
	if([[ut_path stringValue] length]!=0 && [[mod_path stringValue] length]!=0)  //both text boxes have text
	{
		[install setEnabled: YES];
	}
	else //both text boxes have no text
	{
		[install setEnabled: NO];
	}
}

-(void) finishLoad: (NSNotification*) notification
{
	//read in from the preferences
	NSFileManager *prefs=[NSFileManager defaultManager];
	
	//add in some code that checks if the .plist file exists first before any of these bottom 2
	if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist"]]==YES)  //The new prefs exist
	{
		//get the dictionary and get the two keys in there
		NSDictionary *root=[NSKeyedUnarchiver unarchiveObjectWithFile: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath]];
		NSString *path_temp=[root valueForKey: @"UTpath"];
		NSString *colorage=[root valueForKey: @"ColorLabel"];
		if(colorage!=nil)  //need to check for this because it is possible that this key might not exist
		{
			[colorLabel autorelease];
			colorLabel=[colorage retain];
		}
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
		//send a notification that the text changed b/c the text box doesn't do it
		[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
	else if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]]==YES)  //The UT2k4 location file exists
	{
		NSData *data=[prefs contentsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]];
		NSString *str=[NSString stringWithUTF8String: [data bytes]];
		//remove the last character which is a return
		NSString *path_temp=[[str substringToIndex: [str length]-1] stringByStandardizingPath];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
		
		//write the path to a new preference file
		NSMutableDictionary *root=[NSMutableDictionary dictionary];
		[root setValue: path_temp forKey: @"UTpath"];
		[NSKeyedArchiver archiveRootObject: root toFile: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath]];
		//now delete the old pref file if they are there cause it sucks!
		BOOL deleted=[prefs removeFileAtPath: [@"~/Library/Preferences/Mod_installer_prefs.txt" stringByExpandingTildeInPath] handler: self];
		if(deleted==NO)
		{
			NSLog(@"Old preferences could not be deleted!");
		}
		
		//send a notification that the text changed b/c the text box doesn't do it
		[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
	else if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Preferences/Mod_installer_prefs.txt"]]==YES)  //The old prefs exist
	{
		NSData *data=[prefs contentsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Preferences/Mod_installer_prefs.txt"]];
		NSString *str=[NSString stringWithUTF8String: [data bytes]];
		//parse it so it doesn't have the ":"
		NSArray *path_parts=[str componentsSeparatedByString: @":"];
		//need to change it into a NSMutableArray so I can remove the last element because
		//the last element is blank and screws this up
		NSMutableArray *array_temp=[NSMutableArray arrayWithArray: path_parts];
		[array_temp removeLastObject];
		path_parts=array_temp;
		NSString *path_temp=[[NSString pathWithComponents: path_parts] stringByStandardizingPath];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
		
		//write the path to a new preference file
		NSMutableDictionary *root=[NSMutableDictionary dictionary];
		[root setValue: path_temp forKey: @"UTpath"];
		[NSKeyedArchiver archiveRootObject: root toFile: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath]];
		//now delete the old pref file cause it sucks!
		BOOL deleted=[prefs removeFileAtPath: [@"~/Library/Preferences/Mod_installer_prefs.txt" stringByExpandingTildeInPath] handler: self];
		if(deleted==NO)
		{
			NSLog(@"Old preferences could not be deleted!");
		}
		
		//send a notification that the text changed b/c the text box doesn't do it
		[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
}

-(void) applicationWillTerminate: (NSNotification*) notification
{
	//write the path and color label to a new preference file
	NSFileManager *exists=[NSFileManager defaultManager];
	BOOL deleted=[exists removeFileAtPath: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath] handler: self];
	if(deleted==NO)
	{
		NSLog(@"New prefs can't be overriden!");
	}
	NSMutableDictionary *root=[NSMutableDictionary dictionary];
	[root setValue: [ut_path stringValue] forKey: @"UTpath"];
	[root setValue: colorLabel forKey: @"ColorLabel"];
	[NSKeyedArchiver archiveRootObject: root toFile: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath]];
}

-(BOOL) application: (NSApplication*) theApp openFile: (NSString*) filepath
{
	[mod_path setStringValue: filepath];
	[[zip_umod cellAtRow: 0 column: 0] setState: 0];
	[[zip_umod cellAtRow: 0 column: 1] setState: 1];
	//send a notification that the text changed b/c the text box doesn't do it
	[[NSNotificationCenter defaultCenter] postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	return YES;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[controller release];
	[loggerage release];
	[preffer release];
	[colorLabel release];
	[super dealloc];
}

@end
