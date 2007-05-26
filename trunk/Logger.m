//
//  Logger.m
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall on 2/3/07.
//  Copyright @PAK software 2007. All rights reserved.
//

#import "Logger.h"

@implementation Logger

-(Logger*)init
{
	if(self=[self initWithWindowNibName: @"InstallLog"])
	{
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowLoaded:) name: @"_NSWindowDidBecomeVisible" object: [self window]];
		data=[[LoggerDataSource alloc] init];
		[data retain];
	}
	return self;
}

- (IBAction)uninstall:(id)sender
{
	//not implemented yet
}

- (IBAction)view:(id)sender
{
	//get the file list for the selected mod and send it to the log listing sheet
	NSArray *files=[[log objectAtIndex: [table selectedRow]] objectForKey: @"files"];
	[lister populateListWithArray: files];
	//display that sheet!
	[NSApp beginSheet: [lister window] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
}

-(void)tableViewSelectionDidChange: (NSNotification*)notification
{
	if([table selectedRow]!=-1)  //an item is selected
	{
		[viewButton setEnabled: YES];
	}
	else  //no item is selected
	{
		[viewButton setEnabled: NO];
	}
}

-(void) windowLoaded: (NSNotification*) notification
{
	//set up the data source for the table
	[table setDelegate: self];
	[table setDoubleAction: @selector(view:)];
	[table setDataSource: data];
	[log autorelease];
	
	//read in the data from the log file and put it into the data source
	log=[[NSArray arrayWithContentsOfFile: [@"~/Library/Logs/com.atPAK.04ModInstallerLog.log" stringByExpandingTildeInPath]] retain];
	if(log!=nil)  //if the log file exists
	{
		NSDictionary *dict=nil;
		int lcv;
		for(lcv=0; lcv<[log count]; lcv++)
		{
			dict=[log objectAtIndex: lcv];
			[data addListing: [dict objectForKey: @"name"] withTime: [dict objectForKey: @"when"]];
		}
		
		//display the new data in the table
		[table reloadData];
	}
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[data release];
	[log release];
	[super dealloc];
}

@end
