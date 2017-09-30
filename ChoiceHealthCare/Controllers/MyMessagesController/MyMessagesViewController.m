//
//  MyMessagesViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyMessagesViewController.h"
#import "MyMessageCell.h"

static NSString * CellIdentifier = @"MyMessageCell";

@interface MyMessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MyMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeMenu andTitle:@"My Messages"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];

    self.tableView.estimatedRowHeight = 53;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyMessageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    self.automaticallyAdjustsScrollViewInsets = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegates and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyMessageCell *cell = (MyMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"MyMessageCell" owner:self options:nil][0];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

@end
