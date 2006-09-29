#import "MainWindow.h"

@implementation MainWindow

- (IBAction)findMod:(id)sender
{
	NSButtonCell *zip=[zip_umod cellAtRow: 0 column: 0];
	NSButtonCell *umod=[zip_umod cellAtRow: 0 column: 1];
	NSString *path=@"";
	if([zip state]==1)
	{
		NSLog(@"ZIP is selected so display open dialog for .zip files");
		path=@"ChaosUT2.zip";
	}
	else if([umod state]==1)
	{
		NSLog(@"UMOD is selected so display open dialog for .ut4mod files");
		path=@"ChaosUT2.ut4mod";
	}
	else
	{
		NSLog(@"Bugzor!");
	}
	[mod_path setStringValue: path];
}

- (IBAction)findUT:(id)sender
{
	NSString *path=@"Kendall/Users/halprin/Desktop/Peter/Unreal Tournament 2004/Unreal Tournament 2004.app/";
	[ut_path setStringValue: path];
}

- (IBAction)installMod:(id)sender
{
	
}

@end
