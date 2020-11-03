#import <UIKit/UIKit.h>
#import "User.h"
#import "GridImageView.h"
@interface GridCollectionViewCell : UICollectionViewCell {
    GridImageView * imageView;
    UIImageView *imgGreenDot;
    User *_cellUser;
}
- (void)customizewithUser:(User*)user;
- (User*)cellUser;
@end
