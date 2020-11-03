//
//  NSString+Utilities.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/16/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)
- (NSString *)userIdAddedSoberGrid{
    return [self stringByAppendingString:@"_sobergrid"];
}
- (NSString *)userIdByRemovingSoberGrid{
    return [self stringByReplacingOccurrencesOfString:@"_sobergrid" withString:@""];
}
- (NSString *)stringWithExtensionforCount:(int)count{
    if (count > 1) {
        return [NSString stringWithFormat:@"%@s",self];
    }else
        return self;
}
+ (NSString*)formattedNumber:(int)number{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    return formatted;
}



@end
