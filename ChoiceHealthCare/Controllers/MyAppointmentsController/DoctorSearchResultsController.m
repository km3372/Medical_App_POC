//
//  DoctorSearchResultsController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/24/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "DoctorSearchResultsController.h"
#import "DoctorSearchResultCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DoctorModel.h"
#import "ScheduleAppointmentController.h"
#import "ScheduleAppointmentNew.h"


@interface DoctorSearchResultsController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation DoctorSearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeMenu andTitle:@"Select Doctor"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    [_searchDetailsBackButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _searchLabel.text = @"Searching Doctors";
    [self fetchDoctors];
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
    
    return _doctorResultsDataArray.count
    ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"DoctorSearchResultCell";
    DoctorSearchResultCell* resultCell = (DoctorSearchResultCell*)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (resultCell == nil) {
        resultCell = [[DoctorSearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];    separatorLineView.backgroundColor = [UIColor whiteColor];
    [resultCell.contentView addSubview:separatorLineView];
    
    DoctorModel *model = [DoctorModel new];
    model = _doctorResultsDataArray[indexPath.row];
    
    resultCell.nameLabel.text =model.name;
    resultCell.addressLabel.text = model.address;
    resultCell.cityStateLabel.text = model.cityState;
    resultCell.distanceLabel.text = [NSString stringWithFormat:@"%@ miles away", model.distance];
    
    resultCell.selectButton.tag = indexPath.row;
    [resultCell.selectButton addTarget:self action:@selector(selectDoctorPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return resultCell;
}

#pragma mark - API Calls

-(void)fetchDoctors{
    
    NSString* apiString;
    NSDictionary *requestDictionary;
    
    switch (_searchType) {
        case SearchTypeSpeciality:
        {
            [_searchDetailsBackButton setTitle:[NSString stringWithFormat:@"%@ %@ %@", kSearchDetailsPrefixString,kSearchSpecilityString, _specialtyName] forState:UIControlStateNormal];
            apiString = kDoctorFindBySpecialty;
            requestDictionary =  @{kSpecId:_specialityId};
        }
            break;
        case SearchTypeLocation:
        {
            [_searchDetailsBackButton setTitle:[NSString stringWithFormat:@"%@ %@ %@", kSearchDetailsPrefixString,kSearchLocationString, _locationName] forState:UIControlStateNormal];
            apiString = kDoctorFindByLocation;
            
            float latitude = _userLocation.coordinate.latitude;
            float longitude = _userLocation.coordinate.longitude;
            requestDictionary =  @{kGeo_Lat:@(latitude), kGeo_Long:@(longitude)};
        }
            break;
        case SearchTypeName:
        {
            [_searchDetailsBackButton setTitle:[NSString stringWithFormat:@"%@ %@ %@", kSearchDetailsPrefixString,kSearchNameString, _searchName] forState:UIControlStateNormal];
            apiString = kDoctorFindByName;
            requestDictionary =  @{kDoctorName:_searchName};
        }
            break;
            
        default:
            break;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:apiString
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         
         if ([resultDict[@"success"] boolValue]) {
             _doctorResultsDataArray = [NSMutableArray new];
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                 
                 NSArray *dataArray = resultDict[@"data"];
                 for (int i=0; i<dataArray.count; i++) {
                     NSDictionary *itemInfo = dataArray[i];
                     
                     
                     DoctorModel *model = [DoctorModel createArticleModelWithDictionary:itemInfo];
                     
                     [_doctorResultsDataArray addObject:model];
                 }
                 
                 _searchLabel.text = @"Search Results";
                 
                 [self.tableView reloadData];
             }
             
             else if ([resultDict[@"message"] isEqualToString:kNoDoctorsFoundString]) {
                 _searchLabel.text = kNoDoctorsFoundString;
             }
             else{
                 NSString *errorMessage = resultDict[@"message"];
                 [Utils showAlertForString:errorMessage];
             }
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectDoctorPressed:(UIButton*)sender
{
    DoctorModel* model = _doctorResultsDataArray[sender.tag];
    [self performSegueWithIdentifier:@"ScheduleAppointment" sender:model];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScheduleAppointmentNew class]]) {
        ((ScheduleAppointmentNew*)segue.destinationViewController).model = sender;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
