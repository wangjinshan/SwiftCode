//
//  NSString+Demo.m
//  SwiftCode
//
//  Created by 王金山 on 2022/3/7.
//

#import "NSString+Demo.h"

@implementation NSString (Demo)


- (NSMutableAttributedString *)toHtmlString {
    id temp = [self dataUsingEncoding: NSUnicodeStringEncoding];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithData: temp
                                                   options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                   documentAttributes:nil
                                                   error:nil];
    return attributedString;
}



@end
