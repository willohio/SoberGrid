//
//  PROExapandableCellTableViewCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/12/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UHLabel.h"

@interface PROExapandableCell : UITableViewCell{
    UHLabel     *lblSubtitle;
    UHLabel     *lblTitle;
    UIImageView *imgViewLogo;
}

- (void)unload;
- (void)customizeWithwithTitle:(NSString*)strTitle andSubtitle:(NSString*)strSubtitle withSubImage:(UIImage*)image;
+ (CGFloat)heightForTitle:(NSString*)strTitle andSubtitle:(NSString*)strSubtitle;

@end
