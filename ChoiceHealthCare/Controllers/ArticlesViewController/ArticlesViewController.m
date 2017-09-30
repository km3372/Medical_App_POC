//
//  ArticlesViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ArticlesViewController.h"
#import "ArticlesTableCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CommonFilesImporter.h"
#import "ArticleModel.h"
#import "InstructionsViewController.h"
#import "ArticleDetailsViewController.h"

@interface ArticlesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *articleListArray;

@end

@implementation ArticlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Articles"];
   
    [self addBottomBarViewWithType:BottomBarTypeDefault];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticlesTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ArticleCell"];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self fetchArticleArchive];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

- (NSMutableArray *)articleListArray {
    
    if (!_articleListArray) {
        
        _articleListArray = [NSMutableArray new];
    }
    return _articleListArray;
}

#pragma mark - Event Handling 

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)instructionButtonClicked:(id)sender {
    
    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:controller animated:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ArticleDetailsViewController class]]) {
        ((ArticleDetailsViewController*)segue.destinationViewController).model = sender;
    }
}

#pragma mark - TableView Delegates and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.articleListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ArticlesTableCell *cell = (ArticlesTableCell *)[tableView dequeueReusableCellWithIdentifier:@"ArticleCell"];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"ArticlesTableCell" owner:self options:nil][0];
    }
    
    [cell setUpCellWithArticleModel:(self.articleListArray)[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleModel* model = (self.articleListArray)[indexPath.row];
    [self performSegueWithIdentifier:@"showArticleDetail" sender:model];
}

#pragma mark - API Calls

-(void)fetchArticleArchive {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kArticlesArchiveJSON
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error) {
                                        
        if ([resultDict[@"success"] boolValue]) {
            
            NSArray *dataArray = resultDict[@"data"];
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                for (int i=0; i<dataArray.count; i++) {
                    
                    NSDictionary *articleInfo = dataArray[i];
                    
                    ArticleModel *model = [ArticleModel createArticleModelWithDictionary:articleInfo];
                    
                    [self.articleListArray addObject:model];
                }
                
                [self.tableView reloadData];
            }
        }else{
            
            NSString *errorMessage = resultDict[@"message"];
            
            [Utils showAlertForString:errorMessage];
        }
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        
    } onCancelation:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [Utils showAlertForString:kInternetConnectionNotAvailable];
    }];
}


@end
