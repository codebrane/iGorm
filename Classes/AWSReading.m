#import "AWSReading.h"

@implementation AWSReading

@synthesize readingDate;
@synthesize julianDay;
@synthesize meanWindSpeed;
@synthesize maxWindSpeed;
@synthesize minWindSpeed;
@synthesize windDirection;
@synthesize averageTemperature;

-(void)dealloc {
  [readingDate release];
  [julianDay release];
  [meanWindSpeed release];
  [maxWindSpeed release];
  [minWindSpeed release];
  [windDirection release];
  [averageTemperature release];
  [super dealloc];
}

@end
