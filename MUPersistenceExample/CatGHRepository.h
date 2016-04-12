//
//  CatGHRepository.h
//  MUPersistenceExample
//
//  Created by Muer on 16/4/11.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatGHUser;

@interface CatGHRepository : NSObject

@property (nonatomic, strong) CatGHUser *owner;
@property (nonatomic, strong) NSNumber *repositoryId;       // repositoryId -> *id
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *full_name;
@property (nonatomic, assign) BOOL isPrivate;               // isPrivate -> private
@property (nonatomic, strong) NSString *html_url;
@property (nonatomic, strong) NSString *reposDescription;   // reposDescription -> description;
@property (nonatomic, assign) BOOL fork;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *forks_url;
@property (nonatomic, strong) NSString *keys_url;
@property (nonatomic, strong) NSString *collaborators_url;
@property (nonatomic, strong) NSString *teams_url;
@property (nonatomic, strong) NSString *hooks_url;
@property (nonatomic, strong) NSString *issue_events_url;
@property (nonatomic, strong) NSString *events_url;
@property (nonatomic, strong) NSString *assignees_url;
@property (nonatomic, strong) NSString *branches_url;
@property (nonatomic, strong) NSString *tags_url;

@end
