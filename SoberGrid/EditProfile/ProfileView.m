//
//  ProfileView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/4/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
typedef enum{
    kProfileRowNameUserName             = 0,
    kProfileRowNameAbout                = 1,
    kProfileRowNameLocation             = 2,
    kProfileRowNameSelfSupportingBadge  = 4,
    kProfileRowNameGender               = 5,
    kProfileRowNameOrientation          = 6,
    kProfileRowNameRelationShipStaus    = 7,
    kProfileRowNameSeeking              = 8,
    kProfileRowNameAvailabeToGiveRide   = 9,
   // kProfileRowNameFellowShipType       = 10,
    kProfileRowNameLookingToMeetUp      = 10,
    kProfileRowNameSoberityDate         = 3
}kProfileRowName;

#import "ProfileView.h"
#import "SGRoundButton.h"
#import "NSDate+NVTimeAgo.h"
#import "NSDate+Utilities.h"
#import "UIImageView+WebCache.h"
#import "SGXMPP.h"
#import "NSDate+Utilities.h"
#import "NSObject+ConvertingViewPixels.h"
#import "SoberGridIAPHelper.h"

@implementation ProfileView
@synthesize viewBottomContents;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _ScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        [self addSubview:_ScrollView];
        viewProfileHolder = [[UIView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-[self deviceSpesificValue:90]-64)];
        viewProfileHolder.backgroundColor = [UIColor clearColor];
        [self addSubview:viewProfileHolder];
     
    }
    return self;
}
#pragma mark - PullableView
-(void)SetScrollView
{
    [self unloadScrollView];
    
    int width = 0;
    _ScrollView.pagingEnabled=TRUE;
    _ScrollView.contentSize = CGSizeMake(0, 0);
    
    [_ScrollView scrollRectToVisible:CGRectMake(0, 0, _ScrollView.frame.size.width, _ScrollView.frame.size.height) animated:YES];
    
    for(int i= 0; i<_pUser.arrPics.count; i++)
    {
        NSDictionary *dictImagePic=[_pUser.arrPics objectAtIndex:i];
        //add Imageview to Scrollview
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(width, 0, [UIScreen mainScreen].bounds.size.width, _ScrollView.bounds.size.height)];        //imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius=2.0f;
        [imageView.layer setMasksToBounds:YES];
        imageView.backgroundColor=[UIColor whiteColor];
        imageView.userInteractionEnabled=TRUE;
        imageView.tag = i;
        UIActivityIndicatorView *activityview = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [imageView addSubview:activityview];
        activityview.center = self.center;
        [activityview startAnimating];
        __block UIActivityIndicatorView *blockSafeActivity = activityview;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[dictImagePic objectForKey:@"pic_url"]] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [blockSafeActivity stopAnimating];
            [blockSafeActivity removeFromSuperview];
        }];
        //  [imageView setImageWithURL:[NSURL URLWithString:[dictImagePic objectForKey:@"pic_url"]] placeholer:nil showActivityIndicatorView:YES];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        width = width + [UIScreen mainScreen].bounds.size.width;
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [_ScrollView addSubview:imageView];
    }
    
    viewProfileHolder.userInteractionEnabled=true;
   
    
    if (_pUser.arrPics.count > 0) {
        UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ImageView_clicked:)];
        tap1.numberOfTapsRequired=1.0;
        tap1.numberOfTouchesRequired=1.0;
        [viewProfileHolder addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ImageView_clicked:)];
        tap2.numberOfTapsRequired=1.0;
        tap2.numberOfTouchesRequired=1.0;
        [_ScrollView addGestureRecognizer:tap2];
    }
    
    [_ScrollView setBackgroundColor:[UIColor whiteColor]];
    if(isIPad)
        _ScrollView.contentSize = CGSizeMake(width, 950);
    else if (isIPhone5)
        _ScrollView.contentSize = CGSizeMake(width, 500);
    else if (isIPhone4)
        _ScrollView.contentSize = CGSizeMake(width, 380);
    
    int index=(int)[_pUser.arrPics indexOfObject:[_pUser dictProfilePicFromArray:_pUser.arrPics]];
    [_ScrollView setContentOffset:CGPointMake(index*[UIScreen mainScreen].bounds.size.width, 0) animated:YES];
}
- (void)removeFullMode{
    if([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone){
        _spView.scrollEnabled = NO;
    }else
        _spView.scrollEnabled = YES;
    imageClicked=FALSE;
    viewProfileHolder.userInteractionEnabled=true;
    [self switchToContentMode:UIViewContentModeScaleAspectFill];
    pullUpView.alpha = 1.0;
    bottomView.alpha=1.0;
    pfVC.navigationController.navigationBar.alpha = 1.0;
}
- (void)unloadScrollView{
    for (UIView *v in _ScrollView.subviews) {
        [v removeFromSuperview];
    }
    NSArray *arrGestures = _ScrollView.gestureRecognizers;
    for (UIGestureRecognizer *gesture in arrGestures) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [_ScrollView removeGestureRecognizer:gesture];
        }
    }
    arrGestures =viewProfileHolder.gestureRecognizers;
    for (UIGestureRecognizer *gesture in arrGestures) {
        [viewProfileHolder removeGestureRecognizer:gesture];
    }
}

