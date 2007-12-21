//
//  LoggerDataSource.h
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall on 5/19/07.
//  Copyright 2007 @PAK software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoggerDataSource : NSObject
{
	NSMutableArray *fullset;
}
-(LoggerDataSource*)init;
-(int)numberOfRowsInTableView: (NSTableView*)aTableView;
-(id)tableView: (NSTableView*)aTableView objectValueForTableColumn: (NSTableColumn*)aTableColumn row: (int)rowIndex;
-(void)tableView: (NSTableView*)aTableView setObjectValue: (id)anObject forTableColumn: (NSTableColumn*)aTableColumn row: (int)rowIndex;
-(void)addListing: (NSString*)name withTime: (NSString*)time;
-(void)dealloc;

@end
