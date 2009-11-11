#import "TMShredder.h"
#import "Constants.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "NotificationWindow.h"
#import "NotificationView.h"
#import "NotificationRowView.h"

@implementation TMShredder

@synthesize trashDirectory, trashContents, notificationWindowLocation, notifiedTrashedFiles, timer, rows;

- (void) registerDefaults {
  [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"windowDisplayDuration"];
}

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification {
  [self registerDefaults];  
  [self initializePaths];
  [self initializeWindow];
  [self initializeRows];
  [self scanTrash];
  [self registerEvents];
  [self startTimerInBackgroundThread];
  
  [self showNotification: [NSArray arrayWithObjects: @"bse.py", @"Lorem big text", @"ipsum jumped", @"dolor over the", 
                           @"sit rainbow while", @"amet drinking a glass", @"consectetur of whisky on", @"adipisicing the rocks", @"elit and got drunk", nil]];
  
  NSLog(@"[%@] Application loaded successfully", [NSThread  currentThread]);
}

- (void) startTimerInBackgroundThread {
  [self performSelectorInBackground:@selector(startTimer) withObject:NULL];
}
  
- (void) startTimer {
  NSLog(@"About to start timer");
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSTimer *localTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFiredInBackgroundThread) userInfo:NULL repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:[localTimer retain] forMode:NSDefaultRunLoopMode];
  [self timerFiredInBackgroundThread];
  [[NSRunLoop currentRunLoop] run];
  [pool release];
}
  
- (void) timerFiredInBackgroundThread {
  [self performSelectorOnMainThread:@selector(timerFired) withObject:self waitUntilDone:NO];
}

- (void) timerFired {
  
  if (holdingWindow)
    return;
  
  int duration = [[NSUserDefaults standardUserDefaults] integerForKey: @"windowDisplayDuration"];
  if (secondsSinceWindowOpen >= duration) {
    [self hideNotification];
  } else {
    [self updateCounter];
    secondsSinceWindowOpen++;
  }  
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

- (void) initializeRows {
  
  self.rows = [[NSMutableArray alloc] initWithCapacity:MAX_ROWS];
  
  for (int index = 0; index < MAX_ROWS; index++) {
    NotificationRowView *row = [self drawRowAt:index with:@"" andHidden:YES];
    [self.rows insertObject:row atIndex:index];
  }
  
}

- (NSPoint) windowLocationFrom: (NSSize) size {
  
  NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
    
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
  [notificationWindow setFrame: NSMakeRect(toPoint.x, toPoint.y, to.width, to.height) display:YES];
  [notificationView setFrame: NSMakeRect(0, 0, to.width, to.height)];
}

- (NSArray *) trashSnapshot {
  return [[NSFileManager defaultManager] directoryContentsAtPath: trashDirectory];
}

- (void) showNotification:(NSArray *) trashedFiles {
  
  [self hideAllRows];
  
  if ([trashedFiles count] == 0) {
    [self hideNotification];
    return;
  }
  
  int rowsToDisplay = MIN(MAX_ROWS, [trashedFiles count]);
  
  //42 + (rows * (66 + 4)) - DELETE ALL + (rows * (ROW HEIGHT + PAD))
  NSSize calculatedWindowSize = NSMakeSize(WINDOW_DEFAULT_WIDTH, 60 + (rowsToDisplay * (30 + 4)));
  [self setWindowSize: calculatedWindowSize];
  [deleteAll setFrameOrigin:NSMakePoint(77, 4)];
  [close setFrameOrigin:NSMakePoint(WINDOW_DEFAULT_WIDTH - 30, 16)];  
  [others setFrameOrigin:NSMakePoint(WINDOW_DEFAULT_WIDTH - 80, 40)];
    
  for (int index = 0; index < rowsToDisplay; index++) {
    [self update: [self.rows objectAtIndex:index] with:[trashedFiles objectAtIndex:index]];
  }
  
  [others setHidden:YES];
  if ([trashedFiles count] > MAX_ROWS) {
    int displayCount = [trashedFiles count] - MAX_ROWS;
    NSString *title = [NSString stringWithFormat:@"and %i others", displayCount];
    [self setOthersTitle: title];
    [others setHidden:NO];
  }  
    
  self.notifiedTrashedFiles = [[NSMutableArray alloc] initWithArray: trashedFiles];
  
  [[NSAnimationContext currentContext] setDuration:0.5f];
  [[notificationWindow animator] setAlphaValue:1.0];
  secondsSinceWindowOpen = 0;
  [self updateCounter];
}

- (void) hideNotification {
  [timer invalidate];
  [[NSAnimationContext currentContext] setDuration:0.5f];
  [[notificationWindow animator] setAlphaValue:0.0];  
  
}

- (void) update: (NotificationRowView *) row with: (NSString *) file {
  NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[trashDirectory stringByAppendingString:file]];
  [row.image setImage:iconImage];

  NSDictionary *attribs = [[[NSDictionary alloc] initWithObjectsAndKeys: 
                            [NSColor whiteColor], NSForegroundColorAttributeName, 
                            [NSFont fontWithName:@"Futura-Normal" size:14], NSFontAttributeName, 
                            nil] autorelease];
  
  NSString *title = file;
  if ([file length] > LABEL_MAX_LENGTH) {
    NSMutableString *str = [NSMutableString stringWithString:file];
    [str replaceCharactersInRange: NSMakeRange(LABEL_MAX_LENGTH - 3, [str length] - LABEL_MAX_LENGTH) 
                        withString: @"..."];
    title = str;
  }
  
  
  [row.label setAttributedStringValue: [[[NSAttributedString alloc] initWithString:title attributes: attribs] autorelease]];
  [row setHidden:NO];
}

