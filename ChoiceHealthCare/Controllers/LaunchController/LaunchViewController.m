//
//  LaunchViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 23/04/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "LaunchViewController.h"
#import "ProgressView.h"
#import "CommonFilesImporter.h"

@interface LaunchViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet ProgressView *progressView;


@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIUtils setStatusBarColor:[UIColor clearColor]];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self setSplashScreensOnScrollView];
    [self initializeTapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Getters


#pragma mark - ScrollView Delegates


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.progressView.currentItemIndex = page;
}

#pragma mark - IBActions

- (IBAction)loginButtonClicked:(id)sender{
    
    [self performSegueWithIdentifier:@"GoToLoginController" sender:self];
}

- (IBAction)registerButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"GoToRegisterController" sender:self];
}

#pragma mark - Private Methods

- (void)setSplashScreensOnScrollView{
    
    NSArray *viewsArray = [[NSBundle mainBundle] loadNibNamed:@"SplashScreens" owner:self options:nil];
    
    int i = 0;
    
    for (UIView *view in viewsArray) {
        
        view.frame = CGRectMake(i * CGRectGetWidth(self.view.bounds), 0, CGRectGetWidth(self.view.bounds),CGRectGetHeight(self.view.bounds)- 50);
        
        ++i;
        [self.scrollView addSubview:view];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*i, CGRectGetHeight(self.view.bounds)-50);
}

-(void)initializeTapGesture{
    UITapGestureRecognizer *screenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
    screenTap.delegate = self;
    screenTap.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:screenTap];
}

-(void)screenTapped{
    float width = CGRectGetWidth(_scrollView.frame);
    float height = CGRectGetHeight(_scrollView.frame);
    float newPosition = _scrollView.contentOffset.x+width;
    CGRect toVisible = CGRectMake(newPosition, 0, width, height);
    
    [_scrollView scrollRectToVisible:toVisible animated:YES];
    
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width;
    if (page < 5) {
        self.progressView.currentItemIndex = page+1;
    }
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
