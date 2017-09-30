//
//  SecurityPinController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 16/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import "SecurityPinController.h"
#import "AppDelegate.h"
#import "AppUserData.h"
#import "CHCConstants.h"
#import "APINames.h"
#import "APIClass.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ForgetPinController.h"
#import "UIView+Animation.h"

@interface SecurityPinController ()

{
    CompletionBlock _completionBlock;
    UserType _userType;
}

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *secureLabel;
@property (nonatomic, weak) IBOutlet UIButton *forgetPinButton;

@property (nonatomic, strong) NSMutableString *inputPinString;

@property (nonatomic, strong) NSString *selectedPinString;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *navBarHeight;

@end

@implementation SecurityPinController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil userType:(UserType)type completionBlock:(CompletionBlock)block {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _completionBlock = [block copy];
        _userType = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = true;
    
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpView {

    
    if (_userType == UserTypeOld) {
        
        self.textLabel.text = @"PLEASE ENTER FOUR DIGIT PIN";
        self.navBarHeight.constant = 0;
    
    } else {
        self.forgetPinButton.hidden = true;
    }
    
    self.secureLabel.text = @"";
}

- (NSMutableString *)inputPinString{
    
    if (!_inputPinString) {
        _inputPinString = [[NSMutableString alloc] initWithString:@""];
    }
    return _inputPinString;
}

#pragma mark - IBActions

- (IBAction)forgetPinButtonClicked:(id)sender {
    
    ForgetPinController *forgetPinController = [[ForgetPinController alloc] initWithNibName:@"ForgetPinController" bundle:nil];
    
    [self.navigationController presentViewController:forgetPinController animated:YES completion:nil];
}

- (IBAction)buttonClicked:(id)sender {
    
    [self.inputPinString appendFormat:@"%ld",(long)[sender tag]];
    
    self.secureLabel.text = self.secureLabel.text.length == 4 ? @"." : [self.secureLabel.text stringByAppendingString:@"."];
    
    if (self.inputPinString.length >= 4) {
        
        _userType == UserTypeOld ? [self registeredUserValidation] : [self newUserValidation];
    
        self.inputPinString = nil;
    }
}

- (IBAction)backButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Validation

- (void) registeredUserValidation {
    
    if (_completionBlock) {
    
        _completionBlock(self.inputPinString,self);
    }
}

- (void)newUserValidation {
    
    self.secureLabel.text   = @"";
    
    if (!self.selectedPinString) {
        
        self.textLabel.text = @"Confirm your four digit PIN.";
        
        self.selectedPinString = self.inputPinString;
        
    } else if (![self.selectedPinString isEqualToString:self.inputPinString]){
        
        self.textLabel.text = @"PIN not matched try again.";
        
    } else {
        
        [AppUserData sharedInstance].pinString = self.selectedPinString;
        
        if (_completionBlock) {
            
            _completionBlock(self.selectedPinString, self);
        }
    }
}


- (void)showWrongPingAnimationAlert {
    
    self.textLabel.text = @"Wrong PIN please try again.";
    
    [self.secureLabel shakeAnimation];
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
