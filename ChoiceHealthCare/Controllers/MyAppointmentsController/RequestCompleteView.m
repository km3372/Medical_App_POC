//
//  RequestCompleteView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "RequestCompleteView.h"

@implementation RequestCompleteView

+ (RequestCompleteView *)createRequestCompleteViewFromXIB {
    
    RequestCompleteView *aView = [[NSBundle mainBundle] loadNibNamed:@"RequestCompleteView" owner:self options:nil][0];
    
    return aView;
}

@end
