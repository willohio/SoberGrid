//
//  NSDate+Utilities.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/16/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)
- (NSInteger)getAge{
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:self
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return age;
}
-(NSDate *)offsetYear:(int)numOfYears {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:numOfYears];
    
    return [calendar dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}
- (BOOL)isTodayDate{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return true;
    }
    return false;
}
- (NSString*)formattedString{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"MM/dd/yyyy"];
    return [dateformatter stringFromDate:self];
}
- (NSString*)formattedStringwithFormat:(NSString*)format{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:format];
    return [dateformatter stringFromDate:self];
}
- (NSDate*)formattedDatefromstring:(NSString*)str{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    return [dateformatter dateFromString:str];
}
- (NSMutableDictionary*)monthsandDays{
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self  toDate:[NSDate date]  options:0];
    NSInteger months = [comps month];
    NSInteger days = [comps day];
    NSInteger year = [comps year];
    
    [dictTemp setObject:[NSString stringWithFormat:@"%ld",(long)months] forKey:@"month"];
    [dictTemp setObject:[NSString stringWithFormat:@"%ld",(long)days] forKey:@"day"];
    [dictTemp setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"year"];
    return dictTemp;
}
- (NSString *)getSuffix{
    NSInteger day = [[[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] components:NSDayCalendarUnit fromDate:self] day];
    if (day >= 11 && day <= 13) {
        return @"th";
    } else if (day % 10 == 1) {
        return @"st";
    } else if (day % 10 == 2) {
        return @"nd";
    } else if (day % 10 == 3) {
        return @"rd";
    } else {
        return @"th";
    }
}
@end
