//
//  CatBSProduct.m
//  MUPersistenceExample
//
//  Created by Muer on 16/4/12.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "CatBSProduct.h"
#import "NSObject+MUPersistence.h"
#import "CatBSImageItem.h"

@implementation CatBSProduct

+ (NSDictionary *)mup_persistentClassForKeyInArray
{
    return @{@"images": [CatBSImageItem class]};
}

@end
