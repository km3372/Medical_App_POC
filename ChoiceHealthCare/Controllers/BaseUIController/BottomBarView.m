//
//  BottomBarView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "BottomBarView.h"
#import "CommonFilesImporter.h"
#import "APINames.h"



@interface BottomBarView ()

@property (nonatomic, weak) IBOutlet UIButton *pointsButton;
@property (nonatomic, weak) IBOutlet UIButton *getHelpButton;
@property (nonatomic, weak) IBOutlet UIButton *myMedsButton;
@property (nonatomic, weak) IBOutlet UIButton *myAppsButton;

@end

@implementation BottomBarView

@synthesize delegate;

+ (BottomBarView *)createBottomBarWithType:(BottomBarType)type {
    
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"BottomBarView" owner:self options:nil];
    
    BottomBarView *view = type == BottomBarTypeDefault ? viewArray[0] : viewArray[1];
    
    [self setButtonTypesForView:view];
    
    return view;
}

+ (void)setButtonTypesForView:(BottomBarView *)view {
    
    if (view.pointsButton) {
        view.pointsButton.tag = ButtonTypePoints;
        [view updatePointsCount];
    }
    
    if (view.getHelpButton) {
        view.getHelpButton.tag = ButtonTypeGetHelp;
    }
    
    if (view.myAppsButton) {
        view.myAppsButton.tag = ButtonTypeMyApps;
    }
    
    if (view.myMedsButton) {
        view.myMedsButton.tag = ButtonTypeMyMeds;
    }
}

- (void)dealloc {
    [[UserModel currentUser] removeObserver:self forKeyPath:@"pointTotal"];
}

- (void)awakeFromNib {
    UserModel* user = [UserModel currentUser];
    [user addObserver:self forKeyPath:@"pointTotal" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self updatePointsCount];
}

- (void)updatePointsCount {
    UserModel* user = [UserModel currentUser];
    
    UIImage *pointsImage = [UIImage getImageFromText:(user.pointTotal).stringValue
                                       withTextColor:[UIColor grayColor]
                                            textFont:[UIFont boldSystemFontOfSize:20]
                                        andImageSize:self.pointsButton.frame.size];
    
    [self.pointsButton setBackgroundImage:pointsImage forState:UIControlStateNormal];
}

- (IBAction)buttonsClicked:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarButtonClickedForType:)]) {
        [self.delegate bottomBarButtonClickedForType:[sender tag]];
    }
}

@end
