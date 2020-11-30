//
//  WebViewViewController.h
//  SoberGrid
//
//  Created by Harsh Shah on 6/18/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController
{
    
    IBOutlet UIWebView *webViewForTerms;
    NSURL *fullURL;
}
-(void)loadURLToWebView:(NSURL*)strURL;

@end
