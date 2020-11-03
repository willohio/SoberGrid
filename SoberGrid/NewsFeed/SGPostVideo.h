//
//  SGPostVideo.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "SGPost.h"

@interface SGPostVideo : SGPost <NSCopying>
@property (nonatomic,strong)UIImage         *thumbImage;
@property (nonatomic,strong)NSString        *strThumbUrl;
@property (nonatomic,strong)NSString        *strVideoUrl;
@property (nonatomic,strong)NSString        *strDesrciption;

- (id)initWithDictionary:(NSDictionary*)dict;

@end
