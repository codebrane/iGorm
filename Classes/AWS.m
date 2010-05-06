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
  NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.phy.hw.ac.uk/resrev/aws/AWSRSS.xml"]];
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
		reportTime = [[NSString alloc] initWithString:buffer];
		
		// status
		parts = [string componentsSeparatedByString:@"AWS Status - "];
		// OK.  Latest ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@"."];
		buffer = [parts objectAtIndex:0];
    reportStatus = [[NSString alloc] initWithString:buffer];
		
		// Latest reading
		parts = [string componentsSeparatedByString:@"Latest reading at "];
		// 0548,  26 Apr Temperature ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@"Temperature"];
		buffer = [parts objectAtIndex:0];
		buffer = [buffer stringByReplacingOccurrencesOfString:@"  " withString:@" "];
		latestReading = [[NSString alloc] initWithString:buffer];
		
		// Temperature
		parts = [string componentsSeparatedByString:@"Temperature"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    temperature = [[NSString alloc] initWithString:buffer];
		
		// Mean Windspeed
		parts = [string componentsSeparatedByString:@"Mean Windspeed"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    meanWindSpeed = [[NSString alloc] initWithString:buffer];
		
		// Gust Windspeed
		parts = [string componentsSeparatedByString:@"Gust Windspeed"];
		//  2.1 C, ...
		buffer = [parts objectAtIndex:1];
		parts = [buffer componentsSeparatedByString:@","];
		buffer = [parts objectAtIndex:0];
    gustWindSpeed = [[NSString alloc] initWithString:buffer];
		
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
  
  NSURL *url = [NSURL URLWithString: @"http://www.phy.hw.ac.uk/resrev/aws/new_aws_data.htm"];
  NSError *error;
  
  NSMutableArray *awsReadingsTemp = [NSMutableArray array];
  
  NSMutableArray *averageTemperatureReadingsTemp = [NSMutableArray array];
  NSMutableArray *meanWindReadingsTemp = [NSMutableArray array];
  NSMutableArray *gustWindReadingsTemp = [NSMutableArray array];
  
  NSString *urlContents = [[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] autorelease];
  
  NSString *answer;
  NSScanner *myScanner = [NSScanner scannerWithString:urlContents];
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
      NSString *latestDate;
      int count = 0;
      for (int i=0; i < noOfReadings; i++) {
        NSString *temps = [readingData objectAtIndex:i];
        if ([temps length] > 2) {
          NSArray *temp = [[NSArray alloc] initWithArray:[temps componentsSeparatedByString:@","]];
          
          // First reading is the latest, so use that for the latest status
          NSString *statustemp = [temp objectAtIndex:10];
          if ([statustemp isEqual:@"1+2"]) {
            status = @"Status : Normal";
          }
          else {
            status = @"Status : FAULT";
          }
          
          int averageTemp = ([(NSString*)[temp objectAtIndex:8] intValue] + [(NSString*)[temp objectAtIndex:9] intValue]) / 2;
          int meanWind = [(NSString*)[temp objectAtIndex:3] intValue];
          int gustWind = [(NSString*)[temp objectAtIndex:4] intValue];
          
          NSNumber *nAverageTemp = [NSNumber numberWithInt:averageTemp];
          NSNumber *nMeanWind = [NSNumber numberWithInt:meanWind];
          NSNumber *nGustWind = [NSNumber numberWithInt:gustWind];
          
          AWSReading *awsReading = [[AWSReading alloc] init];
          
          // 2010-03-25'T'06:48Z
          int l = 5 - [[temp objectAtIndex:0] length];
          NSString *day = [[temp objectAtIndex:0] substringWithRange: NSMakeRange(0, (2 - l))];
          NSString *month = [[temp objectAtIndex:0] substringWithRange: NSMakeRange((2 - l), ([[temp objectAtIndex:0] length] - 1))];
          
          // 0548
          NSString *hour = [[temp objectAtIndex:2] substringWithRange: NSMakeRange(0, 2)];
          NSString *minute = [[temp objectAtIndex:2] substringWithRange: NSMakeRange(2, 2)];
          
          NSDateComponents *components = [[NSDateComponents alloc] init];
          [components setYear:2010];
          [components setMonth:[[months objectForKey:month] intValue]];
          [components setDay:[day intValue]];
          [components setHour:[hour intValue]];
          [components setMinute:[minute intValue]];
          NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
          awsReading.readingDate = [gregorian dateFromComponents:components];
          
          awsReading.julianDay = [temp objectAtIndex:1];
          awsReading.meanWindSpeed = [temp objectAtIndex:3];
          awsReading.maxWindSpeed = [temp objectAtIndex:4];
          awsReading.minWindSpeed = [temp objectAtIndex:5];
          awsReading.windDirection = [temp objectAtIndex:6];
          awsReading.averageTemperature = nAverageTemp;
          [awsReadingsTemp addObject:awsReading];
          
          NSString *date = [temp objectAtIndex:0];
          if (count == 0) {
            maxTemperature = [NSNumber numberWithInt:averageTemp];
            minTemperature = [NSNumber numberWithInt:averageTemp];
            latestDate = [[NSString alloc] initWithFormat:@"%@", date];
            // Readings are reverse chronological
            endDate = [[NSString alloc] initWithFormat:@"%@", date];
            endTime = [[NSString alloc] initWithFormat:@"%@", [temp objectAtIndex:2]];
          }
          else {
            if ([nAverageTemp compare:maxTemperature] == NSOrderedDescending) maxTemperature = [NSNumber numberWithInt:averageTemp];
            if ([nAverageTemp compare:minTemperature] == NSOrderedAscending) minTemperature = [NSNumber numberWithInt:averageTemp];
          }
          
          [averageTemperatureReadingsTemp addObject:nAverageTemp];
          [meanWindReadingsTemp addObject:nMeanWind];
          [gustWindReadingsTemp addObject:nGustWind];
          
          startDate = [[NSString alloc] initWithFormat:@"%@", date];
          startTime = [[NSString alloc] initWithFormat:@"%@", [temp objectAtIndex:2]];
          count++;
        } // if ([temps length] > 2) {
      }
    }
  }
  
  [urlContents release];
  
  averageTemperatureReadings = [[NSArray alloc] initWithArray:averageTemperatureReadingsTemp];
  meanWindReadings = [[NSArray alloc] initWithArray:meanWindReadingsTemp];
  gustWindReadings = [[NSArray alloc] initWithArray:gustWindReadingsTemp];
  awsReadings = [[NSArray alloc] initWithArray:[[awsReadingsTemp reverseObjectEnumerator] allObjects]];
}

