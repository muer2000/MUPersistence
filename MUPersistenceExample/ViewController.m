//
//  ViewController.m
//  MUPersistenceExample
//
//  Created by Muer on 16/4/11.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "ViewController.h"
#import "BSProduct.h"
#import "CatBSProduct.h"
#import "GHRepositories.h"
#import "NSObject+MUPersistence.h"
#import "CatGHRepository.h"

static NSString * const kGetGithubRepositoriesURL = @"https://api.github.com/repositories";

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *productInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MUPersistence";
}


#pragma mark - Product

- (NSDictionary *)productInfo
{
    if (!_productInfo) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"product" ofType:@"json"];
        NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _productInfo = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:kNilOptions
                                                         error:nil];
    }
    return _productInfo;
}

- (void)transformByCategory
{
    NSLog(@"*** product transform by category ***");
    NSLog(@"source product info:%@", self.productInfo);
    CatBSProduct *product = [CatBSProduct mup_objectWithDictionary:self.productInfo];
    NSLog(@"new product info:%@", [product mup_toDictionary]);
}

- (void)transformByInheritance
{
    NSLog(@"*** product transform by inheritance ***");
    NSLog(@"source product info:%@", self.productInfo);
    BSProduct *product = [BSProduct objectWithDictionary:self.productInfo];
    NSLog(@"new product info:%@", [product toDictionary]);
}


#pragma mark - GitHub

- (void)requestRepositoriesWithCompletionHandler:(void (^)(id responseObject, NSError *error))handler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kGetGithubRepositoriesURL]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        id jsonObject = nil;
        if (!connectionError) {
            jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
        if (handler) {
            handler(jsonObject, connectionError);
        }
    }];
}

- (void)requestRepositoriesByCategory
{
    NSLog(@"*** GitHub repositories by category ***");
    [self requestRepositoriesWithCompletionHandler:^(id responseObject, NSError *error) {
        if (responseObject) {
            NSArray *repositories = [NSObject mup_objectsWithDictionaries:responseObject modelClass:[CatGHRepository class]];
            NSLog(@"by category count: %zd", repositories.count);
            if (repositories.count > 0) {
                NSLog(@"by category first object: %@", [repositories.lastObject mup_toDictionary]);
            }
        }
    }];
}

- (void)requestRepositoriesByInheritance
{
    NSLog(@"*** GitHub repositories by inheritance ***");
    [self requestRepositoriesWithCompletionHandler:^(id responseObject, NSError *error) {
        if (responseObject) {
            GHRepositories *repositories = [GHRepositories listWithArrayOfDictionaries:responseObject];
            NSLog(@"by inheritance count: %zd", repositories.count);
            if (repositories.count > 0) {
                NSLog(@"by inheritance first object: %@", repositories.lastObject);
            }
        }
    }];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self transformByCategory];
        }
        else {
            [self transformByInheritance];
        }
    }
    else {
        if (indexPath.row == 0) {
            [self requestRepositoriesByCategory];
        }
        else {
            [self requestRepositoriesByInheritance];
        }
    }
}

@end
