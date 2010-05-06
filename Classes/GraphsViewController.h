#import <UIKit/UIKit.h>
#import "GraphsViewPlot.h"
#import "AWS.h"

typedef enum {
  kReadingTypeTemperature = 0,
  kReadingTypeMeanWind,
  kReadingTypeWindGust
} ReadingType;

@interface GraphsViewController : UIViewController {
  IBOutlet UILabel *readingsRangeLabel;
  IBOutlet UILabel *statusLabel;
  IBOutlet UISegmentedControl *readingTypeControl;
  IBOutlet GraphsViewPlot *readingView;
}

@property(nonatomic, retain) UILabel *readingsRangeLabel;
@property(nonatomic, retain) UILabel *statusLabel;
@property(nonatomic, retain) UISegmentedControl *readingTypeControl;
@property(nonatomic, retain) GraphsViewPlot *readingView;

-(IBAction)changeReadingType:(id)sender;

@end
