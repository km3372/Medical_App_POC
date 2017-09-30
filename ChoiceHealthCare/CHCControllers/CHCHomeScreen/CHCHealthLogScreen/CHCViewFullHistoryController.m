//
//  CHCViewFullHistoryController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 11/2/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCViewFullHistoryController.h"
#import "LoggerDetailsTableViewCell.h"
#import "SWRevealViewController.h"
@interface CHCViewFullHistoryController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UITableView *logDetailsTableview;
@property (strong, nonatomic) NSMutableArray *loggerDetailsArray;
@property (weak, nonatomic) IBOutlet UIView *loggerDetailsView;

@end

@implementation CHCViewFullHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loggerDetailsView.layer.borderColor = [UIColor grayColor].CGColor;
    self.loggerDetailsView.layer.borderWidth  = 2.0;
    self.loggerDetailsView.layer.cornerRadius = 20;
    self.loggerDetailsArray = [NSMutableArray new];
    self.loggerDetailsArray = (self.viewFullHistory)[@"data"];
    self.titleLabel.text = (self.viewFullHistory)[@"name"];
    self.averageLabel.text =[NSString stringWithFormat:@"Average: %.2f",[(self.loggerDetailsArray)[0][@"average"] floatValue]] ;
    NSLog(@"%@",self.viewFullHistory);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loggerDetailsArray.count != 0) {
        return self.loggerDetailsArray.count;
    }
    return 0;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 30.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"LoggerCell";
    
    LoggerDetailsTableViewCell *cell =(LoggerDetailsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    NSDictionary *cellInfo=(self.loggerDetailsArray)[indexPath.row];
    if (cellInfo[@"data"]) {
        cell.unitsLabel.text = [NSString stringWithFormat:@"%@",cellInfo[@"data"]];
        cell.dateLabel.text=cellInfo[@"timestamp"];
        if (indexPath.row % 2) {
            cell.backgroundColor = [UIColor whiteColor];
        }else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.unitsLabel.text = @"";
        cell.dateLabel.text=@"";
        
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClicked:(id)sender {
       [self performSegueWithIdentifier:@"backtologhealthdata" sender:self];
//   [self.revealViewController.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
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
