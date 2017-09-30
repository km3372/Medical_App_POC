//
//  CHCHomeController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/17/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCHomeController.h"
#import "SWRevealViewController.h"
#import "CHCHealthLogSurveyDetails.h"
#import "CHCArticleDetails.h"
#import "CHCHealthSurveyCell.h"
#import "CHCArticleCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CHCSurveyController.h"
#import "CHCHealthLogController.h"
#import "CHCArticleController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface CHCHomeController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel  *choicePoints;
@property (strong, nonatomic) NSMutableArray    *listSurveyArray;
@property (strong, nonatomic) IBOutlet UITableView *detailsTableView;
@property (strong, nonatomic) NSString *webURLString;
@property (strong, nonatomic) IBOutlet UIView *customAlertView;
@property (strong, nonatomic) IBOutlet UITextField *enterUserID;
@property (nonatomic) BOOL isFromArticleArchive;
- (IBAction)okButtonClick:(id)sender;
- (IBAction)cancelButtonClick:(id)sender;


@end

@implementation CHCHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customAlertView.hidden=YES;
    // Do any additional setup after loading the view.
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.choicePoints.text=[NSString stringWithFormat:@"Choice Points %ld",(long)[[[NSUserDefaults standardUserDefaults] objectForKey:kPointTotal] integerValue]];
    self.listSurveyArray=[NSMutableArray new];
    
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


- (void)addDataForStaticCellsToDisplay{
    CHCHealthLogSurveyDetails *firstCell = [[CHCHealthLogSurveyDetails alloc]init];
    firstCell.titleHeading         = @"YOUR HEALTH SURVEY QUESTIONS";
    firstCell.subTitle             = @"Answer Today's Question";
    firstCell.snipset              = @"Answer today's health survey questions to get more points.";
    firstCell.answerQuestions      = @"ANSWER QUESTIONS";
    [self.listSurveyArray addObject:firstCell];
    
    CHCHealthLogSurveyDetails *secondCell = [[CHCHealthLogSurveyDetails alloc]init];
    secondCell.titleHeading         = @"HEALTH LOG";
    secondCell.subTitle             = @"Log Health Related Activities";
    secondCell.snipset              = @"Exercise, blood pressure, blood sugar, bad habits";
    secondCell.answerQuestions      = @"LOG HEALTH DATA";
    [self.listSurveyArray addObject:secondCell];

    
}

-(void)fetchJasonForDetails {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kFetchJSON,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
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
                    [self.listSurveyArray addObject:cell];
                    [self.detailsTableView reloadData];
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
            self.choicePoints.text=[NSString stringWithFormat:@"Choice Points %ld",(long)[resultDict[@"totalpoints"] integerValue]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listSurveyArray.count  ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0 || indexPath.row==1)
    {
        static NSString *MyIdentifier = @"HealthSurvey";
        
        CHCHealthSurveyCell *cell =(CHCHealthSurveyCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell.borderView.layer.borderColor = [UIColor grayColor].CGColor;
        cell.borderView.layer.borderWidth  = 2.0;
        cell.borderView.layer.cornerRadius = 20;

        cell.titleHeading.text=[(self.listSurveyArray)[indexPath.row]titleHeading];
        cell.subTitle.text=[(self.listSurveyArray)[indexPath.row]subTitle];
        cell.snipset.text=[(self.listSurveyArray)[indexPath.row]snipset];
        cell.answerQuestions.text=[(self.listSurveyArray)[indexPath.row]answerQuestions];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"ArticleServe";
        CHCArticleCell * cell = (CHCArticleCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.borderView.layer.borderColor = [UIColor grayColor].CGColor;
        cell.borderView.layer.borderWidth  = 2.0;
        cell.borderView.layer.cornerRadius = 20;
        //just for check.....
        for (UIImageView *img in cell.contentView.subviews) {
            if ([img isKindOfClass:[UIImageView class]]) {
                [img removeFromSuperview];
            }
        }        
        //check completed...
        CHCArticleDetails *articleDetails = (self.listSurveyArray)[indexPath.row];

        cell.titleHeading.text=articleDetails.articleTitle;
        cell.snipset.text=articleDetails.articleSnippet;
        for (UIImageView *img in cell.contentView.subviews) {
            if ([img isKindOfClass:[UIImageView class]]) {
                [img removeFromSuperview];
            }
        }
      
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,10, 275, 65)];
        imv.center = CGPointMake(self.view.frame.size.width/2.0, imv.center.y);
        imv.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imv];
        if (articleDetails.articlePhoto.length == 0) {
            imv.image=[UIImage imageNamed:@"logo.png"];
        }else{
            [imv setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@assets/imgs/dash/%@",kImageIP,articleDetails.articlePhoto]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }

//        NSString *imageString =articleDetails.articlePhoto;
//        cell.articleImage.image=[UIImage imageNamed:imageString];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"hometohealthsurvey" sender:self];
    }else if (indexPath.row ==1) {
        [self performSegueWithIdentifier:@"hometohealthlog" sender:self];
    }else {
        CHCArticleDetails *articleDetails = (self.listSurveyArray)[indexPath.row];
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


- (IBAction)okButtonClick:(id)sender {
    if (self.enterUserID.text.length==0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:kAppName message:@"User ID must be some integer value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else {
    [[NSUserDefaults standardUserDefaults]setObject:self.enterUserID.text forKey:kUid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.customAlertView.hidden=YES;
        [self.enterUserID resignFirstResponder];
        if (self.listSurveyArray.count !=0) {
            [self.listSurveyArray removeAllObjects];
        }
        [self addDataForStaticCellsToDisplay];
        [self fetchJasonForDetails];
        [self getUserChoicePoints];
        [self.detailsTableView reloadData];
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