- (void) hideAllRows {
  for (NotificationRowView *row in self.rows) {
    [row setHidden:YES];
  }
}

- (NotificationRowView *) drawRowAt: (int) index with: (NSString *) file andHidden: (BOOL) hide  {
  
  int rowY = 60 + index * 24;
  
  NotificationRowView *row = [[[NotificationRowView alloc] initWithFrame: NSMakeRect(0, 0, 0, 0)] autorelease];
  
  NSImageView *imageView = [self createImageViewWith:file];
  [row addSubview:imageView];
  row.image = imageView;
  [imageView setFrame: NSMakeRect(20, 0, 16, 16)];
  
  NSTextField *label = [self createLabelWith:file];
  [row addSubview:label];
  row.label = label;
  [label setFrame: NSMakeRect(44, 0, 120, 16)];  
  
  NSButton *button = [self createButtonWith:file];
  [row addSubview:button];
  row.button = button;
  [button setFrame: NSMakeRect(175, 0, 70, 20)];
  
  [notificationView addSubview:row];
  [row setFrame: NSMakeRect(0, rowY, 265, 20)];
  
  [row setHidden:hide];
  return row;
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

  [label setAttributedStringValue: [[[NSAttributedString alloc] initWithString:display attributes: attribs] autorelease]];
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
  [button setAction:@selector(remove:)];
  [button setImage:[NSImage imageNamed:@"delete_up"]];
  [button setAlternateImage:[NSImage imageNamed:@"delete_down"]];
  return button;
}

- (void) pathWatcher:(SCEvents *)pathWatcher eventOccurred: (SCEvent *)event {
  NSArray *trashState = [self trashSnapshot];
  
  NSMutableArray *trashedFiles = [NSMutableArray array];
  for (NSString *file in trashState) {
    if ([self.trashContents indexOfObject:file] == NSNotFound) {
      [trashedFiles addObject:file];
    }
  }
  NSLog(@"Found total %d changed files", [trashedFiles count]);
  self.trashContents = [NSArray arrayWithArray:trashState];
  
  if ([trashedFiles count]) {
    [self showNotification:trashedFiles];
  }
}

- (IBAction) close: (id) sender {
  [self hideNotification];
}

- (IBAction) show: (id) sender {
  [self showNotification: [NSArray arrayWithObjects: @"MYDirectoryWatcher.m", @"domain_mapping.php", nil]];
}

- (void) remove: (id) sender {
  
  NotificationRowView *row = (NotificationRowView *) [sender superview];
  int fileIndex = [self.rows indexOfObject:row];
  [self.notifiedTrashedFiles removeObjectAtIndex:fileIndex];
  [self showNotification:self.notifiedTrashedFiles];
  
}

- (IBAction) removeAll: (id) sender {
  [self.notifiedTrashedFiles removeAllObjects];
  [self hideNotification];
}

- (void) setOthersTitle: (NSString *) title {
  NSDictionary *attribs = [[[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSColor whiteColor], NSForegroundColorAttributeName,
                            [NSFont fontWithName:@"Futura-Normal" size:12], NSFontAttributeName,
                            nil] autorelease];
  
  [others setAttributedStringValue: [[[NSAttributedString alloc] initWithString:title attributes: attribs] autorelease]];  
}

- (void) updateCounter {
  
  int filesShown = [self displayedFilesCount];
  int fontSize = (108 * filesShown) / MAX_ROWS;

  NSDictionary *attribs = [[[NSDictionary alloc] initWithObjectsAndKeys:
                            [self colorFromHexRGB:@"0x747474"], NSForegroundColorAttributeName,
                            [NSFont fontWithName:@"Helvetica Bold" size:fontSize], NSFontAttributeName,
                            nil] autorelease];
  
  int duration = [[NSUserDefaults standardUserDefaults] integerForKey: @"windowDisplayDuration"];
  [counter setAttributedStringValue: [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", duration - secondsSinceWindowOpen] attributes: attribs] autorelease]];
  
  NSRect deleteAllFrame = [deleteAll frame];
  [counter sizeToFit];
  [counter setFrameOrigin:NSMakePoint(110, deleteAllFrame.origin.y + deleteAllFrame.size.height + 5)];
}

- (int) displayedFilesCount {
  return MIN([notifiedTrashedFiles count], MAX_ROWS);
}

- (NSColor *) colorFromHexRGB:(NSString *) inColorString {
  NSColor *result = nil;
  unsigned int colorCode = 0;
  unsigned char redByte, greenByte, blueByte;
  
  if (nil != inColorString) {
    NSScanner *scanner = [NSScanner scannerWithString:inColorString];
    (void) [scanner scanHexInt:&colorCode];	// ignore error
  }
  
  redByte		= (unsigned char) (colorCode >> 16);
  greenByte	= (unsigned char) (colorCode >> 8);
  blueByte	= (unsigned char) (colorCode);	// masks off high bits
  result = [NSColor
            colorWithCalibratedRed:		(float)redByte	/ 0xff
            green:	(float)greenByte/ 0xff
            blue:	(float)blueByte	/ 0xff
            alpha:0.3];
  return result;
}

- (void)mouseEntered:(NSEvent *)theEvent {
  [self holdWindow];
}

- (void)mouseExited:(NSEvent *)theEvent {
  [self releaseWindow];
}

- (void) holdWindow {
  holdingWindow = YES;
}

- (void) releaseWindow {
  holdingWindow = NO;
}

@end
