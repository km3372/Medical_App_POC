//
//  RewardsCatalogModel.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 08/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardsCatalogModel : NSObject

@property (nonatomic, strong) NSString *rewardId;
@property (nonatomic, strong) NSString *rewardTitle;
@property (nonatomic, strong) NSString *rewardText;
@property (nonatomic, strong) NSNumber *rewardPointValue;
@property (nonatomic, strong) NSURL *rewardImageURL;

+ (RewardsCatalogModel *)createModelWithDictionary:(NSDictionary *)info;

@end
