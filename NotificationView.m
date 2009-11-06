#import "NotificationView.h"

@implementation NotificationView

@synthesize bgImage;

/*
 This routine is called at app launch time when this class is unpacked from the nib.
 */
- (void)awakeFromNib {
  // Load the images from the bundle's Resources directory
  self.bgImage = [NSImage imageNamed:@"bg"];
}

- (void)dealloc {
  [self.bgImage release];
  [super dealloc];
}

- (void)drawRect:(NSRect)rect {
  [[NSColor clearColor] set];
  NSRectFill([self frame]);
  [self.bgImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
  
  [[self window] setHasShadow:NO];
  [[self window] setHasShadow:YES];
}

@end
