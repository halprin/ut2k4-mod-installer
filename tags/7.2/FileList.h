/* FileList */

#import <Cocoa/Cocoa.h>

@interface FileList : NSObject
{
    IBOutlet NSTextView *files;
    IBOutlet NSWindow *window;
}
- (IBAction)ok:(id)sender;
-(NSWindow*)window;
-(void)populateListWithArray: (NSArray*)array;
@end
