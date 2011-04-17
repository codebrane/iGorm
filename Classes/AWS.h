#import <Foundation/Foundation.h>

typedef enum {
  kIntegrityOK = 0,
  kIntegrityConnectError,
  kIntegrityPageNotFound
} Integrity;

@interface AWS : NSObject <NSXMLParserDelegate> {
  // Integrity check
  NSInteger integrityStatus;
  
  // Latest status
  NSString *reportTime;
  NSString *reportStatus;
  NSString *latestReading;
  NSString *temperature;
  NSString *meanWindSpeed;
  NSString *gustWindSpeed;
  
  // Current readings
  NSNumber *maxTemperature;
  NSNumber *minTemperature;
  NSString *startDate;
  NSString *endDate;
  NSString *startTime;
  NSString *endTime;
  NSString *status;
  NSArray *averageTemperatureReadings;
  NSArray *meanWindReadings;
  NSArray *gustWindReadings;
  NSArray *awsReadings;
}

@property NSInteger integrityStatus;

@property (nonatomic, retain) NSString *reportTime;
@property (nonatomic, retain) NSString *reportStatus;
@property (nonatomic, retain) NSString *latestReading;
@property (nonatomic, retain) NSString *temperature;
@property (nonatomic, retain) NSString *meanWindSpeed;
@property (nonatomic, retain) NSString *gustWindSpeed;

@property (nonatomic, retain) NSNumber *maxTemperature;
@property (nonatomic, retain) NSNumber *minTemperature;
@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSArray *averageTemperatureReadings;
@property (nonatomic, retain) NSArray *meanWindReadings;
@property (nonatomic, retain) NSArray *gustWindReadings;
@property (nonatomic, retain) NSArray *awsReadings;

+ (AWS *)sharedAWS;

- (void)loadCurrentStatus;
- (void)loadLatestReadings;

@end
