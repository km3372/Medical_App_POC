//
//  CHCRevealController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/18/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCRevealController.h"
#import "SWRevealViewController.h"
@interface CHCRevealController ()<UITableViewDataSource,UITableViewDelegate>

{
    NSMutableIndexSet *expandedSection;
   
}
@property (strong, nonatomic) IBOutlet UITableView *revealListTableView;
@property(nonatomic, strong) NSMutableArray *selectedActivities;
@property (nonatomic, strong )  NSMutableArray *totalRevealViews;
//@property (weak, nonatomic) IBOutlet UIView *myProfileView;
@property(nonatomic) BOOL subtract1;
@end

@implementation CHCRevealController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.myProfileView.layer.borderColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0  blue:222.0/255.0  alpha:1.0].CGColor;
//    self.myProfileView.layer.borderWidth = 1.0;
    
    
    

    if (!expandedSection) {
        expandedSection=[[NSMutableIndexSet alloc]init];
        self.selectedActivities=nil;
    }
    
    NSString *propertyListPath = [[NSBundle mainBundle] pathForResource:@"RevealViewList " ofType:@"plist"];
    self.totalRevealViews = [[NSArray arrayWithContentsOfFile:propertyListPath] mutableCopy];
    NSLog(@"%@",self.totalRevealViews);
      self.selectedActivities = [[NSMutableArray alloc]init];
  

    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
  
    
    if (self.revealViewController.isFromHome) {
       
        NSMutableDictionary * replaceObject = [(self.totalRevealViews)[0] mutableCopy];
        replaceObject[@"SectionName"] = @"Choose User";
        replaceObject[@"SubSections"] = @[@"Choose User"];
        (self.totalRevealViews)[0] = replaceObject;

        self.subtract1 = YES;
        
    }else{
        NSMutableDictionary * replaceObject = [(self.totalRevealViews)[0] mutableCopy];
        replaceObject[@"SectionName"] = @"Home";
        replaceObject[@"SubSections"] = @[@"Home"];
        (self.totalRevealViews)[0] = replaceObject;
        
     
        self.subtract1  = NO;
    }
   [self.revealListTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)sendNotificationToShowCustomAlert{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"enterUserID"
                                                           object:self
                                                         userInfo:nil];
    });

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            if ([segue.identifier isEqualToString:@"revealtohome"] && self.revealViewController.isFromHome) {
                [self.revealViewController.navigationController popToRootViewControllerAnimated:YES];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            }else{
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        
            [navController setViewControllers: @[dvc] animated: NO ];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];}
        };
        
    }
}

#pragma mark - tableview collapsable

