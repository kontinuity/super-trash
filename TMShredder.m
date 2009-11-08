#import "TMShredder.h"
#import "Constants.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "NotificationWindow.h"
#import "NotificationView.h"

@implementation TMShredder

@synthesize trashDirectory, trashContents, notificationWindowLocation, notifiedTrashedFile, notifyWindowTimer;

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {

  [self initializePaths];
  [self initializeWindow];
  [self scanTrash];
  [self registerEvents];

  [self showNotification: [NSArray arrayWithObjects: @"bse.py", @"abcdefghijklmnopqrstuvwxyz", @"12345678901234567890" , nil]];
  
  NSLog(@"[%@] Application loaded successfully", [NSThread  currentThread]);
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

- (void) initializePaths {
  self.trashDirectory = [NSHomeDirectory() stringByAppendingString:@"/temp/shredder/"];
  NSLog(@"Done initializing trash locations. Location set to: %@", self.trashDirectory);
}

- (void) initializeWindow {
  [self setDefaultWindowSizeAndPosition];
  [notificationWindow setLevel:NSFloatingWindowLevel];
}

- (NSPoint) windowLocationFrom: (NSSize) size {
  
  NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
  NSLog(@"Screen resolutions detected as %@", NSStringFromSize(screenSize));
    
  /* 
   * Default Location is bottom right of screen cause its closest to the 
   * trash can where the users mouse will be
   */
  return NSMakePoint(screenSize.width - size.width - WINDOW_RIGHT_PAD, MAX(screenSize.height / 4, size.height + WINDOW_BOTTOM_PAD));
}

- (void) setDefaultWindowSizeAndPosition {
  [self setWindowSize:NSMakeSize(WINDOW_DEFAULT_WIDTH, WINDOW_DEFAULT_HEIGHT)];
}

- (void) setWindowSize: (NSSize) to {
  NSPoint toPoint = [self windowLocationFrom:to];
  
  NSLog(@"Calculated window location %@ from size %@", NSStringFromPoint(toPoint), NSStringFromSize(to));
  
  [notificationWindow setFrame: NSMakeRect(toPoint.x, toPoint.y, to.width, to.height) display:YES];
  [notificationView setFrame: NSMakeRect(0, 0, to.width, to.height)];
}

- (NSArray *) trashSnapshot {
  return [[NSFileManager defaultManager] directoryContentsAtPath: trashDirectory];
}

- (void) showNotification:(NSArray *) trashedFiles {
  
  //42 + (rows * (66 + 4)) - DELETE ALL + (rows * (ROW HEIGHT + PAD))
  
  int rowsToDisplay = [trashedFiles count] > 5 ? 5 : [trashedFiles count];
  [self setWindowSize:NSMakeSize(WINDOW_DEFAULT_WIDTH, 42 + (rowsToDisplay * (30 + 4)))];
  [deleteAll setFrameOrigin:NSMakePoint(77, 4)];
  [close setFrameOrigin:NSMakePoint(WINDOW_DEFAULT_WIDTH - 30, 16)];
  
  int index = 0;
  for (NSString *file in trashedFiles) {
    [self drawRowAt:index++ with:file];
  }
  
  [[NSAnimationContext currentContext] setDuration:0.5f];
  [[notificationWindow animator] setAlphaValue:1.0];
}

- (void) drawRowAt: (int) index with: (NSString *) file  {
  NSLog(@"Drawing label %@", file);

  int rowY = 50 + index * 24;
  
  NSImageView *imageView = [self createImageViewWith:file];
  [notificationView addSubview:imageView];
  [imageView setFrame: NSMakeRect(20, rowY, 16, 16)];  
  
  NSTextField *label = [self createLabelWith:file];
  [notificationView addSubview:label];
  [label setFrame: NSMakeRect(44, rowY, 120, 16)];
  
  NSButton *button = [self createButtonWith:file];
  [notificationView addSubview:button];
  [button setFrame: NSMakeRect(175, rowY, 70, 20)];
}

- (NSImageView *) createImageViewWith: (NSString *) file {
  NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[trashDirectory stringByAppendingString:file]];
  
  NSImageView *imageView = [[[NSImageView alloc] init] autorelease];
  [imageView setImage:iconImage];
  return imageView;
}

- (NSTextField *) createLabelWith: (NSString *) display {
  
  NSTextField *label = [[[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 120, 16)] autorelease];
  [label setEditable:NO];
  NSDictionary *attribs = [[[NSDictionary alloc] initWithObjectsAndKeys: 
                            [NSColor whiteColor], NSForegroundColorAttributeName, 
                            [NSFont fontWithName:@"Futura-Normal" size:14], NSFontAttributeName, 
                            nil] autorelease];
  [label setAttributedStringValue: [[NSAttributedString alloc] initWithString:display attributes: attribs]];
  [label setSelectable:NO];
  [label setBordered:NO];
  [label setDrawsBackground:NO];
  return label;
}

- (NSButton *) createButtonWith: (NSString *) title {
  NSButton *button = [[[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 70, 20)] autorelease];
  [button setButtonType:NSMomentaryChangeButton];
  [button setBezelStyle:NSSmallSquareBezelStyle];
  [button setBordered:NO];
  [button setTitle: title];
  [button setTarget: self];
  [button setImage:[NSImage imageNamed:@"delete_up"]];
  [button setAlternateImage:[NSImage imageNamed:@"delete_down"]];
  return button;
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

- (IBAction) close: (id) sender {
  NSLog(@"Close notif");
}

@end
