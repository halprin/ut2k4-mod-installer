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
	
}

-(void) textChange: (NSNotification*) notification
{
	if([[ut_path stringValue] length]!=0 && [[mod_path stringValue] length]!=0)
	{
		NSLog(@"Enable the Install button");
		[install setEnabled: YES];
	}
	else
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
	if([prefs fileExistsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]]==YES)  //The UT2k4 location file exists
	{
		NSLog(@"UT2k4 location file exist");
		NSData *data=[prefs contentsAtPath: [NSHomeDirectory() stringByAppendingString: @"/Library/Application Support/Unreal Tournament 2004/System/ut2k4path.ini"]];
		NSString *str=[NSString stringWithUTF8String: [data bytes]];
		//remove the last character which is a return
		NSString *path_temp=[[str substringToIndex: [str length]-1] stringByStandardizingPath];
		//set the UT2k4 location text box to the path
		[ut_path setStringValue: path_temp];
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
		//send a notification that the text changed b/c the text box doesn't do it
		NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
		[center postNotificationName: @"NSControlTextDidChangeNotification" object: ut_path];
	}
}

@end
