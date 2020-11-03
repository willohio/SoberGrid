//
//  FacebookPhotosViewController.m
//  PleaseIdentify
//
//  Created by Haresh Kalyani on 7/21/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import "PhotosViewController.h"
#import "PICollectionViewHelper.h"
#import "PICollcetionViewCell.h"
#import "User.h"
@interface PhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
}
@property (nonatomic,strong)PICollectionViewHelper *pcvh;

@end

@implementation PhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _arrFBPhotos = [[NSMutableArray alloc]init];
    [self.view addSubview:[self topView]];
    [self drawCollectionView];
    [self getImages];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
   // _pcvh.delegate = nil;
   // _pcvh = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)drawCollectionView{
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    //[aFlowLayout setItemSize:CGSizeMake(158, 159)];
    //[aFlowLayout setMinimumInteritemSpacing:0];
    
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    eventCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40,(isIPad) ? 600: CGRectGetWidth(self.view.bounds)-30, [UIScreen mainScreen].bounds.size.height -40 - ((isIPad) ? 30 : 50)) collectionViewLayout:aFlowLayout];
    eventCollectionView.backgroundColor=[UIColor whiteColor];
    eventCollectionView.delegate=self;
    eventCollectionView.dataSource=self;
    [eventCollectionView registerClass:[PICollcetionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [self.view addSubview:eventCollectionView];
}
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _arrFBPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    PICollcetionViewCell * eventCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strTempDirectoryPath = [paths objectAtIndex:0];
    NSString *strFilepath =[strTempDirectoryPath stringByAppendingPathComponent:[_arrFBPhotos objectAtIndex:indexPath.row]];
    NSURL *fileUrl =[NSURL fileURLWithPath:strFilepath];
    [eventCell customizewithMediaURL:fileUrl];
    eventCell.tag = collectionView.tag;
    return eventCell;
    
    
    
    
    
}

#pragma mark -
#pragma mark UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrFBPhotos.count > 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *strTempDirectoryPath = [paths objectAtIndex:0];
        NSString *strFilepath =[strTempDirectoryPath stringByAppendingPathComponent:[_arrFBPhotos objectAtIndex:indexPath.row]];
        NSURL *fileUrl =[NSURL fileURLWithPath:strFilepath];
        
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        UIImage *img = [UIImage imageWithData:data];
        
        [self didSelectitem:img];
        data = nil;
        img = nil;
        fileUrl = nil;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrFBPhotos.count == 0) {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }else{
            return CGSizeMake(140, 140);
      
        
    }
    
    return CGSizeMake(0, 0);
    
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 1 , 0, 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
- (IBAction)btnCancel_Clicked:(UIButton *)sender {
}
- (void)didSelectitem:(id)item{
    [_delegate photosViewControllerdidFinishPickingPhoto:item];
    [self closeView:nil];
}

- (IBAction)closeView:(id)sender {

    [self.depthViewReference dismissPresentedViewInView:self.presentedInView animated:YES];
}
- (void)getImages{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strTempDirectoryPath = [paths objectAtIndex:0];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strTempDirectoryPath error:nil];
    NSPredicate *fltr;
    if (_isMyPhotoes) {
       fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH[cd] %@",[NSString stringWithFormat:@"sent_%@.png",[User currentUser].struserId]];
    }else{
        fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH[cd] %@",[NSString stringWithFormat:@"rec_%@.png",[User currentUser].struserId]];
    }
    NSArray *onlyJPGs = [dirContents filteredArrayUsingPredicate:fltr];
    _arrFBPhotos=[onlyJPGs mutableCopy];
    _pcvh.arrPhotos = _arrFBPhotos;
    [eventCollectionView reloadData];
}
- (UIView*)topView{
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0,(isIPad) ? 600: CGRectGetWidth(self.view.bounds)-30, 40)];
    viewHeader.backgroundColor = [UIColor whiteColor];
    // Create header lable
    UILabel *lblHeader = [[UILabel alloc]initWithFrame:viewHeader.bounds];
    lblHeader.userInteractionEnabled = false;
    lblHeader.font = [UIFont boldSystemFontOfSize:17.0];
    lblHeader.textColor = [UIColor redColor];
    lblHeader.text = (_isMyPhotoes) ? @"My Photos":@"Their Photos";
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblHeader];
    lblHeader = nil;
    
    // Create cancel button
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(viewHeader.bounds) - 55, 0, 50, 40)];
    [btnCancel setTitle:@"Close" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnCancel];
    btnCancel = nil;
    
    
//    UIButton *btnEdit = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 50, 40)];
//    [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
//    [btnEdit setTitle:@"Done" forState:UIControlStateSelected];
//    btnEdit.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
//    [btnEdit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [btnEdit addTarget:self action:@selector(edit_clicked:) forControlEvents:UIControlEventTouchUpInside];
//    btnEdit.selected = tblView.editing;
//    [viewHeader addSubview:btnEdit];
//    btnEdit = nil;
    return viewHeader;
}
- (void)dealloc{
    NSLog(@"Dealloc from photoes viewcontroller");
    _arrFBPhotos = nil;
    eventCollectionView = nil;
    
}

@end
