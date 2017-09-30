//
//  SurveysViewController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/29/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SurveysViewController : BaseViewController <UIAlertViewDelegate>{
    NSNumber *selectedIndex;
    BOOL isMultipleChoice;
    BOOL isSurveyComplete;
}
@property (nonatomic, strong) NSMutableArray *questionDataArray;
@property (nonatomic, strong) NSMutableArray *selectionArray;
@property (nonatomic, strong) NSString *questionId;
@property (nonatomic, strong) NSString *sid;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)nextButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end
