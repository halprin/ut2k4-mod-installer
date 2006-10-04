#import "Progress.h"

@implementation Progress
-(void) windowDidLoad
{
	NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(windowLoaded:) name: @"_NSWindowDidBecomeVisible" object: [self window]];
	
	//start animate the barber pole
	[progress_bar startAnimation: self];
	
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
	ut_path=path;
}

-(void) setMod: (NSString*) path
{
	mod_path=path;
}

-(void) setZU: (NSString*) zu
{
	zip_umod=zu;
}

-(void) windowLoaded: (NSNotification*) notification
{
	if([zip_umod isEqualToString: @"zip"])  //it is a zip mod
	{
		[self zip_install];
	}
	else if([zip_umod isEqualToString: @"umod"])  //it is a umod
	{
		[self umod_install];
	}
	
	//dismis the sheet
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
}

-(void) zip_install
{
	NSLog(@"Start ZIP install");
	
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
	//execute
	[task launch];
	NSData* data=[file readDataToEndOfFile];
	NSString *contents=[NSString stringWithUTF8String: [data bytes]];
	NSLog(contents);
}

-(void) umod_install
{
	NSLog(@"UMOD install not implemented yet");
}
@end