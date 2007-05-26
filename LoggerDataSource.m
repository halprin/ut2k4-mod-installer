//
//  LoggerDataSource.m
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall on 5/19/07.
//  Copyright 2007 @PAK software. All rights reserved.
//

#import "LoggerDataSource.h"


@implementation LoggerDataSource

-(LoggerDataSource*)init
{
	if(self=[super init])
	{
		fullset=[NSMutableArray array];
		[fullset retain];
	}
	return self;
}

-(int)numberOfRowsInTableView: (NSTableView*)aTableView
{
	return [fullset count];
}

-(id)tableView: (NSTableView*)aTableView objectValueForTableColumn: (NSTableColumn*)aTableColumn row: (int)rowIndex
{
	NSParameterAssert(rowIndex>=0 && rowIndex<[fullset count]);
	id theRecord=[fullset objectAtIndex: rowIndex];
	id theValue=[theRecord objectForKey: [aTableColumn identifier]];
	return theValue;
}

-(void)tableView: (NSTableView*)aTableView setObjectValue: (id)anObject forTableColumn: (NSTableColumn*)aTableColumn row: (int)rowIndex
{
	NSParameterAssert(rowIndex>=0 && rowIndex<[fullset count]);
	id theRecord=[fullset objectAtIndex: rowIndex];
	[theRecord setObject: anObject forKey: [aTableColumn identifier]];
}

-(void)addListing: (NSString*)name withTime: (NSString*)time
{
	//add a new dictionary to the master array with the name of the mod and time that it was installed
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	[dict setObject: name forKey: @"name"];
	[dict setObject: time forKey: @"time"];
	[fullset addObject: dict];
}

-(void)dealloc
{
	[fullset release];
	[super dealloc];
}

@end