- (void)preparePullableView
{
    CGFloat xOffset = 0;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        xOffset = 224;
//    }
    
    if (pullUpView == nil) {
          pullUpView = [[StyledPullableView alloc] initWithFrame:CGRectMake(xOffset, 0, [UIScreen mainScreen].bounds.size.width,viewProfileHolder.frame.size.height)];
        [viewProfileHolder addSubview:pullUpView];

    }
  
    
    [self pullableView:pullUpView didChangeState:0];
    
    pullUpView.openedCenter = CGPointMake([UIScreen mainScreen].bounds.size.width/2 ,viewProfileHolder.frame.size.height/2);
    pullUpView.closedCenter = CGPointMake([UIScreen mainScreen].bounds.size.width/2 , viewProfileHolder.frame.size.height+viewProfileHolder.frame.size.height/4);
    
    if (pullUpimage == nil) {
        pullUpimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 4, 21, 9)];
        [pullUpView addSubview:pullUpimage];

    }
    
    pullUpimage.image=[UIImage imageNamed:@"Up_Arrow.png"];
    
    pullUpView.center = pullUpView.closedCenter;
    pullUpView.handleView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
    pullUpimage.center = pullUpView.handleView.center;
    
    pullUpView.delegate = self;
    
    
    // Add Tableview to PullView
    
    if (tblView == nil) {
         tblView=[[UITableView alloc]initWithFrame:CGRectMake(0, [self deviceSpesificValue:32], pullUpView.frame.size.width, pullUpView.frame.size.height-[self deviceSpesificValue:32])];
        tblView.separatorStyle=UITableViewCellSeparatorStyleNone;
        tblView.scrollEnabled = false;
        
        
        tblView.delegate=self;
        tblView.dataSource=self;
        tblView.backgroundColor=[UIColor clearColor];
        [pullUpView addSubview:tblView];
    }
   
   
    pullUpView.userInteractionEnabled=true;
    
    if (_pUser.arrPics.count == 0 || !_pUser.arrPics ) {
        [pullUpView setOpened:YES animated:false];
    }
    [tblView reloadData];
    // Call BottomView Method
    [self BottomView];
}
#pragma mark - Bottom View

