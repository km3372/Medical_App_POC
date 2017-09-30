//
//  CHCArticleCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/18/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCArticleCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIView *borderView;
@property (strong, nonatomic) IBOutlet UILabel *titleHeading;
@property (strong, nonatomic) IBOutlet UILabel *snipset;
@property (strong, nonatomic) IBOutlet UILabel *readArticle;



@end
