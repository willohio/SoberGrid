//
//  SGPostPage.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGPostPage : NSObject <NSCopying>

@property (nonatomic,assign) int              likesCount;
@property (nonatomic,assign) int              commentsCount;
@property (nonatomic,strong) NSString *strIsLike;
@property (nonatomic,strong) NSString *strPageBanner_Url;
@property (nonatomic,strong) NSString *strPageDiscription;
@property (nonatomic,strong) NSString *strPageId;
@property (nonatomic,assign) int       pageOrder;
@property (nonatomic,strong) NSString *strPageProfile_Url;
@property (nonatomic,strong) NSString *strPageTitle;
@property (nonatomic,strong) NSString *strPage_Phone;
@property (nonatomic,strong) NSString *strPage_Url;
@property (nonatomic,strong) NSString *strThumImageUrl;


- (void)setValuesfromDictionary:(NSDictionary*)dict;

@end
