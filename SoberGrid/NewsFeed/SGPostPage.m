//
//  SGPostPage.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "SGPostPage.h"

@implementation SGPostPage

- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setStrPageBanner_Url:[self.strPageBanner_Url copyWithZone:zone]];
        [copy setStrPageDiscription:[self.strPageDiscription copyWithZone:zone]];
        [copy setStrPageId:[self.strPageId copyWithZone:zone]];
        [copy setStrPageProfile_Url:[self.strPageProfile_Url copyWithZone:zone]];
        [copy setStrPageTitle:[self.strPageTitle copyWithZone:zone]];
        [copy setStrPage_Url:[self.strPage_Url copyWithZone:zone]];
        [copy setStrPage_Phone:[self.strPage_Phone copyWithZone:zone]];
        [copy setLikesCount:self.likesCount];
        [copy setCommentsCount:self.commentsCount];
        
    }
    return copy;
}

- (void)setValuesfromDictionary:(NSDictionary*)dict{
    self.likesCount = (dict[@"Totallikes"]) ? [dict[@"Totallikes"] intValue] : 0;
    self.strIsLike = (dict[@"islike"]) ? dict[@"islike"] : @"0";
    self.strPageBanner_Url = (dict[@"page_bannerpicture"]) ? dict[@"page_bannerpicture"] : @"";
    //self.strPageBanner_Url = @"http://app.sobergrid.co.uk/admin/userimages/profileimg/1437546520image.jpg";
    self.strPageDiscription = (dict[@"page_description"]) ? dict[@"page_description"] : @"";
    self.strPageId = (dict[@"page_id"]) ? dict[@"page_id"] : @"";
    self.pageOrder = (dict[@"page_order"]) ? [dict[@"page_order"] intValue]: 0;
    self.strPageProfile_Url  = (dict[@"page_profilepicture"]) ? dict[@"page_profilepicture"] : @"";
  //  self.strPageProfile_Url = @"http://app.sobergrid.co.uk/admin/userimages/profileimg/1437546520image.jpg";
    self.strPageTitle  = (dict[@"page_title"]) ? dict[@"page_title"] : @"";
    self.strPage_Url  = (dict[@"page_url"]) ? dict[@"page_url"] : @"";
    self.strPage_Phone = (dict[@"page_phone"]) ? dict[@"page_phone"] : @"";
   // self.strThumImageUrl = (dict[@"compress_media"])? dict[@"compress_media"]:nil;
    self.strThumImageUrl = @"http://app.sobergrid.co.uk/admin/userimages/profileimg/1437546520image.jpg";

}

@end
