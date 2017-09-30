//
//  APIClass.m
//  kPetCrumbsAPI
//
//  Created by Mindbowser on 15/07/13.
//  Copyright (c) 2013 Mindbowser. All rights reserved.
//
//server

//

#import "APIClass.h"
#import "Reachability.h"
#import "ConnectionManager.h"
#import "CHCConstants.h"
#import "APINames.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import <EasyImage/UIImage+Resize.h>

#define DEFAULT_TIMEOUT 30.0f

static NSString * kAcceptType = @"application/json";
static NSString * kContentType = @"application/x-www-form-urlencoded";
// @"application/json; charset=UTF-8";
static NSString * kEncodeType = @"gzip";
static NSString * kLanguageType = @"en";
static NSString * kAuthorization = @"Basic bG9jYWxtb3RpdmVzOmxvY2FsbW90aXZlcw==";

NSString * const kLMStagingURL = @"https://reapon.com/";

//NSString * const kLMLocalHostUrl = @"http://52.10.100.99:3000/";

@interface APIClass ()

{
    FetchBlock _fetchBlock;
    FetchCancelBlock _cancelBlock;
    NSMutableData *responseData;
    NSURLConnection *urlConnection;
}

@end

static APIClass *sharedInstance = nil;

@implementation APIClass

+ (id)sharedManager
{    
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    }
    return sharedInstance;
}

///Called by the api when the session has expired so we need to get a new token.
-(void)reloginOnCompletion:(FetchBlock)fetchBlock
             onCancelation:(FetchCancelBlock)cancel {

    UserModel* user = [UserModel currentUser];
    if (user.email == nil || user.password == nil) {
        AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delgate initalizeRootControllerAs:Signing];
        NSLog(@"No saved user credentials so we have to force the user to login again.");
        cancel();
    }
    NSDictionary *postDictionary = @{KUsername:user.email, kPassword:user.password};

    _fetchBlock = [fetchBlock copy];
    _cancelBlock = [cancel copy];
    responseData = [NSMutableData data];

    [self apiCallWithRequest:postDictionary forApi:kLogin requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue]) {
            [user updateWithDictionary:resultDict[@"data"]];
            [user synchronizeUser];
        }
        fetchBlock(resultDict, error);
    } onCancelation:^{
        cancel();
    }];

}


-(void)apiCallWithRequest:(NSDictionary *)dictRequest
                   forApi:(NSString *)apiName
              requestMode:(NSString*)mode
             onCompletion:(FetchBlock)fetchBlock
            onCancelation:(FetchCancelBlock)cancel {

    if(![self isInternetAvailable]) {
        cancel();
        return;
    }

    NSError *error = nil;
    NSString *postUrl;
    UserModel* user = [UserModel currentUser];

    //If our session is expired do a login first
    if ([user isSessionExpired] && apiName != kLogin && apiName != kSignUp) {
        [self reloginOnCompletion:^(NSDictionary *resultDict, NSError *error) {
            //Once login is complete call ourselves again to finish the API call.
            [self apiCallWithRequest:dictRequest forApi:apiName requestMode:mode onCompletion:fetchBlock onCancelation:cancel];
        } onCancelation:^{
            NSLog(@"Relogin failed so telling caller API was cancelled.");
            cancel();
            return;
        }];
    } else {
        _fetchBlock = [fetchBlock copy];
        _cancelBlock = [cancel copy];
        responseData = [NSMutableData data];


        NSLog(@"RequestInfo : %@",dictRequest);


        postUrl = [NSString stringWithFormat:@"%@%@",kLMStagingURL,apiName];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:postUrl]];
        NSString *jsonBody;
        NSData *requestData;

        //Add our custom HTTP headers
        if (user.deviceToken) {
            [request setValue:user.deviceToken forHTTPHeaderField:@"X-DEVICE-TOKEN"];
        }
        if (user.sessionToken) {
            NSString* token = [NSString stringWithFormat:@"Bearer %@", user.sessionToken];
            [request setValue:token forHTTPHeaderField:@"Authentication"];
        }

        if(([mode isEqualToString:@"POST"] || [mode isEqualToString:@"PUT"]) && (dictRequest|| [mode isEqualToString:@"GET"])){

            requestData = [NSJSONSerialization dataWithJSONObject:dictRequest options:NSJSONWritingPrettyPrinted error:&error];

            jsonBody = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        }

        NSLog(@"UrlRequest: %@\n%@",postUrl,jsonBody);

        request.HTTPMethod = mode;


        if(requestData)
            request.HTTPBody = requestData;
        [request setTimeoutInterval:DEFAULT_TIMEOUT];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSLog(@"UrlRequest: %@",[self formatURLRequest:request ]);
        urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:(id<NSURLConnectionDelegate>)self];
    }
}