-(void)BottomView
{
    
    if (bottomView == nil) {
        bottomView=[[BlurView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-[self deviceSpesificValue:90], self.frame.size.width, [self deviceSpesificValue:90])];
         [self addSubview:bottomView];
        if(![[User currentUser].struserId isEqualToString:_pUser.struserId])
        {
        
            SGRoundButton *btnBlock,*btnFavourite,*btnChat;
            
            btnBlock=[[SGRoundButton alloc] initWithFrame:CGRectMake(20, 35, [self deviceSpesificValue:75], [self deviceSpesificValue:35])];
            __weak SGRoundButton *btnTempBlock=btnBlock;
            btnTempBlock.center = CGPointMake(20 +btnBlock.frame.size.width/2 , btnBlock.center.y);
            
            
            btnFavourite=[[SGRoundButton alloc] initWithFrame:CGRectMake(btnBlock.frame.size.width+btnBlock.frame.origin.x + 20, 35,[self deviceSpesificValue:98] , [self deviceSpesificValue:35])];
            __weak SGRoundButton *btnTempFavourite=btnFavourite;
            
            btnTempFavourite.center = CGPointMake(bottomView.center.x, btnFavourite.center.y);
            btnChat=[[SGRoundButton alloc] initWithFrame:CGRectMake(btnFavourite.frame.size.width+btnFavourite.frame.origin.x + 20, 35, [self deviceSpesificValue:70], [self deviceSpesificValue:35])];
            __weak SGRoundButton *btnTempChat=btnChat;
            
            btnTempChat.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
            btnTempChat.center = CGPointMake([UIScreen mainScreen].bounds.size.width - (20+btnChat.frame.size.width/2), btnChat.center.y);
            
            
            [btnTempBlock setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Block_Button")] forState:UIControlStateNormal];
            [btnTempBlock setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Block_Button_selected")] forState:UIControlStateSelected];
            [btnTempBlock setTitle:NSLocalizedString(@"Block", nil) forState:UIControlStateNormal];
            [btnTempBlock setTitle:NSLocalizedString(@"Blocked", nil) forState:UIControlStateSelected];
            [btnTempBlock setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btnTempBlock setSelectedStateBorderColor:[UIColor redColor]];
            
            [btnTempBlock addTarget:self action:@selector(btnBlock_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            btnTempBlock.selected = _pUser.isBlocked;
            [bottomView addSubview:btnBlock];
            
            
            [btnTempFavourite setLeftImage:[UIImage imageNamed:(isIPad)?@"Favourite_Button~iPad":@"Favourite_Button"] forState:UIControlStateNormal];
            [btnTempFavourite setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Favourite_button_selected")] forState:UIControlStateSelected];
            
            [btnTempFavourite setTitle:NSLocalizedString(@"Favorite", nil) forState:UIControlStateNormal];
            [btnTempFavourite setTitle:NSLocalizedString(@"Favorited", nil) forState:UIControlStateSelected];
            [btnTempFavourite setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btnTempFavourite setSelectedStateBorderColor:[UIColor redColor]];
            
            
            btnTempFavourite.selected = _pUser.isFav;
            [btnTempFavourite addTarget:self action:@selector(btnFavourite_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:btnTempFavourite];
            
            
            [btnTempChat setLeftImage:[UIImage imageNamed:(isIPad)?@"Chat_Button~iPad.png":@"Chat_Button"] forState:UIControlStateNormal];
            [btnTempChat setTitle:NSLocalizedString(@"Chat", nil) forState:UIControlStateNormal];
            [btnTempChat addTarget:self action:@selector(btnChat_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:btnChat];
        }
        else
        {
            if (viewBottomContents == nil) {
                viewBottomContents=[[ViewImageIncemental alloc]initWithFrame:bottomView.bounds];
                viewBottomContents.delegate=self;
                [bottomView addSubview:viewBottomContents];
                
            }
            [viewBottomContents customizewithProfileImages:_pUser.arrPics];
            
            
//            UITapGestureRecognizer *tapround=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnImageUpload_Clicked:)];
//            tapround.numberOfTapsRequired = 1.0;
//            tapround.numberOfTouchesRequired = 1.0;
//            [rounbView1 addGestureRecognizer:tapround];
        }

    }
    
    // UIImageView *lineImage= [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, self.view.frame.size.width-10, 1)];
    
    
    // lineImage.backgroundColor=[UIColor whiteColor];
    // [bottomView addSubview:lineImage];
   
    
    // Check if it is Rootview
   }

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened{
    if(opened){
        pullUpimage.transform=CGAffineTransformMakeRotation(M_PI);
        for (UIGestureRecognizer *recognizer in viewProfileHolder.gestureRecognizers) {
            [viewProfileHolder removeGestureRecognizer:recognizer];
        }
        tblView.scrollEnabled = true;
    }
    else{
        pullUpimage.transform=CGAffineTransformMakeRotation(0);
        if (_pUser.arrPics.count > 0) {
        UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ImageView_clicked:)];
        tap1.numberOfTapsRequired=1.0;
        tap1.numberOfTouchesRequired=1.0;
        [viewProfileHolder addGestureRecognizer:tap1];
        tblView.scrollEnabled = false;
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==kProfileRowNameUserName) {
        // For Switches
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SwithCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwithCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        NSString *strUserName;
        if (_pUser.birthDate) {
            strUserName = [NSString stringWithFormat:@"%@ (%ld)",_pUser.strName,(long)[_pUser.birthDate getAge]];
        }else{
            strUserName = _pUser.strName;
        }
        cell.textLabel.text=strUserName;
        cell.textLabel.font = SGBOLDFONT(17.0);
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    if (indexPath.row == kProfileRowNameAbout) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AboutCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        
        cell.textLabel.attributedText=[self aboutString];
        cell.textLabel.frame=CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 280, cell.textLabel.frame.size.height);
        cell.textLabel.numberOfLines = 0;
        return cell;
        
    }
    
    
    PROExapandableCell *exCell=[tableView dequeueReusableCellWithIdentifier:@"ProExpandableCell"];
    if (exCell == nil) {
        exCell = [[PROExapandableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProExpandableCell"];
    }
    if (indexPath.row == kProfileRowNameLocation) {
        [exCell customizeWithwithTitle:(_pUser.strCity.length > 0)?_pUser.strCity:NSLocalizedString(@"Location", nil) andSubtitle:nil withSubImage:[UIImage imageNamed:@"Location_Icon.png"]];
        
        
    }
    if (indexPath.row == kProfileRowNameSelfSupportingBadge) {
        [exCell customizeWithwithTitle:@"Self supporting badge" andSubtitle:nil withSubImage:[UIImage imageNamed:imageNameRefToDevice(@"White_Badge_Icon")]];
        
        
    }
    if (indexPath.row == kProfileRowNameGender) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Gender", nil) andSubtitle:(_pUser.strGender)?NSLocalizedString(_pUser.strGender, nil):NSLocalizedString(@"No Answer", nil) withSubImage:nil];
    }
    if (indexPath.row == kProfileRowNameOrientation) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Orientation", nil) andSubtitle:(_pUser.strOrientation)?NSLocalizedString(_pUser.strOrientation, nil):NSLocalizedString(@"No Answer", nil) withSubImage:nil];
        
    }
    if (indexPath.row == kProfileRowNameRelationShipStaus) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Relationship status", nil) andSubtitle:(_pUser.strRelStatus)?NSLocalizedString(_pUser.strRelStatus, nil):NSLocalizedString(@"No Answer", nil) withSubImage:nil];
        
        
    }
    if (indexPath.row == kProfileRowNameSeeking) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Seeking", nil) andSubtitle:(_pUser.arrSeekingType)?[_pUser.arrSeekingType componentsJoinedByString:@","]:NSLocalizedString(@"No Answer", nil) withSubImage:nil];
        
        
    }
    if (indexPath.row == kProfileRowNameAvailabeToGiveRide) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Available to give a ride", nil) andSubtitle:(_pUser.strisAvailbeToGiveRide)?NSLocalizedString(_pUser.strisAvailbeToGiveRide, nil):NSLocalizedString(@"No Answer", nil) withSubImage:nil];
        
    }
    // client dont need it any more
//    if (indexPath.row == kProfileRowNameFellowShipType) {
//        [exCell customizeWithwithTitle:NSLocalizedString(@"Fellowship type", nil) andSubtitle:(_pUser.arrfellowShipType)?[_pUser.arrfellowShipType componentsJoinedByString:@","]:NSLocalizedString(@"No Answer", nil) withSubImage:nil];
//        
//    }
    if (indexPath.row == kProfileRowNameLookingToMeetUp) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Looking to meet up", nil) andSubtitle:(_pUser.strLookingToMeetUP)?NSLocalizedString(_pUser.strLookingToMeetUP, nil):NSLocalizedString(@"No Answer", nil)withSubImage:nil];
        
    }
    if (indexPath.row == kProfileRowNameSoberityDate) {
        [exCell customizeWithwithTitle:NSLocalizedString(@"Sobriety Date", nil) andSubtitle:(_pUser.dateSoberity)?([_pUser.dateSoberity formattedStringwithFormat:@"MMM d yyyy"]):NSLocalizedString(@"No Answer", nil) withSubImage:nil];
    }
    
    
    return exCell;
    
    
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PROExapandableCell class]]) {
        PROExapandableCell *exCell=(PROExapandableCell*)cell;
        [exCell unload];
    }else{
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kProfileRowNameAbout) {
        CGRect textRect=[[self aboutString] boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return textRect.size.height + 5;
    }
    if (indexPath.row == kProfileRowNameSelfSupportingBadge) {
        if (_pUser.isBadgePurchased) {
            return [self deviceSpesificValue:40];

        }else
            return 0;
    }
    if (indexPath.row == kProfileRowNameSoberityDate) {
        if (_pUser.showSoberDate) {
            return [self deviceSpesificValue:40];
        }else
            return 0;
    }
    if(indexPath.row  == kProfileRowNameSeeking){
        return [PROExapandableCell heightForTitle:NSLocalizedString(@"Seeking", nil) andSubtitle:[_pUser.arrSeekingType componentsJoinedByString:@","]];
    }
        return [self deviceSpesificValue:40];
}
- (NSMutableAttributedString*)aboutString{
    NSMutableAttributedString *arrTotalStr=[[NSMutableAttributedString alloc]init];
    NSAttributedString *attrStr1=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n",NSLocalizedString(@"About Me", nil)] attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : SGREGULARFONT(17.0)}];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc]initWithString:_pUser.strAboutMe attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : SGBOLDFONT(17.0)}];
    [arrTotalStr appendAttributedString:attrStr1];
    [arrTotalStr appendAttributedString:attrStr2];
    return arrTotalStr;
}
-(void)setUser:(User *)user{
    _pUser = user;
    if ([_pUser.struserId isEqualToString:[User currentUser].struserId]) {
        _pUser = [User currentUser];
        UIBarButtonItem *button=[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:pfVC action:@selector(pushToEdit)];
        pfVC.navigationItem.rightBarButtonItem=button;
    }
    [self SetScrollView];
    [self preparePullableView];

    if (![User currentUser].isStealthModeEnable && ![_pUser.struserId isEqualToString:[User currentUser].struserId]) {
        [self callVisitorApi];

    }
}
- (void)setController:(ProfileVC *)controller{
    pfVC = controller;
}
- (void)callVisitorApi{
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"Add_Visitor") andDelegate:self];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [inputFormatter stringFromDate:[NSDate date]];

    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"visitor_id":_pUser.struserId,@"date":strDate} options:NSJSONWritingPrettyPrinted error:nil]];
}
#pragma mark - Image Clicked - Whole Image view

