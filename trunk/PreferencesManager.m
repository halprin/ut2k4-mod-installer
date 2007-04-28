#import "PreferencesManager.h"

@implementation PreferencesManager

-(PreferencesManager*)initWithWindowNibName: (NSString*)nibName withPrefVar: (NSString**)label
{
	[*label retain];
	labelColor=label;
	
	return [self initWithWindowNibName: nibName];
}

- (IBAction)cancel:(id)sender
{
	//destroy it without setting anything
	[[self window] close];
}

- (IBAction)ok:(id)sender
{
	if([color isEnabled]==YES)  //is the checkbox checked?
	{
		//test what the item is chose in the drop down menu
		if([[color titleOfSelectedItem] isEqualToString: @"Red"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"2"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Orange"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"1"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Yellow"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"3"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Green"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"6"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Blue"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"4"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Purple"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"5"] retain];
		}
		else if([[color titleOfSelectedItem] isEqualToString: @"Gray"])
		{
			[*labelColor autorelease];
			*labelColor=[[NSString stringWithString: @"7"] retain];
		}
	}
	else  //it is not enabled and set it to 0 or nothing
	{
		[*labelColor autorelease];
		*labelColor=[[NSString stringWithString: @"0"] retain];
	}
	
	//close the window now
	[[self window] close];
}

- (IBAction)enableColor:(id)sender
{
	if([sender state]==NSOnState)  //it was just checked
	{
		[color setEnabled: YES];
	}
	else  //it was just unchecked
	{
		[color setEnabled: NO];
	}
}

-(void)windowDidLoad
{
	if([*labelColor isEqualToString: @"0"]==NO)  //the previous setting was set to a color
	{
		//put the checbox into a checked state and enable the drop down menu
		[check setState: NSOnState];
		[color setEnabled: YES];
		
		//set the drop down menu to the appropriate menu selection
		if([*labelColor isEqualToString: @"2"])
		{
			[color selectItemAtIndex: 0];
		}
		else if([*labelColor isEqualToString: @"1"])
		{
			[color selectItemAtIndex: 1];
		}
		else if([*labelColor isEqualToString: @"3"])
		{
			[color selectItemAtIndex: 2];
		}
		else if([*labelColor isEqualToString: @"6"])
		{
			[color selectItemAtIndex: 3];
		}
		else if([*labelColor isEqualToString: @"4"])
		{
			[color selectItemAtIndex: 4];
		}
		else if([*labelColor isEqualToString: @"5"])
		{
			[color selectItemAtIndex: 5];
		}
		else if([*labelColor isEqualToString: @"7"])
		{
			[color selectItemAtIndex: 6];
		}
	}
}

-(void)dealloc
{
	[*labelColor release];
	[super dealloc];
}

@end
