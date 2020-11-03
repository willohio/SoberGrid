//
//  MessagesViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/30/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonApiCall.h"
@interface MessagesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CommonApiCallDelegate>{
    UITableView *tblView;
}
@property (nonatomic,strong)NSMutableArray *arrLastSentOrReceivedMessages;

@end
