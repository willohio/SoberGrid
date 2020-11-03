//
//  SGNavigationController.m
//  SoberGrid
//
//  Created by agilepc-159 on 11/21/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "SGNavigationController.h"

@interface SGNavigationController ()

@end

@implementation SGNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setAttributes];
    }
    return self;
}
- (void)setAttributes{
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: SGBOLDFONT(17),NSForegroundColorAttributeName : [UIColor blackColor]};
    self.navigationBar.tintColor = [UIColor blackColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
