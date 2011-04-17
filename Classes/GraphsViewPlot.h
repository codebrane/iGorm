#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "AWS.h"

typedef enum {
  kReadingViewTypeTemperature = 0,
  kReadingViewTypeMeanWind,
  kReadingViewTypeWindGust
} ReadingViewType;

@interface GraphsViewPlot : UIView <CPPlotDataSource> {
  NSInteger type;
  UIActivityIndicatorView *activityIndicator;
  CPGraphHostingView *chartView;
  CPXYGraph *graph;
  NSArray *data;
}

@property NSInteger type;
@property(nonatomic, retain) NSArray *data;

@end