- (void)updateProfileImage:(UIImage*)image
              onCompletion:(FetchBlock)fetchBlock
             onCancelation:(FetchCancelBlock)cancel {

    if(![self isInternetAvailable]) {
        cancel();
        return;
    }

    NSString *postUrl;
    UserModel* user = [UserModel currentUser];

    //If our session is expired do a login first
    if ([user isSessionExpired]) {
        [self reloginOnCompletion:^(NSDictionary *resultDict, NSError *error) {
            [self updateProfileImage:image onCompletion:fetchBlock onCancelation:cancel];
        } onCancelation:^{
            NSLog(@"Relogin failed so telling caller API was cancelled.");
            cancel();
            return;
        }];
    } else {
        _fetchBlock = [fetchBlock copy];
        _cancelBlock = [cancel copy];
        responseData = [NSMutableData data];

        postUrl = [NSString stringWithFormat:@"%@%@",kLMStagingURL, kUpdateProfileImage];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:postUrl]];

        //Add our custom HTTP headers
        if (user.deviceToken) {
            [request setValue:user.deviceToken forHTTPHeaderField:@"X-DEVICE-TOKEN"];
        }
        if (user.sessionToken) {
            NSString* token = [NSString stringWithFormat:@"Bearer %@", user.sessionToken];
            [request setValue:token forHTTPHeaderField:@"Authentication"];
        }

        //Set multi-part form data
        NSString* boundaryConstant = @"MultipartBoundary-ChoicePoints";
        NSString* contentType = [@"multipart/form-data;boundary=" stringByAppendingString:boundaryConstant];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

        // resize & add image
        NSMutableData* uploadData = [NSMutableData new];
        UIImage* resized = [image scaleImageToSize:CGSizeMake(512, 512)];
        NSData* imageData = UIImageJPEGRepresentation((resized) ? resized : image, 0.81);

        [uploadData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:imageData];
        [uploadData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];

        request.HTTPMethod = kModePost;
        request.HTTPBody = uploadData;
        [request setTimeoutInterval:DEFAULT_TIMEOUT];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;

        NSLog(@"UrlRequest: %@",[self formatURLRequest:request ]);
        urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:(id<NSURLConnectionDelegate>)self];
    }
}


- (NSString *)formatURLRequest:(NSURLRequest *)request
{
    NSMutableString *message = [NSMutableString stringWithString:@"---REQUEST------------------\n"];
    [message appendFormat:@"URL: %@\n",(request.URL).description ];
    [message appendFormat:@"METHOD: %@\n",request.HTTPMethod];
    for (NSString *header in request.allHTTPHeaderFields)
    {
        [message appendFormat:@"%@: %@\n",header,[request valueForHTTPHeaderField:header]];
    }
    [message appendFormat:@"BODY: %@\n",[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    [message appendString:@"----------------------------\n"];
    return [NSString stringWithFormat:@"%@",message];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == urlConnection) {
        responseData.length = 0;
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    if (connnection == urlConnection) {
        [responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == urlConnection) {
      
       // PresentAlertViewWithMessageAndTitle(@"Connection Error", [error localizedDescription],@"OK");
        _cancelBlock();
       
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %d bytes of data",(int)responseData.length);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];

    if (responseDict)
    NSLog(@"RESPONSE JSON Output :%@",[self getJSON:responseDict]);
   
    _fetchBlock(responseDict,myError);
}


-(BOOL)isInternetAvailable {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
        if (_cancelBlock){
            _cancelBlock();
        }

    } else
        return YES;

    return NO;
}

- (NSString*)getJSON:(NSDictionary*)dict{
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

- (NSDictionary*)getDict:(NSString*)strChangetoJSON{

    NSError *error = nil;
    NSData *data = [strChangetoJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    return jsonResponse;
}

@end
