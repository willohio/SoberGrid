//
//  SGPostPhoto.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "SGPost.h"

@interface SGPostPhoto : SGPost <NSCopying>
@property (nonatomic,strong)UIImage         *postImage;
@property (nonatomic,strong)NSString        *strImageUrl;
@property (nonatomic,strong)NSString        *strDesrciption;
@property (nonatomic,strong)NSString        *strThumImageUrl;
- (id)initWithDictionary:(NSDictionary*)dict;
@end
