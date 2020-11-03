//
//  PROExapandableCellTableViewCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/12/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "PROExapandableCell.h"
#import "SGButton.h"
@implementation PROExapandableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)customizeWithwithTitle:(NSString*)strTitle andSubtitle:(NSString*)strSubtitle withSubImage:(UIImage*)image{

    if ( [strTitle isEqualToString:@"Seeking"]) {
        NSLog(@"");
    }
    lblTitle=[[UHLabel alloc]initWithFrame:CGRectMake(12, 5, [UIScreen mainScreen].bounds.size.width - 45, 20)];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font = SGREGULARFONT(17.0);
    lblTitle.text = strTitle;
    lblTitle.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:lblTitle];

    
    if (strSubtitle) {
        [lblTitle sizeToFit];
        lblSubtitle = [[UHLabel alloc]initWithFrame:CGRectMake(lblTitle.frame.origin.x+lblTitle.frame.size.width + 2, 5, [UIScreen mainScreen].bounds.size.width-(lblTitle.frame.origin.x+lblTitle.frame.size.width + 2+10), 20)];
        lblSubtitle.textAlignment=NSTextAlignmentRight;
        lblSubtitle.textColor=[UIColor whiteColor];
        lblSubtitle.font = SGBOLDFONT(17.0);
        lblSubtitle.text=strSubtitle;
        lblSubtitle.numberOfLines = 0;
        [lblSubtitle resizeToHeight];
        NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
        paragrapStyle.alignment= NSTextAlignmentRight;
        [lblSubtitle setAttributes:@{NSFontAttributeName:SGBOLDFONT(17.0),NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragrapStyle}];
        [self.contentView addSubview:lblSubtitle];
    }else{
        imgViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -40 , 0, 30, 30)];
        imgViewLogo.image = image;
        [self.contentView addSubview:imgViewLogo];
    }
}
+ (CGFloat)heightForTitle:(NSString*)strTitle andSubtitle:(NSString*)strSubtitle{
    
    CGFloat titleWidth = [UHLabel getWidthOfText:strTitle forHight:20 withAttributes:@{NSFontAttributeName:SGREGULARFONT(17.0)}];
    
    CGFloat width=[UIScreen mainScreen].bounds.size.width-(12+titleWidth + 2+10);
    NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
    paragrapStyle.alignment= NSTextAlignmentRight;
    CGFloat subTitlheight=[UHLabel getHeightOfText:strSubtitle forWidth:width withAttributes:@{NSFontAttributeName:SGBOLDFONT(17.0),NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragrapStyle}];
    subTitlheight = subTitlheight + 5;
    if (subTitlheight > 40) {
        return subTitlheight;
    }
    return 40;
}

- (void)unload{
    [lblSubtitle removeFromSuperview];
    lblSubtitle = nil;
    [lblTitle removeFromSuperview];
    lblTitle = nil;
    [imgViewLogo removeFromSuperview];
    imgViewLogo = nil;
}

@end
