//
//  CHCArticleController.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/19/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCArticleController : UIViewController
@property (strong, nonatomic) NSString *webUrlString;
@property (strong, nonatomic) NSString *choicePoints;
@property (nonatomic) BOOL isFromArticleArchive;
@end