- (IBAction)ImageView_clicked:(UIButton *)sender
{
    if(imageClicked==FALSE)
    {
        _spView.scrollEnabled = NO;
        imageClicked=TRUE;
        viewProfileHolder.userInteractionEnabled=false;
        [self switchToContentMode:UIViewContentModeScaleAspectFit];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            pullUpView.alpha = 0.0;
            bottomView.alpha=0.0;
            pfVC.navigationController.navigationBar.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        if([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone){
            _spView.scrollEnabled = NO;
        }else
            _spView.scrollEnabled = YES;
        imageClicked=FALSE;
        viewProfileHolder.userInteractionEnabled=true;
        [self switchToContentMode:UIViewContentModeScaleAspectFill];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            pullUpView.alpha = 1.0;
            bottomView.alpha=1.0;
            pfVC.navigationController.navigationBar.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)switchToContentMode:(UIViewContentMode)contentMode{
    for (UIView *viewtemp in _ScrollView.subviews) {
        if ([viewtemp isKindOfClass:[UIImageView class]]) {
            UIImageView *imgTemp  = (UIImageView*)viewtemp;
            imgTemp.contentMode = contentMode;
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    MEAlertView *cuAlert=(MEAlertView *)alertView;
    
    if (buttonIndex == 1) {
        UIButton *btnTemp = cuAlert.controller;
        btnTemp.selected = !btnTemp.selected;
        _pUser.isBlocked = btnTemp.selected;
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"block") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"type":@"add",@"userid":[User currentUser].struserId,@"sobergrid_user":_pUser.struserId} options:NSJSONWritingPrettyPrinted error:nil]];
        [[SGXMPP sharedInstance] blockUser:_pUser];
        
    }
}

