#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"

@interface TMShredder : NSObject <SCEventListenerProtocol> {
  NSString *trashDirectory;
  NSArray *trashContents;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) application:(NSApplication *)sender openFiles:(NSArray *)filenames;
- (BOOL) application:(NSApplication *)sender openFile:(NSString *)path;
- (void) registerEvents;
- (void) scanTrash;
- (void) init;

@end
