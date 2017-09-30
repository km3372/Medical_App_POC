//
//  ArticleDetailsViewController.h
//  
//
//  Created by Chris Morse on 8/23/16.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ArticleModel.h"

@interface ArticleDetailsViewController : BaseViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) ArticleModel* model;


@end
