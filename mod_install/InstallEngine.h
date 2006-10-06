//
//  InstallEngine.h
//  UT2k4 Mod Installer
//
//  Created by Peter Kendall on 10/5/06.
//  Copyright 2006 @PAK sotware. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InstallEngine : NSObject
{

}
+(void) zip_install: (id) info;
+(void) umod_install: (id) info;
@end
