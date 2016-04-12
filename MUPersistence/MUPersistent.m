//
//  MUPersistent.m
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUPersistent.h"
#import "MUPersistentList.h"
#import "MUPersistentClassProperty.h"

static NSString * const kMUPersistentCoderKey = @"kMUPersistentCoderKey";
static NSMutableDictionary *kSharedPropertyInfo = nil;

@implementation MUPersistent

+ (instancetype)objectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        [self setValuesForDictionary:dict];
    }
    return self;
}

- (void)setValuesForDictionary:(NSDictionary *)aDictionary
{
    if (!aDictionary || ![aDictionary isKindOfClass:[NSDictionary class]] || aDictionary.count == 0) {
        return;
    }
    NSDictionary *keyMapping = [self.class keyMapping];
    NSDictionary *propertyInfo = [self p_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = key;
        MUPersistentClassProperty *property = obj;
        // ignore property
        if ([self p_shouldIgnoreProperty:property]) {
            return;
        }
        
        // mapping name
        NSString *mappingKeyName = keyMapping[propertyName];
        if (!mappingKeyName) {
            mappingKeyName = [[self class] keyMappingForPropertyName:propertyName];
        }
        
        // property/mapping value
        id propertyValue = nil;
        if (mappingKeyName) {
            @try {
                propertyValue = [aDictionary valueForKeyPath:mappingKeyName];
            }
            @catch (NSException *exception) {
                propertyValue = nil;
            }
        }
        if (!propertyValue) {
            propertyValue = aDictionary[propertyName];
        }
        if (!propertyValue) {
            return;
        }
        
        // primitive type
        if (property.isPrimitiveType) {
            if ([propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNumber class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }
            return;
        }
        
        // non object type
        if (!property.className) {
            return;
        }
        
        // object
        Class aClass = NSClassFromString(property.className);
        if ([aClass isSubclassOfClass:[NSString class]]) {
            if ([propertyValue isKindOfClass:[NSString class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }
            else if ([propertyValue isKindOfClass:[NSNumber class]]) {
                [self setValue:[propertyValue stringValue] forKey:propertyName];
            }
            else {
                [self setValue:[NSString stringWithFormat:@"%@", propertyValue] forKey:propertyName];
            }
        }
        else if ([aClass isSubclassOfClass:[NSNumber class]]) {
            if ([propertyValue isKindOfClass:[NSNumber class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }
            else if ([propertyValue isKindOfClass:[NSString class]]) {
                //                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                //                [self setValue:[nf numberFromString:propertyValue] forKey:propertyName];
                [self setValue:@([propertyValue floatValue]) forKey:propertyName];
            }
        }
        else if ([aClass isSubclassOfClass:[NSURL class]]) {
            if ([propertyValue isKindOfClass:[NSString class]]) {
                [self setValue:[NSURL URLWithString:propertyValue] forKey:propertyName];
            }
        }
        else if ([propertyValue isKindOfClass:[NSDictionary class]]) {
            if ([aClass isSubclassOfClass:[MUPersistent class]]) {
                MUPersistent *subObject = [[aClass alloc] init];
                [subObject setValuesForDictionary:propertyValue];
                [self setValue:subObject forKey:propertyName];
            }
            else if ([aClass isSubclassOfClass:[NSDictionary class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        else if ([propertyValue isKindOfClass:[NSArray class]]) {
            if ([aClass isSubclassOfClass:[MUPersistentList class]]) {
                if ([[aClass transformedModelClass] isSubclassOfClass:[MUPersistent class]]) {
                    MUPersistentList *subList = [[aClass alloc] init];
                    [subList setObjectsFromArrayOfDictionaries:propertyValue];
                    [self setValue:subList forKey:propertyName];
                }
            }
            else if ([aClass isSubclassOfClass:[NSArray class]]) {
                [self setValue:propertyValue forKey:propertyName];
            }
        }
    }];
}

- (NSMutableDictionary *)toDictionary
{
    return [self toDictionaryUsingMapping:NO];
}

- (NSMutableDictionary *)toDictionaryUsingMapping:(BOOL)mapping
{
    NSDictionary *keyMapping = [self.class keyMapping];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    NSDictionary *propertyInfo = [self p_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = key;
        MUPersistentClassProperty *property = obj;
        // ignore null value
        id propertyValue = [self valueForKey:propertyName];
        if (propertyValue == nil || propertyValue == [NSNull null]) {
            return;
        }
        // ignore property
        if ([self p_shouldIgnoreProperty:property]) {
            return;
        }
        
        NSString *keyName = propertyName;
        // mapping name
        if (mapping) {
            NSString *mappingKeyName = keyMapping[propertyName];
            if (!mappingKeyName) {
                mappingKeyName = [[self class] keyMappingForPropertyName:propertyName];
            }
            if (mappingKeyName) {
                keyName = mappingKeyName;
            }
        }
        
        // primitive type
        if (property.isPrimitiveType) {
            [resultDict setObject:propertyValue forKey:keyName];
            return;
        }
        
        // non object type
        if (!property.className) {
            return;
        }
        
        // object
        Class aClass = NSClassFromString(property.className);
        if ([aClass isSubclassOfClass:[NSString class]] || [aClass isSubclassOfClass:[NSNumber class]]) {
            [resultDict setObject:propertyValue forKey:keyName];
        }
        else if ([aClass isSubclassOfClass:[MUPersistent class]]) {
            [resultDict setObject:[propertyValue toDictionary] forKey:keyName];
        }
        else if ([aClass isSubclassOfClass:[MUPersistentList class]]) {
            [resultDict setObject:[propertyValue toArrayOfDictionariesUsingMapping:mapping] forKey:keyName];
        }
        else if ([aClass isSubclassOfClass:[NSURL class]]) {
            [resultDict setObject:[propertyValue absoluteString] forKey:keyName];
        }
    }];
    return resultDict;
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
        NSDictionary *dict = [self toDictionaryUsingMapping:mapping];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"PersistentObject toJSONString error: %@", exception.description);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)keyMapping
{
    return nil;
}

+ (NSString *)keyMappingForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (void)propertyValueMap:(id (^)(NSString *name, id value))block
{
    NSDictionary *propertyInfo = [self p_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = key;
        id oldValue = [self valueForKey:propertyName];
        id newValue = block(propertyName, oldValue);
        if (oldValue != newValue) {
            [self setValue:newValue forKey:propertyName];
        }
    }];
}

+ (NSArray *)ignoredProperties
{
    return nil;
}

+ (BOOL)shouldIgnoreValueTypeProperties
{
    return NO;
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
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dataDict) {
        [self setValuesForDictionary:dataDict];
    }
}

- (void)saveToFile:(NSString *)path
{
    NSDictionary *dataDict = [self toDictionary];
    if (dataDict) {
        if (!path) {
            path = [self p_defaultPersistentFilePath];
        }
        [dataDict writeToFile:path atomically:YES];
    }
}


#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self toDictionary]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
//    MUPersistent *copy = [[self.class allocWithZone:zone] init];
//    [copy setValuesForDictionary:[self toDictionary]];
//    return copy;
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self toJSONString] forKey:kMUPersistentCoderKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *jsonStr = [aDecoder decodeObjectForKey:kMUPersistentCoderKey];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return  [self initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL]];
}


#pragma mark - Private

- (NSDictionary *)p_propertyInfo
{
    if (!kSharedPropertyInfo) {
        kSharedPropertyInfo = [NSMutableDictionary dictionary];
    }

    NSString *className = NSStringFromClass([self class]);
    NSMutableDictionary *classPropertyInfo = kSharedPropertyInfo[className];
    if (classPropertyInfo) {
        return classPropertyInfo;
    }
    
    classPropertyInfo = [NSMutableDictionary dictionary];
    [MUPersistentClassProperty enumeratePropertyAttributesWithClass:[self class] usingBlock:^(MUPersistentClassProperty *property, BOOL *stop) {
        NSString *propertyName = property.name;
        // ignore private property
        if ([propertyName hasPrefix:@"_"]) {
            return;
        }
        // ignore readonly property
        if (property.isReadonly) {
            return;
        }
        if (property.className || property.isPrimitiveType) {
            classPropertyInfo[propertyName] = property;
        }
    }];
    
    kSharedPropertyInfo[className] = classPropertyInfo;
    return classPropertyInfo;
}

- (BOOL)p_shouldIgnoreProperty:(MUPersistentClassProperty *)property
{
    // ignored property
    if ([[[self class] ignoredProperties] containsObject:property.name]) {
        return YES;
    }
    
    // ignore assign, weak property
    if ([[self class] shouldIgnoreValueTypeProperties] && !property.isRetain && !property.isCopy) {
        return YES;
    }
    return NO;
}

- (NSString *)p_mappingNameForKey:(NSString *)key
{
    NSDictionary *keyMapping = [self.class keyMapping];
    NSString *mapStr = keyMapping[key];
    if (!mapStr) {
        mapStr = [[self class] keyMappingForPropertyName:key];
    }
    return mapStr;
}

@end
