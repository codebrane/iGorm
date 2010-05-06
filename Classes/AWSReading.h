#import <Foundation/Foundation.h>

@interface AWSReading : NSObject {
  NSDate *readingDate;
  NSNumber *julianDay;
  NSNumber *meanWindSpeed;
  NSNumber *maxWindSpeed;
  NSNumber *minWindSpeed;
  NSNumber *windDirection;
  NSNumber *averageTemperature;
}

@property(nonatomic, retain) NSDate *readingDate;
@property(nonatomic, retain) NSNumber *julianDay;
@property(nonatomic, retain) NSNumber *meanWindSpeed;
@property(nonatomic, retain) NSNumber *maxWindSpeed;
@property(nonatomic, retain) NSNumber *minWindSpeed;
@property(nonatomic, retain) NSNumber *windDirection;
@property(nonatomic, retain) NSNumber *averageTemperature;

@end
