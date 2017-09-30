//
//  CHCArticleDetails.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/18/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHCArticleDetails : NSObject

@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *answerId;
@property (nonatomic, strong) NSString *articleUrl;
@property (nonatomic, strong) NSString *articleTitle;
@property (nonatomic, strong) NSString *articleSnippet;
@property (nonatomic, strong) NSString *articlePhoto;

- (instancetype)initWithDictionary:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;

@end
