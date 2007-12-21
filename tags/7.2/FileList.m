#import "FileList.h"

@implementation FileList

- (IBAction)ok:(id)sender
{
	//set the textbox to nothing and close the sheet
	[files setString: @""];
	[[self window] orderOut: self];
	[NSApp endSheet: [self window] returnCode: 1];
}

-(NSWindow*)window
{
	return window;
}

-(void)populateListWithArray: (NSArray*)array
{
	//read through the array of files in the mod and populate the textbox w/ the result
	int lcv;
	for(lcv=0; lcv<[array count]; lcv++)
	{
		[[[files textStorage] mutableString] appendString: [array objectAtIndex: lcv]];
		[[[files textStorage] mutableString] appendString: @"\n"];
	}
}

@end
