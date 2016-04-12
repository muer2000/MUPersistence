//
//  MUPersistentList.m
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUPersistentList.h"
#import "MUPersistent.h"

@interface MUPersistentList ()
{
    Class _persistentModelClass;
    NSMutableArray *_objectArray;
}
@end

@implementation MUPersistentList

+ (Class)transformedModelClass
{
    return nil;
}

+ (instancetype)listWithArrayOfDictionaries:(NSArray *)dictionaries
{
    return [self listWithArrayOfDictionaries:dictionaries modelClass:nil];
}

+ (instancetype)listWithArrayOfDictionaries:(NSArray *)dictionaries modelClass:(Class)modelClass
{
    return [[self alloc] initWithArrayOfDictionaries:dictionaries modelClass:modelClass];
}

- (instancetype)init
{
    return [self initWithArrayOfDictionaries:nil];
}

- (instancetype)initWithArrayOfDictionaries:(NSArray *)dictionaries
{
    return [self initWithArrayOfDictionaries:dictionaries modelClass:nil];
}

- (instancetype)initWithArrayOfDictionaries:(NSArray *)dictionaries modelClass:(Class)modelClass
{
    self = [super init];
    if (self) {
        _persistentModelClass = modelClass ? : [[self class] transformedModelClass];
        NSAssert([_persistentModelClass isSubclassOfClass:[MUPersistent class]], @"the modelClass must be a subclass of MUPersistent");
 
        [self setObjectsFromArrayOfDictionaries:dictionaries];
    }
    return self;
}

- (NSMutableArray *)objectArray
{
    if (_objectArray == nil) {
        _objectArray = [NSMutableArray array];
    }
    return _objectArray;
}

- (void)setObjectsFromArrayOfDictionaries:(NSArray *)dictionaries
{
    [self removeAllObjects];
    [self addObjectsFromArrayOfDictionaries:dictionaries];
}

- (void)addObjectsFromArrayOfDictionaries:(NSArray *)dictionaries
{
    if (dictionaries == nil || _persistentModelClass == NULL)
        return;
    for (id objectDic in dictionaries) {
        if ([objectDic isKindOfClass:[NSDictionary class]]) {
            MUPersistent *tempObject = [[_persistentModelClass alloc] init];
            [tempObject setValuesForDictionary:objectDic];
            //将对象加到数组中
            [self.objectArray addObject:tempObject];
        }
    }
}

- (NSArray *)toArrayOfDictionaries
{
    return [self toArrayOfDictionariesUsingMapping:NO];
}

- (NSArray *)toArrayOfDictionariesUsingMapping:(BOOL)mapping
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (id subObject in self.objectArray)
        [tempArray addObject:[subObject toDictionaryUsingMapping:mapping]];
    return tempArray;
}

- (NSString *)toJSONString
{
    return [self toJSONStringUsingMapping:NO];
}

- (NSString *)toJSONStringUsingMapping:(BOOL)mapping
{
    NSData *jsonData = nil;
    NSError *error = nil;
    
    @try {
        NSArray *array = [self toArrayOfDictionariesUsingMapping:mapping];
        jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"PersistentObject toJSONString error: %@", exception.description);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


#pragma mark - Array

- (NSUInteger)count
{
    return self.objectArray.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return self.objectArray[index];
    }
    return nil;
}

- (id)firstObject
{
    if (self.objectArray.count > 0) {
        return self.objectArray.firstObject;
    }
    return nil;
}

- (id)lastObject
{
    if (self.objectArray.count > 0) {
        return self.objectArray.lastObject;
    }
    return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self.objectArray objectAtIndexedSubscript:idx];
}

- (void)addObjectsFromArray:(NSArray *)otherArray
{
    [self.objectArray addObjectsFromArray:otherArray];
}

- (void)addObject:(MUPersistent *)object
{
    [self.objectArray addObject:object];
}

- (void)insertObject:(MUPersistent *)object atIndex:(NSUInteger)index
{
    if (object) {
        @try {
            [self.objectArray insertObject:object atIndex:index];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        [self.objectArray removeObjectAtIndex:index];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index < self.count) {
        [self.objectArray replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)removeAllObjects
{
    [self.objectArray removeAllObjects];
}

- (void)removeObject:(id)anObject
{
    [self.objectArray removeObject:anObject];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    [self.objectArray setObject:obj atIndexedSubscript:idx];
}


#pragma mark - File read write

- (NSString *)p_defaultPersistentFilePath
{
    NSString *fileName = NSStringFromClass([self class]);
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    return [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
}

- (void)loadFromFile:(NSString *)path
{
    if (!path) {
        path = [self p_defaultPersistentFilePath];
    }
    NSArray *arrayOfDictionaries = [NSArray arrayWithContentsOfFile:path];
    if (arrayOfDictionaries) {
        [self setObjectsFromArrayOfDictionaries:arrayOfDictionaries];
    }
}

- (void)saveToFile:(NSString *)path
{
    NSArray *arrayOfDictionaries = [self toArrayOfDictionaries];
    if (arrayOfDictionaries) {
        if (!path) {
            path = [self p_defaultPersistentFilePath];
        }
        [arrayOfDictionaries writeToFile:path atomically:YES];
    }
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.objectArray countByEnumeratingWithState:state objects:buffer count:len];
}


#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self toArrayOfDictionaries]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
//    MUPersistentList *copy = [[self.class allocWithZone:zone] init];
//    [copy setObjectsFromArrayOfDictionaries:[self toArrayOfDictionaries]];
//    return copy;
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}


#pragma mark - NSCoding

static NSString * const kMUPersistentListCoderKey = @"MUPersistentListCoderKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self toJSONString] forKey:kMUPersistentListCoderKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *jsonStr = [aDecoder decodeObjectForKey:kMUPersistentListCoderKey];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return  [self initWithArrayOfDictionaries:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL]];
}

@end
