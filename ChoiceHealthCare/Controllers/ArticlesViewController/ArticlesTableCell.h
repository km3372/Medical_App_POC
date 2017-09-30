//
//  ArticlesTableCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArticleModel;

@interface ArticlesTableCell : UITableViewCell

- (void)setUpCellWithArticleModel:(ArticleModel*)model;

@end
