//
//  WeekdayCell.h
//  DarkSky
//
//  Created by Fishington Studios on 12/16/15.
//  Copyright © 2015 Chris Flammer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekdayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempMaxLabel;

@end
