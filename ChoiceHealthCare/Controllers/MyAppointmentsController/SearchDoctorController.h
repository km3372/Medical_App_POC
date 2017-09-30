//
//  SearchDoctorController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/23/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "BaseViewController.h"
#import "CZPicker.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchDoctorController : BaseViewController  <CZPickerViewDataSource, CZPickerViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>{
    
    NSArray *specialityArray;
    NSString *locationString;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
}
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentControl;
@property (nonatomic, strong) NSMutableArray *specialityDataArray;
@property (nonatomic) NSInteger selectedRow;
- (IBAction)findDoctorButtonPressed:(id)sender;
- (IBAction)segmentedControlChanged:(id)sender;


@end
