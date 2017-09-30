//
//  RewardsCatalogModel.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "RewardsCatalogModel.h"

@implementation RewardsCatalogModel

+ (RewardsCatalogModel *)createModelWithDictionary:(NSDictionary *)info {
    
//    Example return data
//    {
//        "rewardid": "11",
//        "title": "$10 Wal-Mart Gift Card",
//        "text": "$10 for Wal-Mart could buy you a lot of neat things!",
//        "pointval": "100",
//        "image": "/assets/imgs/rewards/amazon.jpg",
//        "redeemed": 1
//    }
    
    RewardsCatalogModel *model = [RewardsCatalogModel new];
    
    model.rewardId          = [info valueForKey:@"rewardid"];
    model.rewardTitle       = [info valueForKey:@"title"];
    model.rewardText        = [info valueForKey:@"text"];
    model.rewardPointValue  = @([[info valueForKey:@"pointval"] intValue]);
    model.rewardImageURL    = [NSURL URLWithString:[info valueForKey:@"image"]];
    
    return model;
}

@end
