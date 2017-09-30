//
//  ArticlesTableCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ArticlesTableCell.h"
#import "ArticleModel.h"
#import "CommonFilesImporter.h"
#import "APINames.h"


@interface ArticlesTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *articleTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *articleDiscLabel;
@property (nonatomic, weak) IBOutlet UIImageView *articleImageView;

@end

@implementation ArticlesTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpCellWithArticleModel:(ArticleModel*)model {
   
    self.articleTitleLabel.text = model.articleTitle;
    self.articleDiscLabel.text = model.articleSnippet;
    
    NSURL *photoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@assets/imgs/dash/%@",kImageIP,model.articlePhotoPath]];
    
    [self.articleImageView setImageWithURL:photoUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

@end
