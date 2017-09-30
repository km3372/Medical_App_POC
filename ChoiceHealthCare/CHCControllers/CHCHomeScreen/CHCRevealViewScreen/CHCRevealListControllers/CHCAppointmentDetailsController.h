//
//  CHCAppointmentDetailsController.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/3/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCAppointmentDetailsController : UIViewController
@property (strong, nonatomic) NSString *docID;
@property (strong, nonatomic) NSDictionary *outputDictionary;
@property (strong, nonatomic)NSMutableDictionary *getDoctorsRequestDict;
@property (nonatomic) NSInteger type;
@end