- (NSArray *)getTemperatureData {
  NSURL *url = [NSURL URLWithString: @"http://www.phy.hw.ac.uk/resrev/aws/new_aws_data.htm"];
  NSError *error;
  NSMutableArray *readingData2 = [NSMutableArray array];
  NSString *urlContents = [[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] autorelease];
  
  NSString *answer;
  NSScanner *myScanner = [NSScanner scannerWithString:urlContents];
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
      NSString *latestDate;
      int count = 0;
      for (int i=0; i < noOfReadings; i++) {
        NSString *temps = [readingData objectAtIndex:i];
        if ([temps length] > 2) {
          NSArray *temp = [[NSArray alloc] initWithArray:[temps componentsSeparatedByString:@","]];
          int averageTemp = ([(NSString*)[temp objectAtIndex:8] intValue] + [(NSString*)[temp objectAtIndex:9] intValue]) / 2;
          NSNumber *nAverageTemp = [NSNumber numberWithInt:averageTemp];
          NSString *date = [temp objectAtIndex:0];
          if (count == 0) {
            maxTemperature = [NSNumber numberWithInt:averageTemp];
            minTemperature = [NSNumber numberWithInt:averageTemp];
            latestDate = [NSString stringWithFormat:@"%@", date];
            startDate = [NSString stringWithFormat:@"%@", date];
            startTime = [NSString stringWithFormat:@"%@", [temp objectAtIndex:2]];
          }
          else {
            if ([nAverageTemp compare:maxTemperature] == NSOrderedDescending) maxTemperature = [NSNumber numberWithInt:averageTemp];
            if ([nAverageTemp compare:minTemperature] == NSOrderedAscending) minTemperature = [NSNumber numberWithInt:averageTemp];
          }
          
          [readingData2 addObject:nAverageTemp];
          
          if (count == (noOfReadings - 1)) {
            endDate = [NSString stringWithFormat:@"%@", date];
            endTime = [NSString stringWithFormat:@"%@", [temp objectAtIndex:2]];
          }
          
          [temp release];
          count++;
        } // if ([temps length] > 2)
      } // for (int i=0; i < noOfReadings; i++)
    } // while (![myScanner isAtEnd])
    
    [urlContents release];
  }
  
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
