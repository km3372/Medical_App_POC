//
//  NSString+MD5.h
//  ChoiceHealthCare
//
//  Source: http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa#2018626
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *MD5String;

@end
