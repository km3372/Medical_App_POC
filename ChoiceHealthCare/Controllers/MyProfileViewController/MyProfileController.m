//
//  MyProfileController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 27/01/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "MyProfileController.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "UserModel.h"
#import "Macros.h"
#import "IQKeyboardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MyProfileController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UITextField *fnameTF;
@property (weak, nonatomic) IBOutlet UITextField *lnameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTF;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTF;

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmented;

@end

@implementation MyProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Profile"];

    self.profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.profileImageView.layer.borderWidth  = 2.0;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.bounds.size.width/2);
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.clipsToBounds = YES;

//    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
//    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[self class]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserModel* user = [UserModel currentUser];

    self.fnameTF.text = user.firstName;
    self.lnameTF.text = user.lastName;
    self.emailTF.text = user.email;
    self.phoneNumberTF.text = user.phoneNumber;
    self.passwordTF.text = user.password;
    self.confirmPasswordTF.text = user.password;


    if (user.dob) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyy-MM-dd";
        self.birthdateTF.text = [dateFormat stringFromDate:user.dob];
    } else {
        self.birthdateTF.text = nil;
    }

    if (user.gender) {
        self.genderSegmented.selectedSegmentIndex = ([(user.gender).lowercaseString isEqualToString:@"m"]) ? 0 : 1;
    } else {
        self.genderSegmented.selectedSegmentIndex = UISegmentedControlNoSegment;
    }

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UserModel* user = [UserModel currentUser];
    if (user.profileImageURL)
        [self.profileImageView setImageWithURL:user.profileImageURL placeholderImage:[UIImage imageNamed:@"profilephoto.png"]];
    else
        self.profileImageView.image = [user profileImage];

    self.revealViewController.isFromHome = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if (textField == self.birthdateTF) {
//        [self.view endEditing:YES];
//        [self showDatePicker];
//    }
}

-(void)showDatePicker {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";
    NSDate* dob = [dateFormat dateFromString:self.birthdateTF.text];

    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Select Birthday" delegate:self];
    picker.date = dob;
    picker.actionSheetPickerStyle = IQActionSheetPickerStyleDatePicker;
    [picker show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.fnameTF) {
        [self.lnameTF becomeFirstResponder];
    } else if (textField == self.lnameTF) {
        [self.emailTF becomeFirstResponder];
    } else if (textField == self.emailTF) {
        [self.phoneNumberTF becomeFirstResponder];
    } else if (textField == self.phoneNumberTF) {
        [self.birthdateTF becomeFirstResponder];
//        [textField resignFirstResponder];
//        [self showDatePicker];
    } else if (textField == self.birthdateTF ) {
        [self.passwordTF becomeFirstResponder];
    } else if (textField == self.confirmPasswordTF) {
        [self.confirmPasswordTF becomeFirstResponder];
    } else {
        [self.view endEditing:true];
    }
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"didFinishPickingMediaWithInfo: %@", info);
    UserModel* user = [UserModel currentUser];

    UIImage* image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        //Now upload to server
        [[APIClass sharedManager] updateProfileImage:image
                                        onCompletion:^(NSDictionary *resultDict, NSError *error)
        {
            if ([resultDict[@"success"] boolValue]) {
                NSDictionary* data = resultDict[@"data"];
                if ([resultDict[@"data"] isKindOfClass:[NSArray class]])
                    data = ((NSArray*)resultDict[@"data"]).firstObject;
                else
                    data = resultDict[@"data"];

                if (data) {
                    user.profileImageURL = data[@"target_url"];
                    [user synchronizeUser];
                }
                self.profileImageView.image = image;
            }
        } onCancelation:^{
            NSLog(@"updateProfileImage api call cancelled");
        }];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Event Handling
- (IBAction)updateAvatar:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        picker.allowsEditing = YES;

        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)updateButtonClicked:(id)sender {
    [self validateForm];
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    dateFormat.dateFormat = @"yyyy-MM-dd";

    self.birthdateTF.text = [dateFormat stringFromDate:date];
}

#pragma mark - Private Methods
-(BOOL)validateEmail:(NSString *)email {

    if(email.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Email field should not be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, email.length)];
    if (regExMatches == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Enter proper email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    else {
        return YES;
    }
}

-(BOOL)validatePassword:(NSString *)password {
    if (password.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self.passwordTF.text stringByTrimmingCharactersInSet:whitespace];

    if (trimmed.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not contain only spaces" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - API Calls
- (void)validateForm{

    NSString *message = nil;
    BOOL validation = YES;

    if (self.fnameTF.text.length == 0) {
        message = @"Please enter a first name";
        [self.fnameTF becomeFirstResponder];
    }
    else if (self.lnameTF.text.length == 0) {
        message = @"Please enter a last name";
    }
    else if (![self validateEmail:self.emailTF.text]){
        validation = NO;
    }
    else if (self.phoneNumberTF.text.length == 0) {
        message = @"Please enter a phone number";
    }
    else if (self.birthdateTF.text.length == 0) {
        message = @"Please enter your date of birth";
    }
    else if (self.genderSegmented.selectedSegmentIndex == UISegmentedControlNoSegment){
        message = @"Please select your gender";
    }
    else if (![self validatePassword:self.passwordTF.text]){
        validation = NO;
    }
    else if (![self.passwordTF.text isEqualToString:self.confirmPasswordTF.text]){
        message = @"Confirm password does not match password entered";
    }


    if (message != nil || validation == NO) {
        if (message != nil) {
            [Utils showAlertForString:message];
        }
    }
    else
    {
        [self updateProfileApiCall];
    }
}


-(void)updateProfileApiCall{
    SHOW_HUD(self.view);

    // Create character set with specified characters
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"()- "];

    // Build array of components using specified characters as separtors
    NSArray *arrayOfComponents = [self.phoneNumberTF.text componentsSeparatedByCharactersInSet:characterSet];

    // Create string from the array components
    NSString *phoneNumber = [arrayOfComponents componentsJoinedByString:@""];

    NSString* gender = (self.genderSegmented.selectedSegmentIndex == 0) ? @"m" : @"f";

    NSDictionary *requestData = @{kFirstName:self.fnameTF.text,
                                  kLastName:self.lnameTF.text,
                                  kPassword:self.passwordTF.text,
                                  kConfirmPassword:self.confirmPasswordTF.text,
                                  kEmail:self.emailTF.text,
                                  kDateOfBirth: self.birthdateTF.text,
                                  kPhone: phoneNumber,
                                  kGender: gender,
                                  };

    [[APIClass sharedManager] apiCallWithRequest:requestData forApi:kUpdateProfile requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {

        if ([resultDict[@"success"] boolValue]) {
            //Save new profile data
            UserModel* user = [UserModel currentUser];
            [user updateWithDictionary:resultDict[@"data"]];
            [user synchronizeUser];

            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"%@",resultDict[@"message"]];
            [Utils showAlertForString:errorMessage];
        }

        HIDE_ALL_HUDS(self.view);
    } onCancelation:^{
        [Utils showAlertForString:kRequestFailed];
        HIDE_ALL_HUDS(self.view);
    }];
}


@end
