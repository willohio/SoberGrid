//
//  EventCollcetionViewCell.m
//  ScenePop
//
//  Created by Haresh Kalyani on 7/3/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import "PICollcetionViewCell.h"

@implementation PICollcetionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)customizewithMediaURL:(NSURL *)url{

        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        data = nil;
    if (!_playView) {
        _playView=[[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_playView];
    }
    
    [_playView setImage:img];
    img = nil;

}
-(void)unload{
    [_playView removeFromSuperview];
    _playView = nil;
}

- (void)dealloc{
    _playView = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