-(BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section >= 0)
        return YES;
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.totalRevealViews.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self tableView:tableView canCollapseSection:section])
    {
        if ([expandedSection containsIndex:section])
        {
            NSDictionary *activityInfo = (self.totalRevealViews)[section];
            return [activityInfo[@"SubSections"] count];
        }
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        NSDictionary *activityInfo = (self.totalRevealViews)[indexPath.section];
//        NSString *colorCode = [activityInfo objectForKey:@"Color"];
        NSArray *subActivityList = activityInfo[@"SubSections"];
        
        if (!indexPath.row) {
            
//            [cell.layer setShadowColor:[UIColor blackColor].CGColor];
//            [cell.layer setShadowOffset:CGSizeMake(0, 3)];
//            [cell.layer setShadowOpacity:0.5f];
            
            cell.textLabel.text = subActivityList[indexPath.row];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
//            cell.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
//           cell.backgroundColor = [self getColorFromString:colorCode];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if (subActivityList.count > 1) {
                cell.imageView.image = [UIImage imageNamed:@"Add-Icon@2x.png"];
            }else{
            cell.imageView.image = [UIImage imageNamed:@""];
                
            }
           
            NSLog(@"indexpath section:%ld  expanded section:%@",(long)indexPath.section,expandedSection);
            
            
            BOOL currentlyExpanded = [expandedSection containsIndex:indexPath.section];
            if (currentlyExpanded) {
                if ([cell.imageView.image isEqual:[UIImage imageNamed:@"Add-Icon@2x.png"]]) {
                   cell.imageView.image=[UIImage imageNamed:@"Subtract-logo@2x.png"];
                }else{
                cell.imageView.image=[UIImage imageNamed:@""];
                }
               
                
                
            }
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        else {
            (cell.layer).shadowColor = [UIColor clearColor].CGColor;
            
            NSString *subActivityName = subActivityList[indexPath.row];
            cell.textLabel.text = subActivityName;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.backgroundColor = [UIColor whiteColor];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Color",subActivityName]];
            if ([self.selectedActivities containsObject:subActivityName]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    cell.imageView.contentMode = UIViewContentModeCenter ;
    cell.clipsToBounds = YES ;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.revealViewController.isFromHome) {
        if (indexPath.section == 0) {
            return 0;
        }
    }
    if (!indexPath.row){
        return 60;
    }
    else{
        return 40;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            NSLog(@"%ld",(long)indexPath.section);
            // only first row toggles exapand/collapse
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSInteger section = indexPath.section;
          
            BOOL currentlyExpanded = [expandedSection containsIndex:section];
            NSInteger rows;
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType=UITableViewCellAccessoryNone;
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSection removeIndex:section];
            }
            else
            {
                [expandedSection addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i=1; i<rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                if ([cell.imageView.image isEqual:[UIImage imageNamed:@"Subtract-logo@2x.png" ]]) {
                      cell.imageView.image=[UIImage imageNamed:@"Add-Icon@2x.png"];
                }else{
                cell.imageView.image=[UIImage imageNamed:@""];
                }
              
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                [self.revealListTableView reloadData];
                if ([cell.imageView.image isEqual:[UIImage imageNamed:@"Add-Icon@2x.png" ]]) {
                    cell.imageView.image=[UIImage imageNamed:@"Subtract-logo@2x.png"];
                }else{
                    cell.imageView.image=[UIImage imageNamed:@""];
                }
               
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
   
            
            switch (indexPath.section ) {
                case 0  :{
                     [self performSegueWithIdentifier:@"revealtohome" sender:self];
                    NSDictionary *object=(self.totalRevealViews)[0];
                    
                    if ([object[@"SectionName"] isEqualToString:@"Choose User"]) {
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            [self sendNotificationToShowCustomAlert];
                                        });
                                    }
                    break;}
                case 1:
                    [self performSegueWithIdentifier:@"revealtohowitworks" sender:self];
                    break;
             
            }
           
        }
        else {
            
            NSLog(@"%@",indexPath);
            NSDictionary *activityInfo = (self.totalRevealViews)[indexPath.section];
            NSArray *subActivityList = activityInfo[@"SubSections"];
            [self.selectedActivities addObject:subActivityList[indexPath.row]];
            //      NSLog(@"Selected Activities : %@",self.selectedActivities);
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            if (cell.isSelected) {
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            switch (indexPath.section) {
                case 2:{
                    switch (indexPath.row) {
                        case 1:
                           [self performSegueWithIdentifier:@"revealtohealthscorecard" sender:self];
                            break;
                        case 2:
//                            [self performSegueWithIdentifier:@"EditProfileController" sender:self];
                             [self performSegueWithIdentifier:@"NewProfileController" sender:self];
                            break;
                            
                    }
                    break;}
                    
                case 3:{
                    switch (indexPath.row) {
                        case 1:
                            [self performSegueWithIdentifier:@"revealtologhealth" sender:self];
                            break;
                        case 2:
                            [self performSegueWithIdentifier:@"revealtoarticlearchive" sender:self];
                            break;
                    }
                    break;}
                case 4:{
                    switch (indexPath.row) {
                        case 1:
                            [self performSegueWithIdentifier:@"revealtorequestappointment" sender:self];
                            break;
                        case 2:
                            [self performSegueWithIdentifier:@"revealtomedicationcatalog" sender:self];
                            break;
                            
                    }
                    break;}
                case 5:{
                    switch (indexPath.row) {
                        case 1:
                            [self performSegueWithIdentifier:@"revealtorewardscatalog" sender:self];
                            break;
                            
                    }
                    break;}
                
            }
            
        }
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row)
    {
        return;
    }
    
    else{
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *activityInfo = (self.totalRevealViews)[indexPath.section];
        NSArray *subActivityList = activityInfo[@"SubSections"];
        if ([self tableView:tableView canCollapseSection:indexPath.section])
        {
            [self.selectedActivities removeObject:subActivityList[indexPath.row]];
            //   NSLog(@"Selected Activities : %@",self.selectedActivities);
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}


@end
