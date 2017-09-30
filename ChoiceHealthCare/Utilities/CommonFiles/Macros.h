//
//  Macros.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 23/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>


#define IMAGE(x) [UIImage imageNamed:x]

#define SHOW_HUD(x)      [MBProgressHUD showHUDAddedTo:x animated:YES]
#define HIDE_ALL_HUDS(x) [MBProgressHUD hideAllHUDsForView:x animated:YES]
