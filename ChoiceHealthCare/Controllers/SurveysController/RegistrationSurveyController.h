//
//  RegistrationSurveyController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/9/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZPicker.h"
#import "CHCConstants.h"
#import "IQActionSheetPickerView.h"

@interface RegistrationSurveyController : UITableViewController <CZPickerViewDelegate, CZPickerViewDataSource, UITextFieldDelegate, IQActionSheetPickerViewDelegate>{
    NSArray *questions;
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet UIButton *heightButton;
@property (strong, nonatomic) UIButton *completeButton;
@property (strong, nonatomic) NSMutableArray *questionDataArray;
@property (strong, nonatomic) NSMutableArray *medicalConditionsArray;
@property (weak, nonatomic) IBOutlet UIButton *nationalityButton;
@property (weak, nonatomic) IBOutlet UIButton *medicalConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *raceButton;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;

@property (strong, nonatomic) NSString *userWeight;
@property (strong, nonatomic) NSString *userHeight;
@property (strong, nonatomic) NSString *nationalityQId;
@property (strong, nonatomic) NSString *raceQId;
@property (strong, nonatomic) NSString *medicalQId;


@property (nonatomic) QuestionType  questionType;

@end
