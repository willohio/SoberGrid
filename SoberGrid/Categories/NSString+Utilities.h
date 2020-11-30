//
//  NSString+Utilities.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/16/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)
- (NSString*)userIdByRemovingSoberGrid;
- (NSString*)userIdAddedSoberGrid;
- (NSString*)stringWithExtensionforCount:(int)count;
+ (NSString*)formattedNumber:(int)number;

@end
