//
//  SearchDoctorController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/23/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "SearchDoctorController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DoctorSearchResultsController.h"
#import "InstructionsViewController.h"

@interface SearchDoctorController ()

@end

@implementation SearchDoctorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeMenu andTitle:@"Search Doctor"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    [self setupTextField];
    
    //TESTING
    specialityArray = @[@"Familiy Medicine", @"Radiology", @"Cardiology", @"Dermatology", @"Pediatrics"];
    
   // [self fetchSpecialities];
    [self getCurrentLocation];
    [self requestLocationAuthorization];
}

- (IBAction)instructionButtonClicked:(id)sender {
    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];

    controller.helpText = @"Are you due for a health screening? Would you like to setup an appointment and receive a points reward? ChoicePoints allows you to view your upcoming appointments, schedule a new appointment, and change or cancel an existing appointment. ";

    [self.navigationController pushViewController:controller animated:true];
}


-(void)setupTextField{
    _searchTextField.delegate = self;
    _searchTextField.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
    _searchTextField.layer.borderWidth = 2.0;
    _searchTextField.text = @"-Select One-";
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _searchTextField.leftView = paddingView;
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)setupDoctorNamePlaceholder{
    _searchTextField.text = nil;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter Doctor Name" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    _searchTextField.attributedPlaceholder = str;
}

- (IBAction)segmentedControlChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            [self setupTextField];
        }
            break;
        case 1:
        {
            _searchTextField.text = locationString;
        }
            break;
        case 2:
        {
            [self setupDoctorNamePlaceholder];
        }
            break;
            
        default:
            break;
    }
}


-(void) getCurrentLocation{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil) {
        // longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        // latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && placemarks.count > 0) {
            placemark = placemarks.lastObject;
            
            locationString = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
            
            [locationManager stopUpdatingLocation];
            [locationManager stopMonitoringSignificantLocationChanges];
            locationManager = nil;

        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

- (void)requestLocationAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {

    }
    //    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showSpecialityPicker{
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Select Specialty" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = YES;
    [picker show];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (_searchSegmentControl.selectedSegmentIndex) {
        case 0:
        {
            if (_specialityDataArray == nil) {
                [self fetchSpecialities];
            }
            else{
                [self showSpecialityPicker];
            }
            
            return NO;
        }
            break;
            
        case 1:
        {
            return NO;
        }
            break;
            
        default:
            break;
    }
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowDoctorSearchResults"])
    {
        // Pass the selected object to the new view controller.
        DoctorSearchResultsController *vc = segue.destinationViewController;
        
            if (currentLocation) {
                vc.userLocation = currentLocation;
            }
        
        switch (_searchSegmentControl.selectedSegmentIndex) {
            case 0:
                vc.searchType = SearchTypeSpeciality;
                vc.specialityId = (_specialityDataArray[_selectedRow])[@"specid"];
                vc.specialtyName = (_specialityDataArray[_selectedRow])[@"name"];
                break;
            case 1:
                vc.searchType = SearchTypeLocation;
                vc.locationName = locationString;
                break;
            case 2:
                vc.searchType = SearchTypeName;
                vc.searchName = _searchTextField.text;
                break;
                
            default:
                break;
        }
    }
}


- (IBAction)findDoctorButtonPressed:(id)sender {
    NSLog(@"TEXTFIELDTEXT: %@", _searchTextField.text);
    if ([_searchTextField.text isEqualToString:@"-Select One-"]|| [_searchTextField.text isEqualToString:@"Enter Doctor Name"]|| _searchTextField.text == nil || !_searchTextField.hasText) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"No Selection Made"
                                      message:@"Please Make a Selection"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        [self performSegueWithIdentifier:@"ShowDoctorSearchResults" sender:self];
    }
   
}

/* comment out this method to allow
 CZPickerView:titleForRow: to work.
 */
- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:(_specialityDataArray[row])[@"name"]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return (_specialityDataArray[row])[@"name"];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return _specialityDataArray.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    NSLog(@"%@ is chosen!", (_specialityDataArray[row])[@"name"]);
    [self.navigationController setNavigationBarHidden:YES];
    
    _searchTextField.text =  (_specialityDataArray[row])[@"name"];
    _selectedRow = row;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    for (NSNumber *n in rows) {
        NSInteger row = n.integerValue;
        NSLog(@"%@ is chosen!", (_specialityDataArray[row])[@"name"]);
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Canceled.");
}

- (void)czpickerViewWillDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker will display.");
}

- (void)czpickerViewDidDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker did display.");
}

- (void)czpickerViewWillDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker will dismiss.");
}

- (void)czpickerViewDidDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker did dismiss.");
}


#pragma mark - API Calls

-(void) fetchSpecialities{
    
// Dictionary Format Example
//    {
//        "specid": "3",
//        "name": "Internal Medicine"
//    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kGetAppointmentListSpecialties
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         
         if ([resultDict[@"success"] boolValue]) {
             _specialityDataArray = [NSMutableArray new];
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                 
                 NSArray *dataArray = resultDict[@"data"];
                 for (int i=0; i<dataArray.count; i++) {
                     NSDictionary *itemInfo = dataArray[i];
                     [_specialityDataArray addObject:itemInfo];
                 }
                 
                 [self showSpecialityPicker];
             }
         } else{
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}
@end
