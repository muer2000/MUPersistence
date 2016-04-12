//
//  GHRepository.m
//  MUPersistenceExample
//
//  Created by Muer on 16/4/11.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "GHRepository.h"

@implementation GHRepository

+ (NSDictionary *)keyMapping
{
    return @{@"repositoryId": @"id",
             @"isPrivate": @"private",
             @"reposDescription": @"description"};
}

@end
