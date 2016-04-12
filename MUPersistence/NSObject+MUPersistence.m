//
//  NSObject+MUPersistence.m
//  MUPersistence
//
//  Created by Muer on 16/2/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "NSObject+MUPersistence.h"
#import "MUPersistentClassProperty.h"
#import <objc/runtime.h>

static NSArray * MUPersistentAllowedJSONTypes() {
    static NSArray *_MUPersistentAllowedJSONTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MUPersistentAllowedJSONTypes = @[[NSString class], [NSNumber class], [NSDecimalNumber class],
                                          [NSArray class], [NSDictionary class], [NSNull class],
                                          [NSMutableString class], [NSMutableArray class],
                                          [NSMutableDictionary class]];
    });
    
    return _MUPersistentAllowedJSONTypes;
}

static BOOL MUClassIsAllowedJSONType(Class aClass) {
    for (Class allowedType in MUPersistentAllowedJSONTypes()) {
        if ([aClass isSubclassOfClass:allowedType]) {
            return YES;
        }
    }
    return NO;
}

static NSMutableDictionary *kSharedClassProperties = nil;

@implementation NSObject (MUPersistence)

+ (instancetype)mup_objectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] mup_initWithDictionary:dict];
}

- (instancetype)mup_initWithDictionary:(NSDictionary *)dict
{
    id instance = [self init];
    [instance mup_setValuesForDictionary:dict];
    return instance;
}

- (void)mup_setValuesForDictionary:(NSDictionary *)aDictionary
{
    if (!aDictionary || ![aDictionary isKindOfClass:[NSDictionary class]] || aDictionary.count == 0) {
        return;
    }
    NSDictionary *keyMapping = [[self class] mup_keyMapping];
    NSDictionary *propertyInfo = [self mup_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *pName = key;
        MUPersistentClassProperty *property = obj;
        // ignore property
        if ([self mup_shouldIgnoreProperty:property]) {
            return;
        }
        
        // mapping name
        NSString *mappingKeyName = keyMapping[pName];
        if (!mappingKeyName) {
            mappingKeyName = [[self class] mup_keyMappingForPropertyName:pName];
        }
        
        id pValue = nil;
        // property/mapping value
        if (mappingKeyName) {
            @try {
                pValue = [aDictionary valueForKeyPath:mappingKeyName];
            }
            @catch (NSException *exception) {
                pValue = nil;
            }
        }
        if (!pValue) {
            pValue = aDictionary[pName];
        }
        if (!pValue) {
            return;
        }
        
        // primitive type
        if (property.isPrimitiveType) {
            if ([pValue isKindOfClass:[NSString class]] || [pValue isKindOfClass:[NSNumber class]]) {
                [self setValue:pValue forKey:pName];
            }
            return;
        }
        
        // non object type
        if (!property.className) {
            return;
        }
        
        // object
        Class pClass = NSClassFromString(property.className);
        if ([pClass isSubclassOfClass:[NSString class]]) {
            if ([pValue isKindOfClass:[NSString class]]) {
                [self setValue:pValue forKey:pName];
            }
            else if ([pValue isKindOfClass:[NSNumber class]]) {
                [self setValue:[pValue stringValue] forKey:pName];
            }
            else {
                [self setValue:[NSString stringWithFormat:@"%@", pValue] forKey:pName];
            }
        }
        else if ([pClass isSubclassOfClass:[NSNumber class]]) {
            if ([pValue isKindOfClass:[NSNumber class]]) {
                [self setValue:pValue forKey:pName];
            }
            else if ([pValue isKindOfClass:[NSString class]]) {
//                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
//                [self setValue:[nf numberFromString:pValue] forKey:pName];
                [self setValue:@([pValue floatValue]) forKey:pName];
            }
        }
        else if ([pClass isSubclassOfClass:[NSURL class]]) {
            if ([pValue isKindOfClass:[NSString class]]) {
                [self setValue:[NSURL URLWithString:pValue] forKey:pName];
            }
        }
        else if ([pValue isKindOfClass:[NSDictionary class]]) {
            if ([pClass isSubclassOfClass:[NSDictionary class]]) {
                [self setValue:pValue forKey:pName];
            }
            else {
                NSObject *subObject = [[pClass alloc] init];
                [subObject mup_setValuesForDictionary:pValue];
                [self setValue:subObject forKey:pName];
            }
        }
        else if ([pValue isKindOfClass:[NSArray class]]) {
            if ([pClass isSubclassOfClass:[NSArray class]]) {
                Class itemClass = [[self class] mup_persistentClassForKey:pName];
                if (itemClass && !MUClassIsAllowedJSONType(itemClass)) {
                    NSMutableArray *mValues = [NSMutableArray array];
                    for (id itemValue in pValue) {
                        if ([itemValue isKindOfClass:[NSDictionary class]]) {
                            NSObject *itemObj = [[itemClass alloc] init];
                            [itemObj mup_setValuesForDictionary:itemValue];
                            [mValues addObject:itemObj];
                        }
                    }
                    [self setValue:mValues forKey:pName];
                }
                else {
                    [self setValue:pValue forKey:pName];
                }
            }
        }
    }];
}

