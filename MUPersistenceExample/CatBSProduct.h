//
//  CatBSProduct.h
//  MUPersistenceExample
//
//  Created by Muer on 16/4/12.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatBSProductExtenInfo;

@interface CatBSProduct : NSObject

// implementation mup_persistentClassForKeyInArray

@property (nonatomic, strong) NSNumber *productId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) CatBSProductExtenInfo *extenInfo;

@end
