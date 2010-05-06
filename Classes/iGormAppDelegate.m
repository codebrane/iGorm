#import "iGormAppDelegate.h"
#import "LoadingController.h"

@implementation iGormAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize waiting;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  LoadingController *controller = [[LoadingController alloc] initWithNibName:@"Loading" bundle:nil];
  [window addSubview:controller.view];
  [controller release];
}

- (void)dealloc {
  [rootController release];
  [window release];
  [super dealloc];
}

@end

