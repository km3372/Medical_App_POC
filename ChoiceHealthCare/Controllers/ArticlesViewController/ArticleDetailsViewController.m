//
//  ArticleDetailsViewController.m
//  
//
//  Created by Chris Morse on 8/23/16.
//
//

#import "ArticleDetailsViewController.h"

#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "UserModel.h"

@interface ArticleDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ArticleDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Read Article"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    

    //Set the webView's ScrollView delegate to ourselves so that we can track scrolling
    self.webView.scrollView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    //Load the article
    NSURL* url = [NSURL URLWithString:self.model.articleUrl];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftNavButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //If the user has reached the bottom of the article mark it as read
    UserModel* user = [UserModel currentUser];
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height-self.webView.frame.size.height-100) {

        //Call Article Read API
        NSString* apiPath = [NSString stringWithFormat:@"%@%@", kArticleRead, self.model.articleId];
        [[APIClass sharedManager] apiCallWithRequest:nil forApi:apiPath requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            //Update UserModel with results so the counter increases
            NSNumber* points = resultDict[@"points"][@"totalPoints"];
            if (points) {
                user.pointTotal = points;
                [user synchronizeUser];
            }
        } onCancelation:nil];
    }
}

#pragma mark - UIWebViewDelgate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES; //([request.URL.absoluteString isEqualToString:self.model.articleUrl]);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webView didFailLoadWithError: %@", error);
}


@end
