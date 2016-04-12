//
//  MUPersistent.h
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 持久化对象基类实现了类的属性与字典的相互转换 */
@interface MUPersistent : NSObject<NSCopying, NSCoding>

/** 通过字典创建对象 */
+ (instancetype)objectWithDictionary:(NSDictionary *)dict;
/** 通过字典初始化对象 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/** 通过字典设置对象的属性值,类似setValuesForKeysWithDictionary并拟补了该方法在属性缺失时异常问题 */
- (void)setValuesForDictionary:(NSDictionary *)aDictionary;

/** 将对象转换成字典 不映射 */
- (NSMutableDictionary *)toDictionary;
/** 将对象转换成字典 是否映射转换 */
- (NSMutableDictionary *)toDictionaryUsingMapping:(BOOL)mapping;

/** 将对象转换成JSON 不映射 */
- (NSString *)toJSONString;
/** 将对象转换成JSON 是否映射转换 */
- (NSString *)toJSONStringUsingMapping:(BOOL)mapping;

/** 键值映射 @{@"propertyName": @"dictionaryKeyName"}, 映射名与属性名同时存在时优先取映射值 */
+ (NSDictionary *)keyMapping;
/** 按属性名映射 优先级低于keyMapping */
+ (NSString *)keyMappingForPropertyName:(NSString *)propertyName;

/** 逐一遍历映射属性值 例如将对象所有属性清空: 
    [obj propertyValueMap:^id(NSString *name, id value) {
        return nil;
    }];
 */
- (void)propertyValueMap:(id (^)(NSString *name, id value))block;

/** 忽略的属性 */
+ (NSArray *)ignoredProperties;
/** 忽略assign weak属性 */
+ (BOOL)shouldIgnoreValueTypeProperties;


/** 加载数据 path为nil时文件名默认为"类名.plist" 根目录为NSCachesDirectory */
- (void)loadFromFile:(NSString *)path;
/** 保存数据 path为nil时文件名默认为"类名.plist" 根目录为NSCachesDirectory */
- (void)saveToFile:(NSString *)path;

@end
