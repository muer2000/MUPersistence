//
//  BSImageItem.m
//  MUPersistenceExample
//
//  Created by Muer on 16/4/12.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "BSImageItem.h"

@implementation BSImageItem

+ (NSDictionary *)keyMapping
{
    return @{@"picURL": @"pic_url",
             @"imageWidth": @"width",
             @"imageHeight": @"height"};
}

@end
