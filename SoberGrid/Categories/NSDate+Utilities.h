//
//  NSDate+Utilities.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/16/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utilities)
- (NSInteger)getAge;
-(NSDate *)offsetYear:(int)numOfYears;
- (BOOL)isTodayDate;
- (NSString*)formattedString;
- (NSString*)formattedStringwithFormat:(NSString*)format;
- (NSDate*)formattedDatefromstring:(NSString*)str;
- (NSMutableDictionary*)monthsandDays;
- (NSString *)getSuffix;
@end
