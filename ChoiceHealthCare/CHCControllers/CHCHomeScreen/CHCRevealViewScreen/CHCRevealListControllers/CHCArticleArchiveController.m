//
//  CHCArticleArchiveController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/15/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCArticleArchiveController.h"
#import "CHCArticleCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CHCArticleDetails.h"
#import "SWRevealViewController.h"
#import "CHCArticleController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CHCHealthSurveyNewCell.h"
#import "CHCArticleDetails.h"
#import "CHCAdditionalInfoNewCell.h"
@interface CHCArticleArchiveController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *articlelist;
@property (strong, nonatomic) IBOutlet UITableView *articleArchiveTableView;
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicepoints;
@property (strong, nonatomic) NSString *webURLString;
@property (nonatomic) BOOL isFromArticleArchive;
- (IBAction)appInfoButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIButton *articleArchiveInstructionButton;
- (IBAction)articleArchiveInstructionButtonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleArchiveVerticalConstraint;

@end

@implementation CHCArticleArchiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.instructionView];
    self.articleArchiveInstructionButton.tag = 0 ;
    [self updateView:self.articleArchiveInstructionButton];
    self.articleArchiveInstructionButton.layer.cornerRadius = 6.0;
    self.articleArchiveInstructionButton.clipsToBounds = YES;
    [self updateView:self.instructionView];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.articlelist = [NSMutableArray new];
    [self getUserChoicePoints];
    [self fetchArticleArchive];
    // Do any additional setup after loading the view.
    
}

- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

-(void)viewDidAppear:(BOOL)animated {
    self.isFromArticleArchive = YES;
    self.revealViewController.isFromHome=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getUserChoicePoints {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicepoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];
}

-(void)fetchArticleArchive {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kArticlesArchiveJSON,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
           
            NSArray *dataArray = resultDict[@"data"];
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                for (int i=0; i<dataArray.count; i++) {
                    CHCArticleDetails *cell = [[CHCArticleDetails alloc]init];
                    cell.articleTitle       = dataArray[i][@"title"];
                    cell.articleUrl         = dataArray[i][@"URI"];
                    cell.articleSnippet     = dataArray[i][@"snippet"];
                    cell.articlePhoto       = dataArray[i][@"imgsrc"];
                    cell.articleId          = dataArray[i][@"articleid"];
                    [self.articlelist addObject:cell];
                }
            
               [self.articleArchiveTableView reloadData];
                
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.articlelist.count > 0  ) {
       return  self.articlelist.count+1;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != self.articlelist.count) {
        
        static NSString *MyIdentifier = @"HealthSurveyNew";
        
        CHCHealthSurveyNewCell *cell =(CHCHealthSurveyNewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
    
            CHCArticleDetails *articleDetails = (self.articlelist)[indexPath.row];
            
            cell.titleLabel.text=articleDetails.articleTitle;
            cell.titleLabel.layer.shadowOpacity = 1.0;
            cell.titleLabel.layer.shadowOffset = CGSizeMake(0.0,1.0);
            cell.subtitleLabel.text=articleDetails.articleSnippet;
            
            [cell.backgroundImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@assets/imgs/dash/%@",kImageIP,articleDetails.articlePhoto]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.answerQuestionsLabel.text= @"READ THIS ARTICLE";
        cell.answerQuestionsLabel.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.answerQuestionsLabel.superview.layer.borderWidth = 1.0;
        cell.answerQuestionsLabel.superview.layer.cornerRadius = 10;
        
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else {
        static NSString *MyIdentifier = @"AdditionalInfoCell";
        
        CHCAdditionalInfoNewCell *cell =(CHCAdditionalInfoNewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
        
    }

    
//    static NSString *CellIdentifier = @"ArticleArchiveCellIdentifier";
//    CHCArticleCell * cell = (CHCArticleCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell) {
//        
//    }
//    cell.borderView.layer.borderColor = [UIColor grayColor].CGColor;
//    cell.borderView.layer.borderWidth  = 2.0;
//    cell.borderView.layer.cornerRadius = 20;
//    
//    CHCArticleDetails *articleDetails = [self.articlelist objectAtIndex:indexPath.row];
//    cell.titleHeading.text=articleDetails.articleTitle;
//    cell.snipset.text=articleDetails.articleSnippet;
//  
//    for (UIImageView *img in cell.contentView.subviews) {
//        if ([img isKindOfClass:[UIImageView class]]) {
//            [img removeFromSuperview];
//        }
//    }
//    
//    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,13, 284, 67)];
//    [imv setCenter:CGPointMake(self.view.frame.size.width/2.0, imv.center.y)];
//    imv.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.contentView addSubview:imv];
//    if (articleDetails.articlePhoto.length == 0) {
//        imv.image=[UIImage imageNamed:@"logo.png"];
//    }else{
//        [imv setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@assets/imgs/dash/%@",kImageIP,articleDetails.articlePhoto]] placeholderImage:[UIImage imageNamed:@"logo.png"]];
//    }
//    
//
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    return cell;


}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.articlelist.count) {
        return 148.0;
    }else{
        
        return self.view.frame.size.width/1.5 ;
    }
//    if (indexPath.row == self.articlelist.count) {
//        return 148;
//    }
//    return 190;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.articlelist.count) {
        CHCArticleDetails *articleDetails = (self.articlelist)[indexPath.row];
        self.webURLString = articleDetails.articleUrl;
        [self performSegueWithIdentifier:@"articlearchivetoarticlewebview" sender:self];
    }
   
        
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            
            
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if ([segue.identifier isEqualToString:@"articlearchivetoarticlewebview"]) {
                CHCArticleController *chcArticleController = (CHCArticleController *)segue.destinationViewController ;
                chcArticleController.webUrlString = self.webURLString ;
                chcArticleController.choicePoints = self.choicepoints.text ;
                chcArticleController.isFromArticleArchive = self.isFromArticleArchive ;
            }
            //        }
        };
        
    }
}

