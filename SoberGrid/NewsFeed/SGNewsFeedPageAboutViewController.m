//
//  SGNewsFeedPageAboutViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/28/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SGNewsFeedPageAboutViewController.h"

#import "GroupedCell.h"
#import "UHLabel.h"
#import "WebViewController.h"
#import "ViewBanner.h"

@interface SGNewsFeedPageAboutViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView     *tblPageAbout;
    ViewBanner *bannerView;
}

@end

@implementation SGNewsFeedPageAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    self.title = _page.strPageTitle;
    [self createPageTable];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createPageTable{
    tblPageAbout = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tblPageAbout.dataSource = self;
    tblPageAbout.delegate   = self;
    tblPageAbout.backgroundColor = SG_BACKGROUD_COLOR;
    tblPageAbout.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [self.view addSubview:tblPageAbout];
    
    bannerView = [[ViewBanner alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 230) customizeWithBannerUrl:self.page.strPageBanner_Url withProfileImageUrl:nil withTitle:nil isLiked:NO LikeEnable:NO withDelegate:nil];

     tblPageAbout.tableHeaderView = bannerView;
}

#pragma mark - UITableview Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupedCell * cell = [tableView dequeueReusableCellWithIdentifier:@"gCell"];
    UHLabel *lbl;
    if (cell == nil) {
        cell = [[GroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gCell"];
        cell.backgroundColor = [UIColor clearColor];
        lbl =[[UHLabel alloc]initWithFrame:cell.viewContentHolder.bounds];
        lbl.textColor   = [UIColor blackColor];
        lbl.font        = SGBOLDFONT(14.0);
        lbl.backgroundColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.numberOfLines = 0;
        [cell.viewContentHolder addSubview:lbl];
        
    }
    
    if(indexPath.section == 0){
        lbl.text =@"Visit Website";
    }
    
    if(indexPath.section == 1){
        [cell setHight:([UHLabel getHeightOfText:_page.strPageDiscription forWidth:CGRectGetWidth(self.view.bounds)-20 withAttributes:@{NSFontAttributeName:SGBOLDFONT(14.0)}] + 20)];
        lbl.text = _page.strPageDiscription;
    }
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 16;
    }
    if (indexPath.section == 1) {
        int cellheight =[UHLabel getHeightOfText:_page.strPageDiscription forWidth:CGRectGetWidth(self.view.bounds)-20 withAttributes:@{NSFontAttributeName:SGBOLDFONT(14.0)}] + 20;
        return cellheight;
    }
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 25;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_page.strPage_Url.length > 0){
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.webViewType = kWebViewTypeGeneral;
        
        [self.navigationController pushViewController:webVC animated:YES];
        [webVC setUrl:[NSURL URLWithString:[_page.strPage_Url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    }
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
