#import "MainWindow.h"

@implementation MainWindow

-(MainWindow*) init
{
	if(self=[super init])
	{
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		
		//get notification if one of the text boxes contents changes and set it to textChange:
		[center addObserver: self selector: @selector(textChange:) name: @"NSControlTextDidChangeNotification" object: mod_path];
		[center addObserver: self selector: @selector(textChange:) name: @"NSControlTextDidChangeNotification" object: ut_path];
		
		//get notification once the app has fully loaded
		[center addObserver: self selector: @selector(finishLoad:) name: @"NSApplicationDidFinishLaunchingNotification" object: nil];
	}
	return self;
}

- (IBAction)findMod:(id)sender
{
	NSButtonCell *zip=[zip_umod cellAtRow: 0 column: 0];
	NSButtonCell *umod=[zip_umod cellAtRow: 0 column: 1];
	NSString *path=@"-1";
	if([zip state]==1)  //ZIP is selected in the Radio control
	{
		NSLog(@"ZIP is selected so display open dialog for .zip files");
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
		NSLog(@"UMOD is selected so display open dialog for .ut4mod files");
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
	if(path!=@"-1")  //If the user clicked Cancel in the open dialog box
	{
		//set the mod location text box to the path
		[mod_path setStringValue: path];
		//send a notification that the text changed b/c the text box doesn't do it
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: mod_path];
	}
}

- (IBAction)findUT:(id)sender
{
	NSString *path=@"-1";
	NSLog(@"display open dialog for .app files");
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
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
}

- (IBAction)installMod:(id)sender
{
	//need to make sure that UT2k4 and the mod really exist as the user could
	//of entered the path manually
	NSFileManager *exists=[NSFileManager defaultManager];
	if([exists fileExistsAtPath: [ut_path stringValue]]==NO)  //UT2k4 does not exist
	{
		NSLog(@"UT2k4 doesn't exist!");
		NSBeginAlertSheet(@"UT2k4 does not exist!", @"OK", nil, nil, window, self, nil, nil, nil, @"UT2k4 does not exist at that location.  A way to make sure that it exists is by selecting it through the \"Browse...\" button.");
	}
	else  //UT2k4 does exist
	{
		if([exists fileExistsAtPath: [mod_path stringValue]]==NO)  //the mod does not exist
		{
			NSLog(@"Mod doesn't exist!");
			NSBeginAlertSheet(@"Mod does not exist!", @"OK", nil, nil, window, self, nil, nil, nil, @"The mod file that you specified does not exist.  A way to make sure that it exists is by selecting it through the \"Browse...\" button.");
		}
		else  //the mod does exist
		{
			//I might need to remove this next line possibly if the person wants to install another mod right after another
			if(controller==nil)  //if the controller hasn't been created yet
			{
				controller = [[Progress alloc] initWithWindowNibName: @"ProgressWindow"];
			}
			
			//pass the UT2k4 and mod path to the new progress window
			[controller setUT: [ut_path stringValue]];
			[controller setMod: [mod_path stringValue]];
			//tell the new progress window weather it is a zip or a umod we are doing
			if([[zip_umod cellAtRow: 0 column: 0] state]==1)  //ZIP is selected in the Radio control
			{
				[controller setZU: @"zip"];
			}
			else if([[zip_umod cellAtRow: 0 column: 1] state]==1)  //UMOD is selected in the Radio control
			{
				[controller setZU: @"umod"];
			}
			else  //This should never execute, if so, BUG!
			{
				NSLog(@"Bugzor!");
			} 
			
			//display the sheet!
			[NSApp beginSheet: [controller window] modalForWindow: window modalDelegate: self didEndSelector: nil contextInfo: nil];
		}
	}
}

-(void) textChange: (NSNotification*) notification
{
	if([[ut_path stringValue] length]!=0 && [[mod_path stringValue] length]!=0)  //both text boxes have text
	{
		NSLog(@"Enable the Install button");
		[install setEnabled: YES];
	}
	else //both text boxes have no text
	{
		NSLog(@"Disable the Install button");
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
		NSLog(@"New preferences exist");
		//get the dictionary and get the single key in there
		NSDictionary *root=[NSKeyedUnarchiver unarchiveObjectWithFile: [@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath]];
		NSString *path_temp=[root valueForKey: @"UTpath"];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
		//send a notification that the text changed b/c the text box doesn't do it
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
	else if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]]==YES)  //The UT2k4 location file exists
	{
		NSLog(@"UT2k4 location file exist");
		NSData *data=[prefs contentsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]];
		NSString *str=[NSString stringWithUTF8String: [data bytes]];
		//remove the last character which is a return
		NSString *path_temp=[[str substringToIndex: [str length]-1] stringByStandardizingPath];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
		
		//write the path to a new preference file
		NSMutableDictionary *root=[NSMutableDictionary dictionary];
		[root setValue: path_temp forKey: @"UTpath"];
		[NSKeyedArchiver archiveRootObject: root toFile: [[@"~/Library/Preferences/com.atPAK.04ModInstallerPrefs.plist" stringByExpandingTildeInPath] stringByExpandingTildeInPath]];
		//now delete the old pref file if they are there cause it sucks!
		BOOL deleted=[prefs removeFileAtPath: [@"~/Library/Preferences/Mod_installer_prefs.txt" stringByExpandingTildeInPath] handler: self];
		if(deleted==NO)
		{
			NSLog(@"Old preferences could not be deleted!");
		}
		
		//send a notification that the text changed b/c the text box doesn't do it
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
	else if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Preferences/Mod_installer_prefs.txt"]]==YES)  //The old prefs exist
	{
		NSLog(@"Old preferences exist");
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
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
}

@end