- (IBAction)appInfoButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 10:
          
            [self performSegueWithIdentifier:@"articlearchivetohowotworks" sender:self];
            break;
        case 20:{
            
            UIAlertView *callForAppointmentAlert = [[UIAlertView alloc]initWithTitle:@"Call for Appointment" message:@"404-688-1350" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
            callForAppointmentAlert.tag=404;
            [callForAppointmentAlert show];
          
            break;
        }
        case 30:{
            UIAlertView *callHotline = [[UIAlertView alloc]initWithTitle:@"Call for Appointment" message:@"678-210-9937" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
            callHotline.tag=678;
            [callHotline show];
     
            break;
        }
        case 40:
           
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://choicep.localmarketinginc.com/"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.choicepointsapp.com/"]];
            break;
    }
}
- (IBAction)articleArchiveInstructionButtonClicked:(UIButton *)sender {
 
    if (self.articleArchiveInstructionButton.tag == 0 ) {
        self.articleArchiveInstructionButton.tag = 1;
        [self.articleArchiveInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = (self.view.frame.size.height-65.0);
        (self.articleArchiveVerticalConstraint).constant = self.view.frame.size.height;
        self.instructionTextView.hidden = NO;

    }else{
        self.articleArchiveInstructionButton.tag = 0;
        [self.articleArchiveInstructionButton setTitle:@"Article Archive Instructions!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 35.0;
        (self.articleArchiveVerticalConstraint).constant = 45.0;
        self.instructionTextView.hidden = YES;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 404:{
            switch (buttonIndex) {
                case 0:
                   
                    break;
                case 1:{
                    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"4046881350"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    break;
                }
                    
                    
            }
        
            break;
        }
        case 678:{
            switch (buttonIndex) {
                case 0:
                 
                    break;
                case 1:{
                   
                    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"6782109937"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    break;}
                    
            }
        
            break;
        }
    }
    
}
@end
