//
//  CatGHUser.h
//  MUPersistenceExample
//
//  Created by Muer on 16/4/11.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatGHUser : NSObject

@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSNumber *userId;                 // userId -> id;
@property (nonatomic, strong) NSString *avatar_url;
@property (nonatomic, strong) NSString *gravatar_id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *html_url;
@property (nonatomic, strong) NSString *followers_url;
@property (nonatomic, strong) NSString *following_url;
@property (nonatomic, strong) NSString *gists_url;
@property (nonatomic, strong) NSString *starred_url;
@property (nonatomic, strong) NSString *subscriptions_url;
@property (nonatomic, strong) NSString *organizations_url;
@property (nonatomic, strong) NSString *repos_url;
@property (nonatomic, strong) NSString *events_url;
@property (nonatomic, strong) NSString *received_events_url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL site_admin;

@end
