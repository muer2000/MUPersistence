//
//  GHRepositories.m
//  MUPersistenceExample
//
//  Created by Muer on 16/4/11.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "GHRepositories.h"
#import "GHRepository.h"

@implementation GHRepositories

+ (Class)transformedModelClass
{
    return [GHRepository class];
}

@end
