//
//  CreateMedicationView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CreateMedicationView.h"

@interface CreateMedicationView()

@end

@implementation CreateMedicationView

+ (CreateMedicationView *)createMedicationViewFromXIB {
    
    CreateMedicationView *aView = [[NSBundle mainBundle] loadNibNamed:@"CreateMedicationView" owner:self options:nil][0];
    
    return aView;
}

- (IBAction)buttonClicked:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        ((UIButton*)sender).selected = !((UIButton *)sender).isSelected;
    }
}

@end
