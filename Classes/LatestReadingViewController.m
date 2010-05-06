#import "LatestReadingViewController.h"
#import "AWS.h"

@implementation LatestReadingViewController

NSArray *sectionNames;

- (void)viewDidLoad {
  [super viewDidLoad];
  sectionNames = [[NSArray arrayWithObjects:@"Date", @"Status", @"Latest Reading", @"Temperature", @"Mean Wind Speed", @"Gust Wind Speed", nil] retain];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
  [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger section = [indexPath section];
  
  static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:SectionsTableIdentifier] autorelease];
  }
  
  AWS *aws = [AWS sharedAWS];
  
  switch (section) {
    case 0:
      [cell textLabel].text = aws.reportTime;
      break;
    case 1:
      [cell textLabel].text = aws.status;
      break;
    case 2:
      [cell textLabel].text = aws.latestReading;
      break;
    case 3:
      [cell textLabel].text = aws.temperature;
      break;
    case 4:
      [cell textLabel].text = aws.meanWindSpeed;
      break;
    case 5:
      [cell textLabel].text = aws.gustWindSpeed;
      break;
  }
  
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [sectionNames objectAtIndex:section];
}

@end
