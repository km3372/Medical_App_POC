//
//  APIClass.h
//  
//
//  Created by Mindbowser on 15/07/13.
//  Copyright (c) 2013 Mindbowser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^FetchBlock)(NSDictionary *resultDict, NSError *error);
typedef void (^FetchCancelBlock)();

@interface APIClass : NSObject

+ (id)sharedManager;
-(void)apiCallWithRequest:(NSDictionary *)dictRequest
                   forApi:(NSString *)apiName
              requestMode:(NSString*)mode
             onCompletion:(FetchBlock)fetchBlock
            onCancelation:(FetchCancelBlock)cancel;

- (void)updateProfileImage:(UIImage*)image
              onCompletion:(FetchBlock)fetchBlock
             onCancelation:(FetchCancelBlock)cancel;

@property (NS_NONATOMIC_IOSONLY, getter=isInternetAvailable, readonly) BOOL internetAvailable;


@end


