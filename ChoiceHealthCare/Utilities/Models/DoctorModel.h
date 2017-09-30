//
//  DoctorModel.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/30/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoctorModel : NSObject
@property (nonatomic, strong) NSString *docId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *specialty;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *cityState;
@property (nonatomic, strong) NSString *avatar;

+ (DoctorModel *)createArticleModelWithDictionary:(NSDictionary *)doctorInfo;
@end
