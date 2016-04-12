//
//  BSProduct.h
//  MUPersistenceExample
//
//  Created by Muer on 16/4/12.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUPersistent.h"

@class BSImageItems, BSProductExtenInfo;

@interface BSProduct : MUPersistent

@property (nonatomic, strong) NSNumber *productId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) BSImageItems *images;
@property (nonatomic, strong) BSProductExtenInfo *extenInfo;

@end
