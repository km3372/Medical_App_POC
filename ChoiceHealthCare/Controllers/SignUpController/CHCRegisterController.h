//
//  CHCRegisterController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/26/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"
#import "IQActionSheetPickerView.h"

@interface CHCRegisterController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQActionSheetPickerViewDelegate> {
    BOOL tosAgreed;
}
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *dobTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tosTextField;

@property (weak, nonatomic) IBOutlet UIButton *tosButton;
- (IBAction)tosButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *tosLabel;
- (IBAction)tosLabelTouch:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentControl;
- (IBAction)birthdayButtonPressed:(id)sender;

@property (strong, nonatomic) UIButton *registerButton;
@end
