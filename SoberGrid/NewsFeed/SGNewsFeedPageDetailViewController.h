//
//  SGNewsFeedPageDetailViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/21/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

typedef enum {
    kDetailModePage,
    kDetailModeGroup,
}kDetailMode;
#import <UIKit/UIKit.h>
#import "SGPostPage.h"
#import "SGGroup.h"

@interface SGNewsFeedPageDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *tblPageDetail;
    NSMutableArray *arrOnlyImages;
    kDetailMode _detailMode;
    SGPostPage *_objPage;
    SGGroup    *_objGroup;

}
@property (nonatomic,strong)NSMutableArray *arrPosts;
- (void)setDetailMode:(kDetailMode)detailMode WithObject:(id)object;

@end