- (NSString *)mup_toJSONString
{
    NSData *jsonData = nil;
    NSError *error = nil;
    
    @try {
        NSDictionary *dict = [self mup_toDictionary];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"PersistentObject toJSONString error: %@", exception.description);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)mup_toDictionary
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    NSDictionary *propertyInfo = [self mup_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *pName = key;
        MUPersistentClassProperty *property = obj;
        // ignore null value
        id pValue = [self valueForKey:pName];
        if (pValue == nil || pValue == [NSNull null]) {
            return;
        }
        
        // ignore property
        if ([self mup_shouldIgnoreProperty:property]) {
            return;
        }
        
        // primitive type
        if (property.isPrimitiveType) {
            [resultDict setObject:pValue forKey:pName];
            return;
        }
        
        // non object type
        if (!property.className) {
            return;
        }
        
        // object
        Class pClass = NSClassFromString(property.className);
        if ([pClass isSubclassOfClass:[NSString class]] || [pClass isSubclassOfClass:[NSNumber class]]) {
            [resultDict setObject:pValue forKey:pName];
        }
        else if ([pClass isSubclassOfClass:[NSURL class]]) {
            [resultDict setObject:[pValue absoluteString] forKey:pName];
        }
        else if ([pClass isSubclassOfClass:[NSArray class]] && [pValue isKindOfClass:[NSArray class]]) {
            Class itemClass = [[self class] mup_persistentClassForKey:pName];
            if (itemClass && !MUClassIsAllowedJSONType(itemClass)) {
                NSMutableArray *mItems = [NSMutableArray array];
                for (id subObject in pValue) {
                    [mItems addObject:[subObject mup_toDictionary]];
                }
                [resultDict setObject:mItems forKey:pName];
            }
            else {
                [resultDict setObject:pValue forKey:pName];
            }
        }
        else {
            [resultDict setObject:[pValue mup_toDictionary] forKey:pName];
        }
    }];
    return resultDict;
}

+ (NSArray *)mup_ignoredProperties
{
    return nil;
}

+ (BOOL)mup_shouldIgnoreValueTypeProperties
{
    return NO;
}

+ (NSDictionary *)mup_persistentClassForKeyInArray
{
    return nil;
}

+ (NSDictionary *)mup_keyMapping
{
    return nil;
}

+ (NSString *)mup_keyMappingForPropertyName:(NSString *)propertyName
{
    return nil;
}

- (void)mup_propertyValueMap:(id (^)(NSString *name, id value))block
{
    NSDictionary *propertyInfo = [self mup_propertyInfo];
    [propertyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = key;
        id oldValue = [self valueForKey:propertyName];
        id newValue = block(propertyName, oldValue);
        if (oldValue != newValue) {
            [self setValue:newValue forKey:propertyName];
        }
    }];
}

+ (NSArray *)mup_objectsWithDictionaries:(NSArray *)dictionaries modelClass:(Class)modelClass
{
    if (!modelClass || dictionaries.count == 0) {
        return nil;
    }
    
    NSMutableArray *objects = [NSMutableArray array];
    for (id itemDictionary in dictionaries) {
        if ([itemDictionary isKindOfClass:[NSDictionary class]]) {
            [objects addObject:[modelClass mup_objectWithDictionary:itemDictionary]];
        }
    }
    return objects;
}

+ (Class)mup_persistentClassForKey:(NSString *)key
{
    NSDictionary *classInfo = [self mup_persistentClassForKeyInArray];
    id resultClass = classInfo[key];
    if (object_isClass(resultClass)) {
        return resultClass;
    }
    if ([resultClass isKindOfClass:[NSString class]]) {
        return NSClassFromString(resultClass);
    }
    return nil;
}

- (BOOL)mup_shouldIgnoreProperty:(MUPersistentClassProperty *)property
{
    // ignored property
    if ([[[self class] mup_ignoredProperties] containsObject:property.name]) {
        return YES;
    }
    
    // ignore assign, weak property
    if ([[self class] mup_shouldIgnoreValueTypeProperties] && !property.isRetain && !property.isCopy) {
        return YES;
    }
    return NO;
}

- (NSDictionary *)mup_propertyInfo
{
    if (!kSharedClassProperties) {
        kSharedClassProperties = [NSMutableDictionary dictionary];
    }
    NSString *className = NSStringFromClass([self class]);
    NSMutableDictionary *classPropertyInfo = kSharedClassProperties[className];
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
    
    kSharedClassProperties[className] = classPropertyInfo;
    return classPropertyInfo;
}

@end
