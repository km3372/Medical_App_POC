//
//  ConnectionManager.h
//  LVP Client IOS
//
//  Created by Ayush Jain on 14/08/12.
//  Copyright (c) 2012 ayush.jain@mindbowser.com. All rights reserved.
//

//I have this class mainly because of to establish connection with server. All the application requests hit to server from here. But as it is shared class, i also use it as global class to pass data between controllers thats why these many properties.

#import <Foundation/Foundation.h>

@class Reachability;
@interface ConnectionManager : NSObject
{    
    Reachability* internetReach;
    Reachability *wifiReach;
    NSURLConnection *connection;
    int countForFacebookAlert;
    NSMutableDictionary *paramForFacebookPost;
}


@property (nonatomic, retain) NSURLConnection *connection;
@property(nonatomic,assign) int countForFacebookAlert;
@property(nonatomic,retain) NSMutableDictionary *paramForFacebookPost;

+ (BOOL)currentNetworkStatus;
+(ConnectionManager *)sharedConnectionManager;
//-(void)callAPI:(NSString *)API withDictionary:(NSDictionary *)dictionary forConnectionDelegateObject:(NSObject *)object;

@end
