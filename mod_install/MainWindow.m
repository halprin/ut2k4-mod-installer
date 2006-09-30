#import "MainWindow.h"

@implementation MainWindow

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
	}
}

- (IBAction)installMod:(id)sender
{
	
}

@end
