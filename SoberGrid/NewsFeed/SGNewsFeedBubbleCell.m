//
//  SGNewsFeedBubbleCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//



#import "SGNewsFeedBubbleCell.h"
#import "Line.h"

@implementation SGNewsFeedBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier lineType:(int)lineType withLine:(BOOL)status
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        // Initialization code
        self.contentView.backgroundColor = SG_BACKGROUD_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        isLine = status;
        CGFloat height = self.frame.size.height;
        cellHeight = height;
        // Create Line
        if (status) {
            line = [[CellLineView alloc]initWithFrame:CGRectMake(kSGLine_Origin_X, 0,kSGLine_Size_Width, height) andType:lineType];
            [self.contentView addSubview:line];
            line.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight);
            
        }
        
        
        // Create BubbleView
        _bubbleContentView = [[KBPopupBubbleView alloc] initWithFrame:CGRectMake((status)?(SGBubbleOffsetFromRight+line.frame.size.width + line.frame.origin.x):SGBubbleOffsetFromRightWithourArrow, SGBubbleOffsetFromTop, CGRectGetWidth([UIScreen mainScreen].bounds) -   ((status)? (SGBubbleOffsetFromRight + line.frame.size.width + line.frame.origin.x):(2*(SGBubbleOffsetFromRightWithourArrow))), height - SGBubbleOffsetFromTop)];
        _bubbleContentView.drawableColor = [UIColor whiteColor];
        _bubbleContentView.cornerRadius = 5.0;
        [_bubbleContentView setUseDropShadow:false];
        [_bubbleContentView setPosition:0.05];
        [_bubbleContentView setUseBorders:false];
        [_bubbleContentView setSide:kKBPopupPointerSideLeft];
        [_bubbleContentView setUsePointerArrow:status];
        _bubbleContentView.draggable=false;
        [self.contentView addSubview:_bubbleContentView];

       // [self setBorderTo:_bubbleContentView];
        
        viewHeader = [[NewsFeedTopView alloc]initWithFrame:CGRectMake(kBubbleCellContentPaddingRight, kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 50)];
        viewHeader.delegate = self;
        [self.bubbleContentView addSubview:viewHeader];
        
        nsButtonsView = [[NewsFeedButtonsView alloc]initWithFrame:CGRectMake(kBubbleCellBubblePaddingRight,cellHeight - (55 + kBubbleCellBubblePaddingBottom), self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft, 50)];
        nsButtonsView.delegate = self;
        nsButtonsView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin);
        [self.bubbleContentView addSubview:nsButtonsView];
        
        lblSuggestedPost = [[UILabel alloc] init];
        
        [Line drawStraightLineFromStartPoint:CGPointMake(lblSuggestedPost.frame.origin.x, lblSuggestedPost.frame.origin.y+lblSuggestedPost.frame.size.height) toEndPoint:CGPointMake(lblSuggestedPost.frame.origin.x+lblSuggestedPost.frame.size.width, lblSuggestedPost.frame.origin.y+lblSuggestedPost.frame.size.height) ofWidth:0.5 inView:self.bubbleContentView];
            
        
        lblSuggestedPost.frame =CGRectMake(kBubbleCellContentPaddingRight, kBubbleCellBubblePaddingTop,self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 30);
        lblSuggestedPost.textColor = [UIColor blackColor];
        lblSuggestedPost.font = SGBOLDFONT(12);
        lblSuggestedPost.text = NSLocalizedString(@"Suggested Page", nil);
        [self.bubbleContentView addSubview:lblSuggestedPost];

    }
    return self;
}

- (void)customizeWithUser:(User*)objUser postDate:(NSDate*)postDate withMoodMessage:(NSString*)moodMessage isLiked:(BOOL)status{
    lblSuggestedPost.hidden = YES;
    viewHeader.frame = CGRectMake(kBubbleCellContentPaddingRight, kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 50);
    [viewHeader setUser:objUser withPostDate:postDate withMoodMessage:moodMessage];
     [line updateLineType:_feedType];
    
    [nsButtonsView setLikeStatus:status forPage:NO];
    if (hideLike) {
        [nsButtonsView hideLike];
    }
    if (hideComment) {
        [nsButtonsView hideComment];
    }

    // [self setBorderTo:nsButtonsView];
}
- (void)customizeWithPage:(SGPostPage*)page{
    lblSuggestedPost.hidden = NO;
    viewHeader.frame = CGRectMake(viewHeader.frame.origin.x, lblSuggestedPost.frame.origin.y + lblSuggestedPost.frame.size.height + 3, viewHeader.frame.size.width, viewHeader.frame.size.height);
    [viewHeader setPage:page];
       // [self setBorderTo:viewHeader];
    // Footer View
    
    [nsButtonsView setLikeStatus:[page.strIsLike boolValue] forPage:YES];
    [line updateLineType:_feedType];
    if (hideLike) {
        [nsButtonsView hideLike];
    }
    if (hideComment) {
        [nsButtonsView hideComment];
    }

    // [self setBorderTo:nsButtonsView];

    
}

#pragma mark - Hide Like Option
- (void)hideLikeOption{
    hideLike = YES;
    
}
#pragma mark - Hide Comment Option
- (void)hideCommentOption{
    hideComment = YES;
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
+ (CGFloat)bubbleWidthwithLine:(BOOL)status{
    return CGRectGetWidth([UIScreen mainScreen].bounds) - ((status)?((SGBubbleOffsetFromRight + (kSGLine_Size_Width) + (kSGLine_Origin_X))):(2*(SGBubbleOffsetFromRightWithourArrow)));
}




- (void)dealloc{
    self.delegate = nil;
    line = nil;
    nsButtonsView = nil;
    viewHeader = nil;
    lblSuggestedPost = nil;
}


@end
