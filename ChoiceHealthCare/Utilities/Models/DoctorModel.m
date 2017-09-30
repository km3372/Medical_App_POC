//
//  DoctorModel.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/30/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "DoctorModel.h"

@implementation DoctorModel

+ (DoctorModel *)createArticleModelWithDictionary:(NSDictionary *)doctorInfo {
    
    
    DoctorModel *model = [DoctorModel new];
    
    model.docId      = [doctorInfo valueForKey:@"docid"];
    model.name       = [doctorInfo valueForKey:@"name"];
    model.specialty     = [doctorInfo valueForKey:@"specialty"];
    model.provider   = [doctorInfo valueForKey:@"provider"];
    model.distance = [doctorInfo valueForKey:@"distance"];
    model.address   = [doctorInfo valueForKey:@"address"];
    model.cityState   = [doctorInfo valueForKey:@"citystate"];
    model.avatar   = [doctorInfo valueForKey:@"avatar"];
    
    return model;
}
@end
