//
//  CHCHomeNewController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/4/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCHomeNewController.h"
#import "CHCHealthLogSurveyDetails.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CHCArticleDetails.h"
#import "CHCHealthSurveyNewCell.h"
#import "CHCAdditionalInfoNewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SWRevealViewController.h"
#import "CHCArticleController.h"
#import "SecurityPinController.h"

@interface CHCHomeNewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UITableView *homeScreeTableView;
@property (strong, nonatomic) NSMutableArray *listOfItems;
@property (nonatomic) BOOL isFromArticleArchive;
@property (strong, nonatomic) NSString *webURLString;
- (IBAction)appInfoButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet UITextField *enterUserID;
- (IBAction)okButtonClick:(id)sender;
- (IBAction)cancelButtonClick:(id)sender;


@end

@implementation CHCHomeNewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
        
    
    self.customAlertView.hidden=YES;
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    self.listOfItems = [NSMutableArray new];
    self.enterUserID.text=[[NSUserDefaults standardUserDefaults]objectForKey:kUid];
    [self addDataForStaticCellsToDisplay];
    [self fetchJasonForDetails];
    [self getUserChoicePoints];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doTheReload:)
                                                 name:@"enterUserID"object:nil];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    self.isFromArticleArchive = NO;
    self.revealViewController.isFromHome=YES;
    
}

-(void)doTheReload:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.customAlertView.backgroundColor=[UIColor colorWithPatternImage:[self startBlur]];
        self.customAlertView.hidden=NO;
    });
    
    [self.view bringSubviewToFront:self.customAlertView];
    
}
-(UIImage *)startBlur{
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the image
    CIImage *blurImg = [CIImage imageWithCGImage:viewImg.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:blurImg forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@2.0f forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [context createCGImage:gaussianBlurFilter.outputImage fromRect:blurImg.extent];
    UIImage *outputImg = [UIImage imageWithCGImage:cgImg];
    return outputImg;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addDataForStaticCellsToDisplay {
    
    CHCHealthLogSurveyDetails *firstCell = [[CHCHealthLogSurveyDetails alloc]init];
    firstCell.titleHeading         = @"Today's Survey Question";
    firstCell.subTitle             = @"Answer today's health survey questions to get more points.";
    firstCell.snipset              = @"Doctor Smiling.png";
    firstCell.answerQuestions      = @"ANSWER QUESTIONS";
    [self.listOfItems addObject:firstCell];
    
    CHCHealthLogSurveyDetails *secondCell = [[CHCHealthLogSurveyDetails alloc]init];
    secondCell.titleHeading         = @"Health Log";
    secondCell.subTitle             = @"Log your exercise, blood pressure, blood sugar and habbits.";
    secondCell.snipset              = @"Couple Workout.png";
    secondCell.answerQuestions      = @"LOG HEALTH DATA";
    [self.listOfItems addObject:secondCell];
    
}

-(void)fetchJasonForDetails {
    
    NSString *tempString = [NSString stringWithFormat:@"%@%@",kFetchJSON,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object = @{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager] apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
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
                    [self.listOfItems addObject:cell];
                    [self.homeScreeTableView reloadData];
                }                
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

-(void)getUserChoicePoints {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicePoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];    
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfItems.count+1  ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.listOfItems.count) {
        
        static NSString *MyIdentifier = @"HealthSurveyNew";
        
        CHCHealthSurveyNewCell *cell =(CHCHealthSurveyNewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            
            cell.titleLabel.text=[(self.listOfItems)[indexPath.row]titleHeading];
            cell.titleLabel.layer.shadowOpacity = 1.0;
            cell.titleLabel.layer.shadowOffset = CGSizeMake(0.0,1.0);
            cell.subtitleLabel.text=[(self.listOfItems)[indexPath.row]subTitle];
            cell.backgroundImageView.image = [UIImage imageNamed:[(self.listOfItems)[indexPath.row]snipset]];
            cell.answerQuestionsLabel.text=[(self.listOfItems)[indexPath.row]answerQuestions];
            
        }else{
            CHCArticleDetails *articleDetails = (self.listOfItems)[indexPath.row];
            
            cell.titleLabel.text=articleDetails.articleTitle;
            cell.titleLabel.layer.shadowOpacity = 1.0;
            cell.titleLabel.layer.shadowOffset = CGSizeMake(0.0,1.0);
            cell.subtitleLabel.text=articleDetails.articleSnippet;
            
            [cell.backgroundImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@assets/imgs/dash/%@",kImageIP,articleDetails.articlePhoto]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.answerQuestionsLabel.text= @"READ THIS ARTICLE";
        
        }


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
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.listOfItems.count) {
        return 180.0;
    }else{
    
        return self.view.frame.size.width/1.5 ;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"hometohealthsurvey" sender:self];
    }else if (indexPath.row ==1) {
        [self performSegueWithIdentifier:@"hometohealthlog" sender:self];
    }else if(indexPath.row != self.listOfItems.count){
        CHCArticleDetails *articleDetails = (self.listOfItems)[indexPath.row];
        self.webURLString = articleDetails.articleUrl;
        [self performSegueWithIdentifier:@"hometoarticlewebview" sender:self];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            //            if ([segue.identifier isEqualToString:@"revealtohome"] && self.revealViewController.isFromHome) {
            //                [self.revealViewController.navigationController popToRootViewControllerAnimated:YES];
            //                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            //            }else{
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            
            
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if ([segue.identifier isEqualToString:@"hometoarticlewebview"]) {
                CHCArticleController *chcArticleController = (CHCArticleController *)segue.destinationViewController ;
                chcArticleController.webUrlString = self.webURLString ;
                chcArticleController.choicePoints = self.choicePoints.text ;
                chcArticleController.isFromArticleArchive = self.isFromArticleArchive ;
            }
            //        }
        };
        
    }
}


- (IBAction)appInfoButtonClick:(UIButton *)sender {

//    [sender setBackgroundImage:[UIImage imageNamed:@"Menu_bgcopy.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
//    [sender setBackgroundImage:[UIImage imageNamed:@"Menu_bg.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
    
    switch (sender.tag) {
            
        case 10:
            [self performSegueWithIdentifier:@"hometohowitworks" sender:self];
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
- (IBAction)okButtonClick:(id)sender {
    if (self.enterUserID.text.length==0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:kAppName message:@"User ID must be some integer value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else {
        [[NSUserDefaults standardUserDefaults]setObject:self.enterUserID.text forKey:kUid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.customAlertView.hidden=YES;
        [self.enterUserID resignFirstResponder];
        if (self.listOfItems.count !=0) {
            [self.listOfItems removeAllObjects];
        }
        [self addDataForStaticCellsToDisplay];
        [self fetchJasonForDetails];
        [self getUserChoicePoints];
        [self.homeScreeTableView reloadData];
    }
}

- (IBAction)cancelButtonClick:(id)sender {
      self.customAlertView.hidden=YES;
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;
    
    if (textField == self.enterUserID )
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, newString.length)];
        if (numberOfMatches == 0)
            return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ((self.enterUserID).isFirstResponder){
        [textField resignFirstResponder];
    }
    return YES;
}

@end
