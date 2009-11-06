#import "TMShredder.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "NotificationWindow.h"

@implementation TMShredder

@synthesize trashDirectory, trashContents, notificationWindow, trashedFileLabel, notificationWindowLocation, notifiedTrashedFile, notifyWindowTimer;

- (void) initializePaths {
  NSLog(@"Trying to init...");
  trashDirectory = [NSHomeDirectory() stringByAppendingString:@"/temp/shredder/"];
}

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {
  [self initializePaths];
  [self setNotificationWindowPosition];
  [self scanTrash];
  [self registerEvents];
  [self showNotification:@"abc"];
  
  NSLog(@"[%@] Application loaded successfully", [NSThread  currentThread]);
}

- (void) setNotificationWindowPosition {
  NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
  NSLog(@"mainScreen frame = %@", NSStringFromSize(screenSize));
  [notificationWindow setFrameTopLeftPoint:NSMakePoint(screenSize.width - 315, MAX(screenSize.height / 4, 150))];
  NSLog(@"Window frame = %@", NSStringFromRect([notificationWindow frame]));
}

- (void) scanTrash {
  self.trashContents = [NSMutableArray arrayWithArray:[self trashSnapshot]];
}

- (void) registerEvents {
  SCEvents *events = [SCEvents sharedPathWatcher];
  [events setDelegate:self];
  
  NSMutableArray *paths = [NSMutableArray arrayWithObject:trashDirectory];
  
  [events startWatchingPaths:paths];
}

- (void) pathWatcher:(SCEvents *)pathWatcher eventOccurred: (SCEvent *)event {
  NSArray *trashState = [self trashSnapshot];
  
  NSLog(@"Current state of directory: %@", trashState);
  
  BOOL changed = [self.trashContents isEqualToArray: trashState];
  NSLog(@"%@", (changed ? @"YES" : @"NO"));
  
  NSMutableArray *trashedFiles = [NSMutableArray array];
  for (NSString *file in trashState) {
    if ([self.trashContents indexOfObject:file] == NSNotFound) {
      NSLog(@"New trashed file found: %@", file);
      [trashedFiles addObject:file];
    }
  }
  NSLog(@"Found total %d files", [trashedFiles count]);
  self.trashContents = [NSArray arrayWithArray:trashState];
  
  if ([trashedFiles count]) {
    [self showNotification:[trashedFiles objectAtIndex:0]];
  }
}

- (NSArray *) trashSnapshot {
  return [[NSFileManager defaultManager] directoryContentsAtPath: trashDirectory];
}

- (void) showNotification:(NSString *) trashedFile {
  [self.notifyWindowTimer invalidate];
  self.notifiedTrashedFile = trashedFile;
  [self.trashedFileLabel setStringValue:trashedFile];
  [notificationWindow makeKeyAndOrderFront:self];
  [notificationWindow setLevel:NSFloatingWindowLevel];
  [[NSAnimationContext currentContext] setDuration:0.5f];
  [[notificationWindow animator] setAlphaValue:1.0];
  self.notifyWindowTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideNotification) userInfo:NULL repeats:NO];
}

- (void) hideNotification {
  [self.notifyWindowTimer invalidate];
  [[NSAnimationContext currentContext] setDuration:0.5f];
  [[notificationWindow animator] setAlphaValue:0.0];
}

- (IBAction) confirmDelete:(id) sender {
  NSError *error;  
  NSString *fullPath = [self.trashDirectory stringByAppendingString:self.notifiedTrashedFile];
  if (![[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error]) {
    NSLog(@"Could not delete %@. Error was: %@", fullPath, [error localizedDescription]);
  }
  
  [self hideNotification];
}

@end