-(void)btnFavourite_Clicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _pUser.isFav = sender.selected;
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"favorite") andDelegate:self];
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"type":(sender.selected)?@"add":@"remove",@"userid":[User currentUser].struserId,@"sobergrid_user":_pUser.struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
-(void)btnBlock_Clicked:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }else{
        MEAlertView *alert = [[MEAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Do you want to block", nil),_pUser.strName] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alert.tag = sender.tag;
        alert.controller = sender;
        [alert show];
    }
    
    
    
}

-(void)btnChat_Clicked:(UIButton *)sender
{
   // [self enterMessage];
    [_delegate chatClickedForUser:_pUser];
    //  [self performSegueWithIdentifier:@"profileToChatpush" sender:nil];
    
}
- (void)imageClickedAtView:(UIView *)view{
    [_delegate btnImageUploadClickedForUser:_pUser];
}
- (void)reloadTable{
    [tblView reloadData];
}
- (void)setSwipeView:(SwipeView *)swipView{
    _spView = swipView;
}

#pragma mark - Comman Api delegate
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:@"Add_Visitor"].location != NSNotFound) {
        
    }
    
    if ([requestedURL rangeOfString:@"block"].location != NSNotFound) {
        if ([[dictResponse objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
            
        }
        
    }
    if ([requestedURL  rangeOfString:@"favorite"].location != NSNotFound) {
        if ([[dictResponse objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
            if (_pUser.isFav) {
                NSString *strFirstmessage =NSLocalizedString(@"You added", nil);
                NSString *strSecondMessage = NSLocalizedString(@"to your Favorites", nil);
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ %@ %@",strFirstmessage,_pUser.strName,strSecondMessage] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
                [alert show];
            }
           
        }
    }
}

- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)unload{
    pullUpView.delegate = nil;
    pullUpView = nil;
    viewProfileHolder = nil;
    pullUpimage = nil;
    bottomView = nil;
    rounbView1 = nil;
    tblView = nil;
    _ScrollView = nil;
    bottomButtonsView = nil;
    
}
- (void)dealloc{
//    StyledPullableView *pullUpView;
//    UIView *viewProfileHolder;
//    UIImageView *pullUpimage;
//    BOOL imageClicked;
//    BlurView *bottomView;
//    AGMedallionView *rounbView1;
//    UITableView *tblView;
//    IBOutlet UIScrollView *ScrollView;
//    UIImage *imgChosenImage;
//    User  *_pUser;
//    BOOL isCurrentUserProfile;
//    UIView *bottomButtonsView;
//    ProfileVC *pfVC;
//    SwipeView *_spView;

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
