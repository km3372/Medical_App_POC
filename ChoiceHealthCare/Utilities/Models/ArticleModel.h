//
//  ArticleModel.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleModel : NSObject

@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *answerId;
@property (nonatomic, strong) NSString *articleUrl;
@property (nonatomic, strong) NSString *articleTitle;
@property (nonatomic, strong) NSString *articleSnippet;
@property (nonatomic, strong) NSString *articlePhotoPath;

+ (ArticleModel *)createArticleModelWithDictionary:(NSDictionary *)articleInfo;

@end
