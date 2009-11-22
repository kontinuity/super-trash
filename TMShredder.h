#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"

@class NotificationWindow;
@class NotificationView;
@class NotificationRowView;

@interface TMShredder : NSObject <SCEventListenerProtocol> {
  
  NSString *trashDirectory;
  NSArray *trashContents;
  NSMutableArray *notifiedTrashedFiles;
  
  NSPoint notificationWindowLocation;
  
  NSMutableArray *rows;
    
  IBOutlet NotificationWindow *notificationWindow;
  IBOutlet NotificationView *notificationView;
  IBOutlet NSButton *deleteAll;
  IBOutlet NSButton *close;
  IBOutlet NSTextField *others;
  IBOutlet NSTextField *counter;
  IBOutlet NSTextField *message;
  IBOutlet NSButton *info;
  IBOutlet NSWindow *about;
  
  int secondsSinceWindowOpen;
  BOOL holdingWindow;
}

@property (retain) NSString *trashDirectory;
@property (retain) NSArray *trashContents;
@property (assign) NSPoint notificationWindowLocation;
@property (retain) NSMutableArray *notifiedTrashedFiles;
@property (retain) NSMutableArray *rows;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) registerEvents;
- (void) scanTrash;
- (void) startTimerInBackgroundThread;
- (void) startTimer;
- (void) timerFiredInBackgroundThread;
- (void) playNiceWithSpaces;
- (void) initializeObjects;
- (void) initializePaths;
- (void) initializeWindow;
- (void) initializeRows;
- (void) addGUIDToSparkle;
- (NSString *) installationId;
- (void) setWindowSize: (NSSize) to;
- (void) setDefaultWindowSizeAndPosition;
- (NSArray *) trashSnapshot;
- (void) showNotification:(NSArray *) trashedFiles;
- (void) hideNotification;
- (void) showMessage: (NSString *) title;
- (NotificationRowView *) drawRowAt: (int) index with: (NSString *) file andHidden: (BOOL) hide;
- (void) update: (NotificationRowView *) row with: (NSString *) file;
- (void) showAll;
- (void) hideAll;
- (void) hideAllRows;
- (NSTextField *) createLabelWith: (NSString *) display;
- (NSButton *) createButtonWith: (NSString *) title;
- (NSImageView *) createImageViewWith: (NSString *) file;
- (IBAction) close: (id) sender;
- (IBAction) show: (id) sender;
- (IBAction) removeAll: (id) sender;
- (void) setOthersTitle: (NSString *) title;
- (void) updateCounter;
- (NSColor *) colorFromHexRGB:(NSString *) inColorString;
- (void) mouseEntered:(NSEvent *)theEvent;
- (void) mouseExited:(NSEvent *)theEvent;
- (void) holdWindow;
- (void) releaseWindow;
- (int) displayedFilesCount;
- (BOOL) deleteFileWith: (NSString *) fullPath;
- (IBAction) openAboutWindow: (id) sender;

@end
