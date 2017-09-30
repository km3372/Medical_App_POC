//
//  ArticleModel.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel

+ (ArticleModel *)createArticleModelWithDictionary:(NSDictionary *)articleInfo {
    
    
    ArticleModel *model = [ArticleModel new];
    
    model.articleId      = [articleInfo valueForKey:@"articleid"];
    model.answerId       = [articleInfo valueForKey:@"answerid"];
    model.articleUrl     = [articleInfo valueForKey:@"URI"];
    model.articleTitle   = [articleInfo valueForKey:@"title"];
    model.articleSnippet = [articleInfo valueForKey:@"snippet"];
    model.articlePhotoPath   = [articleInfo valueForKey:@"imgsrc"];
    
    return model;
}

@end
