#import "GraphsViewPlot.h"
#import "AWS.h"
#import "AWSReading.h"

@implementation GraphsViewPlot

@synthesize type;
@synthesize data;

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
  AWS *aws = [AWS sharedAWS];
  return [aws.awsReadings count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
  AWS *aws = [AWS sharedAWS];
  if (fieldEnum == CPScatterPlotFieldX) {
    AWSReading *awsReading = [aws.awsReadings objectAtIndex:index];
    AWSReading *awsStartReading = [aws.awsReadings objectAtIndex:0];
    return [NSNumber numberWithInt:[awsReading.readingDate timeIntervalSinceDate:awsStartReading.readingDate]];
  }
  else if (type == kReadingViewTypeTemperature) {
    NSLog(@"type == kReadingViewTypeTemperature");
    return [aws.averageTemperatureReadings objectAtIndex:index];
  }
  else if (type == kReadingViewTypeMeanWind) {
    NSLog(@"type == kReadingViewTypeMeanWind)");
    return [aws.meanWindReadings objectAtIndex:index];
  }
  else if (type == kReadingViewTypeWindGust) {
    NSLog(@"type == kReadingViewTypeWindGust");
    return [aws.gustWindReadings objectAtIndex:index];
  }
  else {
    return 0;
  }
}


- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:(NSCoder *)aDecoder]) {
    self.type = kReadingViewTypeTemperature;
    CGRect frame = self.bounds;
    chartView = [[CPLayerHostingView alloc] initWithFrame: frame];
    [self addSubview:chartView];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
  }
  return self;
}

-(void)drawRect:(CGRect)rect {
  graph = [[CPXYGraph alloc] initWithFrame: chartView.bounds];
  
  CPLayerHostingView *hostingView = (CPLayerHostingView *)chartView;
  hostingView.hostedLayer = graph;
  graph.paddingLeft = 40.0;
  graph.paddingTop = 30.0;
  graph.paddingRight = 30.0;
  graph.paddingBottom = 40.0;
  
  CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
  
  AWS* aws = [AWS sharedAWS];
  AWSReading *start = [aws.awsReadings objectAtIndex:0];
  AWSReading *end = [aws.awsReadings objectAtIndex:([aws.awsReadings count] - 1)];
  
  plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0)
                                                 length:CPDecimalFromFloat([end.readingDate timeIntervalSinceDate:start.readingDate])];
  
  if (type == kReadingViewTypeTemperature) {
    NSLog(@"kReadingViewTypeTemperature");
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-20)
                                                   length:CPDecimalFromFloat(45)];
  }
  
  if (type == kReadingViewTypeMeanWind) {
    NSLog(@"kReadingViewTypeMeanWind");
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0)
                                                   length:CPDecimalFromFloat(60)];
  }
  
  if (type == kReadingViewTypeWindGust) {
    NSLog(@"kReadingViewTypeWindGust");
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0)
                                                   length:CPDecimalFromFloat(100)];
  }
  
  CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
  
  CPTextStyle *whiteText = [CPTextStyle textStyle];
  whiteText.color = [CPColor whiteColor];              
  CPLineStyle *lineStyle = [CPLineStyle lineStyle];
  lineStyle.lineColor = [CPColor whiteColor];
  lineStyle.lineWidth = 2.0f;
  
  NSTimeInterval oneDay = 24 * 60 * 60;
  NSTimeInterval halfDay = 12 * 60 * 60;
  axisSet.xAxis.majorIntervalLength = CPDecimalFromFloat(oneDay);
  
  axisSet.xAxis.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
  
  axisSet.xAxis.minorTicksPerInterval = 6;
  axisSet.xAxis.axisLineStyle.lineColor = [CPColor whiteColor];
  axisSet.xAxis.majorTickLineStyle = lineStyle;
  axisSet.xAxis.minorTickLineStyle = lineStyle;
  axisSet.xAxis.axisLineStyle = lineStyle;
  axisSet.xAxis.labelTextStyle = whiteText;
  axisSet.xAxis.minorTickLength = 5.0f;
  axisSet.xAxis.majorTickLength = 7.0f;
  
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  dateFormatter.dateStyle = kCFDateFormatterShortStyle;
  NSLocale *ukLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"];
  [dateFormatter setLocale:ukLocale];
  CPTimeFormatter *timeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
  timeFormatter.referenceDate = start.readingDate;
  axisSet.xAxis.labelFormatter = timeFormatter;
  
  if (type == kReadingViewTypeTemperature) {
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"5");
  }
  if (type == kReadingViewTypeMeanWind) {
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"10");
  }
  if (type == kReadingViewTypeWindGust) {
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"10");
  }
  
  axisSet.yAxis.minorTicksPerInterval = 4;
  axisSet.yAxis.axisLineStyle.lineColor = [CPColor whiteColor];
  axisSet.yAxis.majorTickLineStyle = lineStyle;
  axisSet.yAxis.minorTickLineStyle = lineStyle;
  axisSet.yAxis.axisLineStyle = lineStyle;
  axisSet.yAxis.labelTextStyle = whiteText;
  axisSet.yAxis.minorTickLength = 5.0f;
  axisSet.yAxis.majorTickLength = 7.0f;
  
  CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
  greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor greenColor]];
  greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
  
  CPScatterPlot *xInversePlot = [[[CPScatterPlot alloc] init] autorelease];
  xInversePlot.identifier = @"X Inverse Plot";
  xInversePlot.dataLineStyle.lineWidth = 1.0f;
  xInversePlot.dataLineStyle.lineColor = [CPColor greenColor];
  xInversePlot.dataSource = self;
  [graph addPlot:xInversePlot];
}

- (void)dealloc {
  [super dealloc];
}

@end
