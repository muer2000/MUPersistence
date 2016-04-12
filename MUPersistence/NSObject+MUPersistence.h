//
//  NSObject+MUPersistence.h
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MUPersistence)

/** 通过字典创建对象 */
+ (instancetype)mup_objectWithDictionary:(NSDictionary *)dict;
/** 通过字典创建对象 */
- (instancetype)mup_initWithDictionary:(NSDictionary *)dict;

/** 通过字典设置对象的属性值,类似setValuesForKeysWithDictionary并拟补了该方法在属性缺失时异常问题 */
- (void)mup_setValuesForDictionary:(NSDictionary *)aDictionary;

/** 将对象转换成JSON */
- (NSString *)mup_toJSONString;
/** 将对象转换成字典 */
- (NSDictionary *)mup_toDictionary;

/** 忽略的属性 */
+ (NSArray *)mup_ignoredProperties;
/** 忽略assign weak属性 */
+ (BOOL)mup_shouldIgnoreValueTypeProperties;

/** 数组中的对象类型 key为属性名 value为Class或Class name */
+ (NSDictionary *)mup_persistentClassForKeyInArray;

/** 键值映射 例: return @{@"propertyName": @"dictionaryKeyName"}, 映射名与属性名同时存在时优先取映射值 */
+ (NSDictionary *)mup_keyMapping;
/** 按属性名映射 优先级低于mup_keyMapping */
+ (NSString *)mup_keyMappingForPropertyName:(NSString *)propertyName;

/** 逐一遍历映射属性值 例如将对象所有属性清空:
 [obj mup_propertyValueMap:^id(NSString *name, id value) {
 return nil;
 }];
 */
- (void)mup_propertyValueMap:(id (^)(NSString *name, id value))block;

/** JSON字典列表转换为对象列表 */
+ (NSArray *)mup_objectsWithDictionaries:(NSArray *)dictionaries modelClass:(Class)modelClass;

@end
