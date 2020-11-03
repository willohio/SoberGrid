#define  kTagImageView 47584
#import "GridCollectionViewCell.h"
#import "GridImageView.h"
#import "DatabaseManager.h"
#import "SGXMPP.h"
#import "Filter.h"

@implementation GridCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customise];
    }
    return self;
}
- (void)customise{
    CGFloat cellwidth ;
    if (isIPad) {
        cellwidth = [UIScreen mainScreen].bounds.size.width/5 - 8;
    }else
        cellwidth= [UIScreen mainScreen].bounds.size.width/3 - 6;
    imageView = [GridImageView getImageViewWithFrame:CGRectMake(0, 0, cellwidth, cellwidth)];
    [self.contentView addSubview:imageView];
    
    imgGreenDot=[[UIImageView alloc]initWithFrame:CGRectMake(5, imageView.frame.size.height - 25, 16, 16)];
    imgGreenDot.image = [UIImage imageNamed:@"green_dot.png"];
    [imageView addSubview:imgGreenDot];
    self.clipsToBounds = YES;

}
- (void)customizewithUser:(User *)user
{
    self.tag = [user.struserId intValue];

    _cellUser = user;
    NSURL *urlImage;
    if (user.strProfilePicThumb.length > 0) {
        urlImage = [NSURL URLWithString:[user.strProfilePicThumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [imageView setImageURL:urlImage withName:user.strName withDelayMessageCount:[[SGXMPP sharedInstance] getUnreadMessagesCountForUserid:user.struserId] withDisatnce:[user.strDistance floatValue]];
    
    BOOL isOnline = [[DatabaseManager sharedInstance] getPresenceRepostForUserId:user.struserId];
    if(isOnline || user.isOnline){
        imgGreenDot.hidden = NO;
    }else{
        imgGreenDot.hidden = YES;
    }
   
    if ([user.strNeedRide boolValue]) {
        self.layer.borderColor = [UIColor blueColor].CGColor;
        self.layer.borderWidth = 1.5;
    }
    else if ([user.strBurningDesire boolValue]) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1.5;
    }else{
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0;
    }
   
}
- (User*)cellUser{
    return _cellUser;
}
- (void)setupImage
{
    
}

- (void)dealloc{
    imageView = nil;
}

- (void)setHighlighted:(BOOL)highlighted
{
   
}

@end
