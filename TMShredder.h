#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"

@class NotificationWindow;
@class NotificationView;

@interface TMShredder : NSObject <SCEventListenerProtocol> {
  
  NSString *trashDirectory;
  NSMutableArray *trashContents;
  NSString *notifiedTrashedFile;  

  NSPoint notificationWindowLocation;
  NSTimer *notifyWindowTimer;
    
  IBOutlet NotificationWindow *notificationWindow;
  IBOutlet NotificationView *notificationView;
  IBOutlet NSButton *deleteAll;
  IBOutlet NSButton *close;
}

@property (retain) NSString *trashDirectory;
@property (retain) NSMutableArray *trashContents;
@property (assign) NSPoint notificationWindowLocation;
@property (retain) NSString *notifiedTrashedFile;
@property (retain) NSTimer *notifyWindowTimer;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) registerEvents;
- (void) scanTrash;
- (void) initializePaths;
- (void) initializeWindow;
- (void) setWindowSize: (NSSize) to;
- (void) setDefaultWindowSizeAndPosition;
- (NSArray *) trashSnapshot;
- (void) showNotification:(NSArray *) trashedFiles;
- (void) drawRowAt: (int) index with: (NSString *) file;
- (NSTextField *) createLabelWith: (NSString *) display;
- (NSButton *) createButtonWith: (NSString *) title;
- (NSImageView *) createImageViewWith: (NSString *) file;
- (IBAction) close: (id) sender;

@end
