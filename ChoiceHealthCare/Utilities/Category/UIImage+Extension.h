//
//  UIImage+Extension.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)getImageFromColor:(UIColor *)color
                       andSize:(CGSize)size;

+ (UIImage *)getImageFromText:(NSString *)text
                withTextColor:(UIColor *)textColor
                     textFont:(UIFont *)font
                 andImageSize:(CGSize)size;

+ (UIImage *)getImageName:(NSString *)imageName
              withBGColor:(UIColor *)color
                  andSize:(CGSize)size;

@end
