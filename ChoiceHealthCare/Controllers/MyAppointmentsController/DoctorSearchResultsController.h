//
//  DoctorSearchResultsController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/24/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CHCConstants.h"
#import <CoreLocation/CoreLocation.h>

@interface DoctorSearchResultsController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchDetailsBackButton;

@property (nonatomic) SearchType  searchType;
@property (strong, nonatomic) NSString *searchName;
@property (strong, nonatomic) NSString *specialtyName;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *specialityId;
@property (strong, nonatomic) CLLocation *userLocation;
@property (nonatomic, strong) NSMutableArray *doctorResultsDataArray;


@end
