//
//  SoberGridIAPHelper.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/27/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "IAPHelper.h"
#import "CommonApiCall.h"

@interface SoberGridIAPHelper : IAPHelper <UIAlertViewDelegate>{
}

+ (SoberGridIAPHelper *)sharedInstance;
@property (nonatomic,strong)NSArray *products;
- (void)showAlertForActivatePack;
- (void)fetchProducts;
- (void)buyBadge;
- (void)buy1MonthPack;
- (void)buy3MonthPack;
- (void)buy12MonthPack;


@end
