//
//  CHCArticleController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/19/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCArticleController.h"
#import "SWRevealViewController.h"
@interface CHCArticleController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *articleWebView;
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicepoints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewToBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *startOver;
- (IBAction)startOverClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;


@end

@implementation CHCArticleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.webUrlString]];
    
//    choicep.localmarketinginc.com/everyone-know-living-diabetes/
    [self updateButtonView:self.startOver];
    [self.articleWebView loadRequest:request];
    (self.articleWebView).scalesPageToFit;
    // Do any additional setup after loading the view.

}
- (void)updateButtonView:(UIButton*)button{
    //updating button view according to design..
    button.tag=0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 10.0;
    button.clipsToBounds = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    self.revealViewController.isFromHome=NO;
    self.choicepoints.text=self.choicePoints;
    if (self.isFromArticleArchive ) {
        self.webViewToBottomLayoutConstraint.constant = 58.0;
        self.startOver.hidden = NO;
        self.bottomLabel.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)startOverClicked:(id)sender {
   
    [self performSegueWithIdentifier:@"articlewebviewtoarticlearchive" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}

@end
