//
//  UIImage+Extension.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

+ (UIImage *)getImageFromColor:(UIColor *)color andSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)getImageName:(NSString *)imageName
              withBGColor:(UIColor *)color
                  andSize:(CGSize)size {
    
    color = color == nil ? [UIColor clearColor] : color;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    if (imageName) {
        UIImage *internalImage = [UIImage imageNamed:imageName];
        
        if (internalImage) {
            
            [internalImage drawAtPoint:CGPointMake(size.width/2 - internalImage.size.width/2, size.height/2 - internalImage.size.width)];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)getImageFromText:(NSString *)text withTextColor:(UIColor *)textColor textFont:(UIFont *)font andImageSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    NSDictionary *attr = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font};
    CGSize textSize = [text sizeWithAttributes:attr];
    CGRect textRect = CGRectMake(size.width/2 - textSize.width/2, size.height/2 - textSize.height/2-10, textSize.width, textSize.height);
    
    [text drawInRect:textRect withAttributes:attr];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
