
#import "StyledPullableView.h"

/**
 @author Fabio Rodella fabio@crocodella.com.br
 */

@implementation StyledPullableView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
       
        self.autoresizesSubviews = YES;
        
        UIToolbar*    _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _toolbar.barStyle = 1;
        _toolbar.userInteractionEnabled=false;
        [self addSubview:_toolbar];
        _toolbar.superview.layer.allowsGroupOpacity=NO;
    }
    return self;
}
- (void)setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
}

@end
