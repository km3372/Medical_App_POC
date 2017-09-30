//
//  MyToDoController.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "BaseViewController.h"

@interface MyToDoController : BaseViewController

///tell the VC to refresh it's API data.
///Gets called from AppDelegate when a remote push notification comes in
-(void)refresh;

@end
