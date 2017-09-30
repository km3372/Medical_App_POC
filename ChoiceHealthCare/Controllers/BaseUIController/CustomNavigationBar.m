//
//  CustomNavigationBar.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CustomNavigationBar.h"

#import "UserModel.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "MyProfileController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CustomNavigationBar {
    UserModel* user;
}


+(CustomNavigationBar*) sharedInstance
{
    static CustomNavigationBar * sharedData = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[CustomNavigationBar alloc ]init];
    });
    
    return sharedData;
}

- (void)dealloc {
    [user removeObserver:self forKeyPath:@"profileImageURL"];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 1.0;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.bounds.size.width/2);
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.clipsToBounds = YES;

    user = [UserModel currentUser];

    [self performSelector:@selector(loadProfileImage) withObject:NULL afterDelay:0.05];
    [user addObserver:self forKeyPath:@"profileImageURL" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"profileImageURL"]) {
        [self loadProfileImage];
    }
}

- (void)loadProfileImage {
    if (user.profileImageURL)
        [self.profileImageView setImageWithURL:user.profileImageURL placeholderImage:[UIImage imageNamed:@"profilephoto.png"]];
    else
        self.profileImageView.image = [user profileImage];
}

- (IBAction)tappedProfileImage:(id)sender {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    SWRevealViewController* revealVC = (SWRevealViewController*)delegate.window.rootViewController;
    UINavigationController* nc = (UINavigationController*)revealVC.frontViewController;
    UIStoryboard* storyboard = revealVC.storyboard;

    if (![nc.topViewController isKindOfClass:[MyProfileController class]]) {
        UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyProfileController"];
        [nc pushViewController:nextVC animated:YES];
    }
}

- (CustomNavigationBar *)createNavBarWithLeftButtonType:(LeftNavButtonType)type andTitle:(NSString *)title {
    
    CustomNavigationBar *navBarView = [[NSBundle mainBundle] loadNibNamed:@"CustomNavigationBar" owner:self options:nil][0];
    
    [self setLeftNavButtonTitleForNavView:navBarView withType:type];
   
    (navBarView.titleLabel).text = title;
    
    return navBarView;
    
}

- (void)setLeftNavButtonTitleForNavView:(CustomNavigationBar *)view
                               withType:(LeftNavButtonType)leftNavButtonType {
    switch (leftNavButtonType) {
            
        case LeftNavButtonTypeBack:
            
            [view.leftNavButton setTitle:@"Back" forState:UIControlStateNormal];
            
            break;
            
        case LeftNavButtonTypeMenu:
            
            [view.leftNavButton setImage:[UIImage imageNamed:@"menu-icon"] forState:UIControlStateNormal];
            _badgeView = [GIBadgeView new];
            [view.leftNavButton addSubview:self.badgeView];
            
            break;
    }
}

-(void)setBadgeValue: (NSInteger) value {
   (self.badgeView).badgeValue = value;
}


@end
