#import "GraphsViewController.h"
#import "GraphsViewPlot.h"
#import "AWS.h"
#import "AWSReading.h"

@implementation GraphsViewController

@synthesize readingsRangeLabel;
@synthesize statusLabel;
@synthesize readingTypeControl;
@synthesize readingView;

-(IBAction)changeReadingType:(id)sender {
  UISegmentedControl *control = (id)sender;
  NSInteger index = [control selectedSegmentIndex];
  
  switch (index) {
    case kReadingTypeTemperature:
      readingView.type = kReadingViewTypeTemperature;
      break;
    case kReadingTypeMeanWind:
      readingView.type = kReadingViewTypeMeanWind;
      break;
    case kReadingTypeWindGust:
      readingView.type = kReadingViewTypeWindGust;
      break;
    default:
      break;
  }
  
  [readingView setNeedsDisplay];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  AWS *aws = [AWS sharedAWS];
  AWSReading *start = [aws.awsReadings objectAtIndex:0];
  AWSReading *end = [aws.awsReadings objectAtIndex:([aws.awsReadings count] - 1)];
  readingsRangeLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", start.readingDate, end.readingDate];
  statusLabel.text = aws.status;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
  [super dealloc];
}

@end
