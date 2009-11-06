#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"

@class NotificationWindow;
@interface TMShredder : NSObject <SCEventListenerProtocol> {
  NSString *trashDirectory;
  NSMutableArray *trashContents;
  IBOutlet NotificationWindow *notificationWindow;
  IBOutlet NSTextField *trashedFileLabel;
  NSPoint notificationWindowLocation;
  NSString *notifiedTrashedFile;
  NSTimer *notifyWindowTimer;
}

@property (retain) NSString *trashDirectory;
@property (retain) NSMutableArray *trashContents;
@property (retain) NotificationWindow *notificationWindow;
@property (retain) NSTextField *trashedFileLabel;
@property (assign) NSPoint notificationWindowLocation;
@property (retain) NSString *notifiedTrashedFile;
@property (retain) NSTimer *notifyWindowTimer;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) registerEvents;
- (void) scanTrash;
- (void) initializePaths;
- (NSArray *) trashSnapshot;
- (void) showNotification:(NSString *) trashedFile;
- (void) setNotificationWindowPosition;
- (IBAction) confirmDelete:(id) sender;

@end
