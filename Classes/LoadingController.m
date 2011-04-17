#import "LoadingController.h"
#import "iGormAppDelegate.h"
#import "AWS.h"
#import "ErrorViewController.h"

@implementation LoadingController

@synthesize activity;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [NSTimer scheduledTimerWithTimeInterval: 1
           target: self
         selector: @selector(handleTimer:)
         userInfo: nil
          repeats: NO];
  
  [activity startAnimating];
}

- (void) handleTimer: (NSTimer *) timer {
  AWS *aws = [AWS sharedAWS];
  iGormAppDelegate *appDelegate = (iGormAppDelegate *)[[UIApplication sharedApplication] delegate];
  [activity stopAnimating];
  
  if (aws.integrityStatus == kIntegrityOK) {
    [appDelegate.window insertSubview:appDelegate.rootController.view atIndex:0];
  }
  else {
    ErrorViewController *errorController = [[[ErrorViewController alloc] initWithNibName:@"ErrorView" bundle:nil] autorelease];
    [appDelegate.window insertSubview:errorController.view atIndex:0];
  }
  
  [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
  [activity release];
  [super dealloc];
}

@end
