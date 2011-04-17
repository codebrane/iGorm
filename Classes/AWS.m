#import "AWS.h"
#import "AWSReading.h"
#import "SynthesizeSingleton.h"

@implementation AWS

SYNTHESIZE_SINGLETON_FOR_CLASS(AWS);

@synthesize integrityStatus;
@synthesize reportTime;
@synthesize reportStatus;
@synthesize latestReading;
@synthesize temperature;
@synthesize meanWindSpeed;
@synthesize gustWindSpeed;
@synthesize maxTemperature;
@synthesize minTemperature;
@synthesize startDate;
@synthesize endDate;
@synthesize startTime;
@synthesize endTime;
@synthesize status;
@synthesize averageTemperatureReadings;
@synthesize meanWindReadings;
@synthesize gustWindReadings;
@synthesize awsReadings;

BOOL inChannel;
BOOL inChannelDescription;
BOOL finished;


- (id)init {
  self = [super init];
  [self loadCurrentStatus];
  [self loadLatestReadings];
  self.integrityStatus = kIntegrityOK;
  return self;
}

- (void)loadCurrentStatus {
//  NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.phy.hw.ac.uk/resrev/aws/AWSRSS.xml"]];
  NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cairngormweather.eps.hw.ac.uk/AWSRSS.xml"]];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"channel"]) {
		inChannel = YES;
		return;
  }
	
	if (([elementName isEqualToString:@"item"]) || ([elementName isEqualToString:@"language"])) {
		inChannel = NO;
		inChannelDescription = NO;
		return;
	}
	
	if ([elementName isEqualToString:@"description"]) {
		if (inChannel) {
			inChannelDescription = YES;
		}
		return;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  /* The current reading is in the channel description:
	 * AWS Report issued at 07:15 on Sunday Apr 26, 2009.  AWS Status - OK.  Latest reading at 0548,  26 Apr Temperature 2.1 C, Mean Windspeed 7 mph, Gust Windspeed 8 mph.
	 */
	if (inChannelDescription) {
		if (finished) {
			return;
		}
    
		// Time of report
		NSArray* parts = [string componentsSeparatedByString:@"."];
		NSString* buffer = [parts objectAtIndex:0];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"AWS Report issued at " withString:@""];
    NSString *reportTimeHolder = [[NSString alloc] initWithString:buffer];
		self.reportTime = reportTimeHolder;
    [reportTimeHolder release];
		
		// status
		parts = [string componentsSeparatedByString:@"AWS Status - "];
		// OK.  Latest ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@"."];
		buffer = [parts objectAtIndex:0];
    NSString *reportStatusHolder = [[NSString alloc] initWithString:buffer];
    self.reportStatus = reportStatusHolder;
    [reportStatusHolder release];
		
		// Latest reading
		parts = [string componentsSeparatedByString:@"Latest reading at "];
		// 0548,  26 Apr Temperature ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@"Temperature"];
		buffer = [parts objectAtIndex:0];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSString *latestReadingHolder = [[NSString alloc] initWithString:buffer];
		self.latestReading = latestReadingHolder;
    [latestReadingHolder release];
		
		// Temperature
		parts = [string componentsSeparatedByString:@"Temperature"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    NSString *temperatureHolder = [[NSString alloc] initWithString:buffer];
    self.temperature = temperatureHolder;
    [temperatureHolder release];
		
		// Mean Windspeed
		parts = [string componentsSeparatedByString:@"Mean Windspeed"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    NSString *meanWindSpeedHolder = [[NSString alloc] initWithString:buffer];
    self.meanWindSpeed = meanWindSpeedHolder;
    [meanWindSpeedHolder release];
		
		// Gust Windspeed
		parts = [string componentsSeparatedByString:@"Gust Windspeed"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    NSString *gustWindSpeedHolder = [[NSString alloc] initWithString:buffer];
    self.gustWindSpeed = gustWindSpeedHolder;
    [gustWindSpeedHolder release];
		
		finished = YES;
  }
}


- (void)loadLatestReadings {
  NSMutableDictionary *months = [[NSMutableDictionary alloc] init];
  [months setObject:[NSNumber numberWithInt:1] forKey:@"Jan"];
  [months setObject:[NSNumber numberWithInt:2] forKey:@"Feb"];
  [months setObject:[NSNumber numberWithInt:3] forKey:@"Mar"];
  [months setObject:[NSNumber numberWithInt:4] forKey:@"Apr"];
  [months setObject:[NSNumber numberWithInt:5] forKey:@"May"];
  [months setObject:[NSNumber numberWithInt:6] forKey:@"Jun"];
  [months setObject:[NSNumber numberWithInt:7] forKey:@"Jul"];
  [months setObject:[NSNumber numberWithInt:8] forKey:@"Aug"];
  [months setObject:[NSNumber numberWithInt:9] forKey:@"Sep"];
  [months setObject:[NSNumber numberWithInt:10] forKey:@"Oct"];
  [months setObject:[NSNumber numberWithInt:11] forKey:@"Nov"];
  [months setObject:[NSNumber numberWithInt:12] forKey:@"Dec"];
  
  NSURL *url = [[NSURL alloc] initWithString:@"http://www.phy.hw.ac.uk/resrev/aws/new_aws_data.htm"];
  
  NSMutableArray *awsReadingsTemp = [NSMutableArray array];
  NSMutableArray *averageTemperatureReadingsTemp = [NSMutableArray array];
  NSMutableArray *meanWindReadingsTemp = [NSMutableArray array];
  NSMutableArray *gustWindReadingsTemp = [NSMutableArray array];
  
  NSError *error;
  NSString *urlContents = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  
  NSString *latestReadingsTextBlock;
  NSScanner *myScanner = [[NSScanner alloc] initWithString:urlContents];
  while (![myScanner isAtEnd]) {
    if ([myScanner scanUpToString:@"T2,Stat,  TH" intoString:NULL] &&
        [myScanner scanUpToString:@"</B>" intoString:NULL] &&
        [myScanner scanUpToString:@"</pre>" intoString:&latestReadingsTextBlock]) {
      NSString *data = [latestReadingsTextBlock stringByReplacingOccurrencesOfString: @"</B>" withString: @""];
      data = [data stringByReplacingOccurrencesOfString: @"</pre>" withString: @""];
      data = [data stringByReplacingOccurrencesOfString: @" " withString: @""];
      
      NSArray *readingData = [[NSArray alloc] initWithArray:[data componentsSeparatedByString:@"\n"]];
      
      // Date,   Day, Time, MeW, MaW, MiW, WDir, SDev,  T1,     T2,  Stat,  TH
      // 13 Mar, 73,  1248,   0,   0,   0,  90,   0,   15.8,   18.7, 1+1, 15.7
      
      int noOfReadings = [readingData count];
      int count = 0;
      bool first = true;
      
      for (int i=0; i < noOfReadings; i++) {
        NSString *dataLine = [readingData objectAtIndex:i];
        if ([dataLine length] > 2) {
          NSArray *dataLineParts = [[NSArray alloc] initWithArray:[dataLine componentsSeparatedByString:@","]];
          
          // First reading is the latest, so use that for the latest status
          if (first) {
            NSString *statustemp = [dataLineParts objectAtIndex:10];
            if ([statustemp isEqual:@"1+2"]) {
              status = @"Status : Normal";
            }
            else {
              status = @"Status : FAULT";
            }
            first = false;
          }
          
          int averageTemp = ([(NSString*)[dataLineParts objectAtIndex:8] intValue] + [(NSString*)[dataLineParts objectAtIndex:9] intValue]) / 2;
          int meanWind = [(NSString*)[dataLineParts objectAtIndex:3] intValue];
          int gustWind = [(NSString*)[dataLineParts objectAtIndex:4] intValue];
          
          NSNumber *nAverageTemp = [[NSNumber alloc] initWithInt:averageTemp];
          NSNumber *nMeanWind = [[NSNumber alloc] initWithInt:meanWind];
          NSNumber *nGustWind = [[NSNumber alloc] initWithInt:gustWind];
          
          AWSReading *awsReading = [[AWSReading alloc] init];
          
          // 17Apr
          int l = 5 - [[dataLineParts objectAtIndex:0] length];
          NSString *day = [[dataLineParts objectAtIndex:0] substringWithRange: NSMakeRange(0, (2 - l))];
          NSString *month = [[dataLineParts objectAtIndex:0] substringWithRange: NSMakeRange((2 - l), ([[dataLineParts objectAtIndex:0] length] - 2))];
          
          // 0548
          NSString *hour = [[dataLineParts objectAtIndex:2] substringWithRange: NSMakeRange(0, 2)];
          NSString *minute = [[dataLineParts objectAtIndex:2] substringWithRange: NSMakeRange(2, 2)];
          
          NSDateComponents *components = [[NSDateComponents alloc] init];
          [components setYear:2010];
          [components setMonth:[[months objectForKey:month] intValue]];
          [components setDay:[day intValue]];
          [components setHour:[hour intValue]];
          [components setMinute:[minute intValue]];
          NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
          awsReading.readingDate = [gregorian dateFromComponents:components];
          [components release];
          [gregorian release];
          
          awsReading.julianDay = [dataLineParts objectAtIndex:1];
          awsReading.meanWindSpeed = [dataLineParts objectAtIndex:3];
          awsReading.maxWindSpeed = [dataLineParts objectAtIndex:4];
          awsReading.minWindSpeed = [dataLineParts objectAtIndex:5];
          awsReading.windDirection = [dataLineParts objectAtIndex:6];
          awsReading.averageTemperature = nAverageTemp;
          [awsReadingsTemp addObject:awsReading];
          
          NSString *date = [dataLineParts objectAtIndex:0];
          if (count == 0) {
            NSNumber *maxTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
            self.maxTemperature = maxTemperatureHolder;
            [maxTemperatureHolder release];
            
            NSNumber *minTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
            self.minTemperature = minTemperatureHolder;
            [minTemperatureHolder release];
            
            // Readings are reverse chronological
            NSString *endDateHolder = [[NSString alloc] initWithFormat:@"%@", date];
            self.endDate = endDateHolder;
            [endDateHolder release];
            
            NSString *endTimeHolder = [[NSString alloc] initWithFormat:@"%@", [dataLineParts objectAtIndex:2]];
            self.endTime = endTimeHolder;
            [endTimeHolder release];
          }
          else {
            if ([nAverageTemp compare:maxTemperature] == NSOrderedDescending) {
              NSNumber *maxTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
              self.maxTemperature = maxTemperatureHolder;
              [maxTemperatureHolder release];
            }
            if ([nAverageTemp compare:minTemperature] == NSOrderedAscending) {
              NSNumber *minTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
              self.minTemperature = minTemperatureHolder;
              [minTemperatureHolder release];
            }
          }
          
          [averageTemperatureReadingsTemp addObject:nAverageTemp];
          [meanWindReadingsTemp addObject:nMeanWind];
          [gustWindReadingsTemp addObject:nGustWind];
          
          NSString *startDateHolder = [[NSString alloc] initWithFormat:@"%@", date];
          self.startDate = startDateHolder;
          [startDateHolder release];
          
          NSString *startTimeHolder = [[NSString alloc] initWithFormat:@"%@", [dataLineParts objectAtIndex:2]];
          self.startTime = startTimeHolder;
          [startTimeHolder release];
          
          [nAverageTemp release];
          [nMeanWind release];
          [nGustWind release];
          
          count++;
        } // if ([temps length] > 2) {
      } // for (int i=0; i < noOfReadings; i++)
      
      [readingData release];
    } // if ([myScanner scanUpToString:@"T2,Stat,  TH" intoString:NULL] &&
  } // while (![myScanner isAtEnd])
  
  NSArray *averageTemperatureReadingsHolder = [[NSArray alloc] initWithArray:averageTemperatureReadingsTemp];
  self.averageTemperatureReadings = averageTemperatureReadingsHolder;
  [averageTemperatureReadingsHolder release];
  
  NSArray *meanWindReadingsHolder = [[NSArray alloc] initWithArray:meanWindReadingsTemp];
  self.meanWindReadings = meanWindReadingsHolder;
  [meanWindReadingsHolder release];
  
  NSArray *gustWindReadingsHolder = [[NSArray alloc] initWithArray:gustWindReadingsTemp];
  self.gustWindReadings = gustWindReadingsHolder;
  [gustWindReadingsHolder release];
  
  NSArray *awsReadingsHolder = [[NSArray alloc] initWithArray:[[awsReadingsTemp reverseObjectEnumerator] allObjects]];
  self.awsReadings = awsReadingsHolder;
  [awsReadingsHolder release];
  
  [myScanner release];
  [months release];
  [url release];
  [urlContents release];
}

- (NSArray *)getTemperatureData {
  NSURL *url = [[NSURL alloc] initWithString:@"http://www.phy.hw.ac.uk/resrev/aws/new_aws_data.htm"];
  
  NSMutableArray *readingData2 = [NSMutableArray array];
  
  NSError *error;
  NSString *urlContents = [[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] autorelease];
  
  NSString *answer;
  NSScanner *myScanner = [[NSScanner alloc] initWithString:urlContents];
  
  while (![myScanner isAtEnd]) {
    if ([myScanner scanUpToString:@"T2,Stat,  TH" intoString:NULL] &&
        [myScanner scanUpToString:@"</B>" intoString:NULL] &&
        [myScanner scanUpToString:@"</pre>" intoString:&answer]) {
      NSString *data = [answer stringByReplacingOccurrencesOfString: @"</B>" withString: @""];
      data = [data stringByReplacingOccurrencesOfString: @"</pre>" withString: @""];
      data = [data stringByReplacingOccurrencesOfString: @" " withString: @""];
      
      NSArray *readingData = [[NSArray alloc] initWithArray:[data componentsSeparatedByString:@"\n"]];
      
      // Date,   Day, Time, MeW, MaW, MiW, WDir, SDev,  T1,     T2,  Stat,  TH
      // 13 Mar, 73,  1248,   0,   0,   0,  90,   0,   15.8,   18.7, 1+1, 15.7
      
      int noOfReadings = [readingData count];
      int count = 0;
      
      for (int i=0; i < noOfReadings; i++) {
        NSString *temps = [readingData objectAtIndex:i];
        if ([temps length] > 2) {
          NSArray *temp = [[NSArray alloc] initWithArray:[temps componentsSeparatedByString:@","]];
          int averageTemp = ([(NSString*)[temp objectAtIndex:8] intValue] + [(NSString*)[temp objectAtIndex:9] intValue]) / 2;
          
          NSNumber *nAverageTemp = [[NSNumber alloc] initWithInt:averageTemp];
          NSString *date = [temp objectAtIndex:0];
          
          if (count == 0) {
            NSNumber *maxTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
            self.maxTemperature = maxTemperatureHolder;
            [maxTemperatureHolder release];
            
            NSNumber *minTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
            self.minTemperature = minTemperatureHolder;
            [minTemperatureHolder release];
            
            NSString *startDateHolder = [[NSString alloc] initWithFormat:@"%@", date];
            self.startDate = startDateHolder;
            [startDateHolder release];
            
            NSString *startTimeHolder = [[NSString alloc] initWithFormat:@"%@", [temp objectAtIndex:2]];
            self.startTime = startTimeHolder;
            [startTimeHolder release];
          }
          else {
            if ([nAverageTemp compare:maxTemperature] == NSOrderedDescending) {
              NSNumber *maxTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
              self.maxTemperature = maxTemperatureHolder;
              [maxTemperatureHolder release];
            }
            
            if ([nAverageTemp compare:minTemperature] == NSOrderedAscending) {
              NSNumber *minTemperatureHolder = [[NSNumber alloc] initWithInt:averageTemp];
              self.minTemperature = minTemperatureHolder;
              [minTemperatureHolder release];
            }
          }
       
          [readingData2 addObject:nAverageTemp];
          
          if (count == (noOfReadings - 1)) {
            NSString *endDateHolder = [[NSString alloc] initWithFormat:@"%@", date];
            self.endDate = endDateHolder;
            [endDateHolder release];
            
            NSString *endTimeHolder = [[NSString alloc] initWithFormat:@"%@", [temp objectAtIndex:2]];
            self.endTime = endTimeHolder;
            [endTimeHolder release];
          }
          
          [temp release];
          [nAverageTemp release];
          
          count++;
        } // if ([temps length] > 2)
      } // for (int i=0; i < noOfReadings; i++)
      
      [readingData release];
    } // if ([myScanner scanUpToString:@"T2,Stat,  TH" intoString:NULL] &&
    
    [url release];
    [urlContents release];
    [myScanner release];
  } // while (![myScanner isAtEnd])
  
  return readingData2;
}

- (void)  dealloc {
  [reportTime release];
  [reportStatus release];
  [latestReading release];
  [temperature release];
  [meanWindSpeed release];
  [gustWindSpeed release];
  [maxTemperature release];
  [minTemperature release];
  [startDate release];
  [endDate release];
  [startTime release];
  [endTime release];
  [status release];
  [averageTemperatureReadings release];
  [meanWindReadings release];
  [gustWindReadings release];
  
  [super dealloc];
}

@end
