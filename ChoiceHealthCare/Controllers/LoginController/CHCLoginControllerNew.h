//
//  CHCRegisterControllerNew.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/29/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface CHCLoginControllerNew : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;

@property (strong, nonatomic) UIButton *loginButton;

@end
