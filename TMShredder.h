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
  NSTimer *timer;
  
  NSMutableArray *rows;
    
  IBOutlet NotificationWindow *notificationWindow;
  IBOutlet NotificationView *notificationView;
  IBOutlet NSButton *deleteAll;
  IBOutlet NSButton *close;
  IBOutlet NSTextField *others;
  IBOutlet NSTextField *counter;
}

@property (retain) NSString *trashDirectory;
@property (retain) NSArray *trashContents;
@property (assign) NSPoint notificationWindowLocation;
@property (retain) NSMutableArray *notifiedTrashedFiles;
@property (retain) NSTimer *timer;
@property (retain) NSMutableArray *rows;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) registerEvents;
- (void) scanTrash;
- (void) initializePaths;
- (void) initializeWindow;
- (void) initializeRows;
- (void) setWindowSize: (NSSize) to;
- (void) setDefaultWindowSizeAndPosition;
- (NSArray *) trashSnapshot;
- (void) showNotification:(NSArray *) trashedFiles;
- (void) hideNotification;
- (NotificationRowView *) drawRowAt: (int) index with: (NSString *) file andHidden: (BOOL) hide;
- (void) update: (NotificationRowView *) row with: (NSString *) file;
- (void) hideAllRows;
- (NSTextField *) createLabelWith: (NSString *) display;
- (NSButton *) createButtonWith: (NSString *) title;
- (NSImageView *) createImageViewWith: (NSString *) file;
- (IBAction) close: (id) sender;
- (IBAction) show: (id) sender;
- (IBAction) removeAll: (id) sender;
- (void) setOthersTitle: (NSString *) title;
- (void) setCounterTitle: (NSString *) title;
- (NSColor *) colorFromHexRGB:(NSString *) inColorString;

@end
