//
//  MUPersistentList.h
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUPersistent;

/**  
 @brief
    持久化对象数组列表基类,实现了对数组的封装和json与对象数组的转换
 */
@interface MUPersistentList : NSObject <NSCopying, NSCoding, NSFastEnumeration>

/** 指定数组中的对象的类型,由子类实现 */
+ (Class)transformedModelClass;

/**
 *  创建对象通过对象字典
 *  @param dictionaries 字典数组
 *  @return 返回对象
 */
+ (instancetype)listWithArrayOfDictionaries:(NSArray *)dictionaries;

/**
 *  创建对象通过对象字典
 *  @param dictionaries 字典数组
 *  @param modelClass   指定数组中字典映射的对象类型，如果为空取transformedModelClass返回值
 *  @return 返回对象
 */
+ (instancetype)listWithArrayOfDictionaries:(NSArray *)dictionaries modelClass:(Class)modelClass;


/** 改写对象列表 */
- (void)setObjectsFromArrayOfDictionaries:(NSArray *)dictionaries;
/** 附加对象列表 */
- (void)addObjectsFromArrayOfDictionaries:(NSArray *)dictionaries;

/** 将对象列表转换成字典数组 */
- (NSArray *)toArrayOfDictionaries;
/** 将对象列表转换成字典数组 是否映射转换*/
- (NSArray *)toArrayOfDictionariesUsingMapping:(BOOL)mapping;

/** 将对象列表转换成JSON */
- (NSString *)toJSONString;
/** 将对象列表转换成JSON 是否映射转换*/
- (NSString *)toJSONStringUsingMapping:(BOOL)mapping;

/** 加载数据 path为nil时文件名默认为"类名.plist" 根目录为NSCachesDirectory */
- (void)loadFromFile:(NSString *)path;
/** 保存数据 path为nil时文件名默认为"类名.plist" 根目录为NSCachesDirectory */
- (void)saveToFile:(NSString *)path;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (id)objectAtIndex:(NSUInteger)index;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)addObject:(MUPersistent *)object;
- (void)insertObject:(MUPersistent *)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject;

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) id firstObject;
@property (nonatomic, readonly) id lastObject;
@property (nonatomic, readonly) NSMutableArray *objectArray;

@end
