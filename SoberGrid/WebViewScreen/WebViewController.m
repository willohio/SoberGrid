//
//  WebViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/6/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView *webView;
}
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@end

@implementation WebViewController
-(void)configureTitle{
    switch (_webViewType) {
        case kWebViewTypeBigBook:
            self.title = NSLocalizedString(@"Big Book", nil);
            
            break;
        case kWebViewType12:
            self.title = NSLocalizedString(@"12 & 12", nil);
            
            break;
            
        case kWebViewTypeFAQ:
            [Localytics tagEvent:LLUserInFAQScreen];
            self.title = NSLocalizedString(@"FAQ", nil);
            break;
            
        case kWebViewTypeTypeContactUs:
            self.title = NSLocalizedString(@"Contact Us", nil);
            break;
            
        case kWebViewTypeGeneral:
            self.title = NSLocalizedString(@"SGBrowser", nil);
            break;
            
        default:
            break;
    }
}
- (NSURL*)urlToLaunch{
    NSString *strUrl;
    switch (_webViewType) {
        case kWebViewTypeBigBook:
            strUrl = @"http://www.aa.org/pages/en_US/alcoholics-anonymous";
            break;
            
        case kWebViewType12:
            strUrl = @"http://www.aa.org/pages/en_US/twelve-steps-and-twelve-traditions";
            break;
            
        case kWebViewTypeFAQ:
            strUrl = @"http://www.sobergridapp.com/#!faq/cleg";
            break;
            
        case kWebViewTypeTypeContactUs:
            strUrl = @"";
            break;
     
        default:
            break;
    }
    return [NSURL URLWithString:strUrl];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTitle];
    self.view.backgroundColor =[UIColor whiteColor];
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    

    if (_webViewType == kWebViewTypeGeneral) {
       [webView loadRequest:[NSURLRequest requestWithURL:urlToLaunch]];
    }else
        [webView loadRequest:[NSURLRequest requestWithURL:[self urlToLaunch]]];
    
    webView.delegate = self;
    webView.scalesPageToFit=true;
    [self.view addSubview:webView];
    
    
    [self createBackAndForthButtons];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated{
    
}
- (void)setUrl:(NSURL *)Url{
    urlToLaunch =   Url;
}
- (void)createBackAndForthButtons{
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:webView
                                                      action:@selector(goBack)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:webView
                                                         action:@selector(goForward)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.forwardButton,self.backButton];
}
- (UIImage *)forwardButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)backButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

#pragma mark - WEBVIEWDELEGATE
#pragma mark - Web view delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.scheme isEqualToString:@"file"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    else {
        return true;
    }}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
   
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self toggleState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishLoad];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoad];
}
- (void)toggleState
{
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;

   
}

- (void)finishLoad
{
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [webView stopLoading];
    webView = nil;
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
