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
	[[self window] close];
}

- (IBAction)ok:(id)sender
{
	if([color isEnabled]==YES)
	{
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
	else
	{
		[*labelColor autorelease];
		*labelColor=[[NSString stringWithString: @"0"] retain];
	}
	[[self window] close];
	
}

- (IBAction)enableColor:(id)sender
{
	if([sender state]==NSOnState)
	{
		[color setEnabled: YES];
	}
	else
	{
		[color setEnabled: NO];
	}
}

-(void)windowDidLoad
{
	if([*labelColor isEqualToString: @"0"]==NO)
	{
		[check setState: NSOnState];
		[color setEnabled: YES];
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
