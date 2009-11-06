#import "TMShredder.h"
#import "SCEvents.h"
#import "SCEvent.h"

@implementation TMShredder

- (void) init {
  trashDirectory = [NSHomeDirectory() stringByAppendingString:@"/.Trash"];
  trashContents = [NSMutableArray array];
}

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {
  [self init];
  [self registerEvents];
  [self scanTrash];
  NSLog(@"[%@] Application loaded successfully", [NSThread  currentThread]);
}

- (void) application:(NSApplication *)sender openFiles:(NSArray *)filenames {
  NSLog(@"[%@]", filenames);
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)path {
  NSLog(@"[%@]", path);
  return YES;
}

- (void) scanTrash {
  trashContents = [NSMutableArray arrayWithArray: [[NSFileManager defaultManager] directoryContentsAtPath: trashDirectory]];
  NSLog(@"%@", trashContents);
}

- (void) registerEvents {
  SCEvents *events = [SCEvents sharedPathWatcher];
  [events setDelegate:self];
  
  NSMutableArray *paths = [NSMutableArray arrayWithObject:trashDirectory];
  
  [events startWatchingPaths:paths];
}

- (void) pathWatcher:(SCEvents *)pathWatcher eventOccurred: (SCEvent *)event {
  NSLog(@"%@", event);
}

@end
