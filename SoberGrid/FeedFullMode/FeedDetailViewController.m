//
//  FeedDetailViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 7/15/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import "FeedDetailViewController.h"
#import "SGNewsFeedPhotoCell.h"
#import "SGNewsFeedStatusCell.h"
#import "SGNewsFeedVideoCell.h"
#import "SGNewsFeedViewController.h"
#import "MHFacebookImageViewer.h"
#import "XHDisplayMediaViewController.h"
#import "SGNewsFeedPageDetailViewController.h"
#import "ProfileVC.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
@interface FeedDetailViewController () <SGNewsFeedVideoCellDelegate,SGNewsFeedCellDelegate,UITableViewDataSource,UITableViewDelegate>
{
}

@end

@implementation FeedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    [self createNewsFeedTable];
}
- (void)createNewsFeedTable{
    UITableView* tblComments = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblComments.dataSource = self;
    tblComments.delegate   = self;
    tblComments.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tblComments];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_post isKindOfClass:[SGPostVideo class]]) {
        // Show fullvierson of photo
        SGPostVideo *sVideo=(SGPostVideo*)_post;
        SGNewsFeedVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:kVideoCellIdentifier];
        if (videoCell == nil) {
            videoCell = [[SGNewsFeedVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVideoCellIdentifier withLine:false];
            videoCell.delegate = self;
            videoCell.videodelegate = self;
            
        }
            [videoCell hideLikeOption];
            [videoCell hideCommentOption];
        
        // videoCell.delegate = self;
        [videoCell customizeWithPost:sVideo withFullVersion:true forType:@"post"];
        
        return videoCell;
        
    }else{
        // Show fullvierson of photo
        
        SGNewsFeedPhotoCell *photocell =[tableView dequeueReusableCellWithIdentifier:kPhotosCellIdentifier];
        if (photocell == nil) {
            photocell = [[SGNewsFeedPhotoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPhotosCellIdentifier withLine:false];
            photocell.delegate = self;
            
        }
            [photocell hideLikeOption];
            [photocell hideCommentOption];
        
        [photocell customizeWithPost:_post withFullVersion:true forType:@"post"];
        if ([_post isKindOfClass:[SGPostPhoto class]]) {
            
            SGPostPhoto *sPhoto=(SGPostPhoto*)_post;
            
            [photocell.imgViewPost setupImageViewerWithImageURL:[NSURL URLWithString:sPhoto.strImageUrl] onOpen:^{
            } onClose:^{
            }];
        }
        return photocell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_post isKindOfClass:[SGPostVideo class]]) {
        // Show fullvierson of photo
        SGPostVideo *sVideo=(SGPostVideo*)_post;
        return [SGNewsFeedVideoCell getheightWithLikeAndCommentForPost:sVideo withFullVersion:YES  withLine:NO];
    }else{
        return [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentAccordintToPost:_post withFullVersion:YES withLine:NO];
    }
}

#pragma mark - VideoCell delegate
- (void)sgNewsFeedVideoCellClickeVideoforUrl:(NSString *)videoUrl{
    XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
    messageDisplayTextView.videoUrl = [NSURL URLWithString:videoUrl];
    [self.navigationController pushViewController:messageDisplayTextView animated:YES];
}



- (void)updatedPost:(id)post ForCell:(UITableViewCell *)cell{
    _post = post;
}


- (void)setPost:(SGPost *)objPost{
    _post=objPost;
}


- (void)dealloc{
    //tblComments = nil;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

