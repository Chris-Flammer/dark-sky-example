//
//  ForecastTableViewController.m
//  DarkSky
//
//  Created by Fishington Studios on 12/16/15.
//  Copyright © 2015 Chris Flammer. All rights reserved.
//

#import "ForecastTableViewController.h"
#import "WeekdayCell.h"
#import <CoreLocation/CoreLocation.h>

#define DARK_SKY_API_KEY @"e5b611a034599d370e78b6a8682c0155"

@interface ForecastTableViewController ()<CLLocationManagerDelegate> {
    // instance responsible for fetching and updating user location
    CLLocationManager *_locationManager;
}
// the array that holds our results from the Dark Sky API
@property (strong, nonatomic) NSMutableArray *resultsArray;


@end

@implementation ForecastTableViewController


#pragma mark - View Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // initialize the location manager
    _locationManager = [[CLLocationManager alloc] init];
    
    // Set the delegate
    _locationManager.delegate = self;

    // get the user's current location
    [self getQuickLocationUpdate];
    
    self.navigationItem.title = NSLocalizedString(@"...Fetching Data...", nil);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeekdayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dateData = [self.resultsArray objectAtIndex:indexPath.row];
    

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *weatherDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:indexPath.row toDate:[NSDate date] options:kNilOptions];
    NSString *dayString = [self getStringFromDate:weatherDate withFormat:@"EEEE"];
    
    
    // put just a little more emphasis on today's date
    if([calendar isDate:weatherDate inSameDayAsDate:[NSDate date]]) {
        cell.weekdayLabel.text = NSLocalizedString(@"Today", nil);
        cell.weekdayLabel.textColor = [UIColor colorWithRed:0 green:0.49 blue:1 alpha:1];
    } else {
        cell.weekdayLabel.text = dayString;
        cell.weekdayLabel.textColor = [UIColor blackColor];
    }

    
    NSNumber *minTemp = dateData[@"temperatureMin"];
    cell.tempMinLabel.text = [NSString stringWithFormat:@"%.2ld°",(long)minTemp.integerValue];
    
    NSNumber *maxTemp = dateData[@"temperatureMax"];
    cell.tempMaxLabel.text = [NSString stringWithFormat:@"%.2ld°",(long)maxTemp.integerValue];
    
    
    
    cell.summaryLabel.text = dateData[@"summary"];
    

    
    return cell;
}





-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}








#pragma mark - Location Delegate

// since we aren't doing a whole lot with location, we'll new the user and awesome requestLocation iOS 9 api to get the location
-(void)getQuickLocationUpdate {
    
    // Request location authorization
    [_locationManager requestWhenInUseAuthorization];
    
    // Request a location update
    [_locationManager requestLocation];
    // Note: requestLocation may timeout and produce an error if authorization has not yet been granted by the user
}



-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations {
    // Process the received location update
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [self getForcastUsingLocation:currentLocation apikey:DARK_SKY_API_KEY];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failure:%@",error.description);
}

















#pragma mark - Dark Sky API


-(void)getForcastUsingLocation:(CLLocation *)currentLocation apikey:(NSString *)apiKey {
    
    CLLocationDegrees latitude = currentLocation.coordinate.latitude;
    CLLocationDegrees longitude = currentLocation.coordinate.longitude;
    NSString *urlString = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",apiKey,latitude,longitude];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {

                NSMutableDictionary * innerJson = [NSJSONSerialization
                                                   JSONObjectWithData:data options:kNilOptions error:&error
                                                   ];
                // get the forcast for the week
                NSDictionary *daily = innerJson[@"daily"];
                self.resultsArray = daily[@"data"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    self.navigationItem.title = NSLocalizedString(@"7 Day Forecast from Dark Weather API", nil);

                });
             
                
            }] resume];
    
    
}






#pragma mark - Helper Method

-(NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return  dateString;
    
}




@end
