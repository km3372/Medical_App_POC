//
//  CHCArticleDetails.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/18/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCArticleDetails.h"

@implementation CHCArticleDetails

- (instancetype)initWithDictionary:(NSDictionary*)dict{
    
    self = [super init];
    
    if(self){
        
        self.articleId      =[dict valueForKey:@"articleid"];
        self.answerId       =[dict valueForKey:@"answerid"];
        self.articleUrl     =[dict valueForKey:@"URI"];
        self.articleTitle   =[dict valueForKey:@"title"];
        self.articleSnippet =[dict valueForKey:@"snippet"];
        self.articlePhoto   =[dict valueForKey:@"imgsrc"];
        
    }
    return self;
}



@end
