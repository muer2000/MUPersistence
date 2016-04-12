//
//  MUPersistentClassProperty.h
//  MUPersistence
//
//  Created by Muer on 16/4/1.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUPersistentClassProperty : NSObject

+ (void)enumeratePropertyAttributesWithClass:(Class)objectClass usingBlock:(void(^)(MUPersistentClassProperty *property, BOOL *stop))block;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSArray *protocolNames;

@property (nonatomic, readonly) char objcType;
@property (nonatomic, readonly) BOOL isPrimitiveType;
@property (nonatomic, readonly) BOOL isReadonly;

@property (nonatomic, readonly) BOOL isRetain;
@property (nonatomic, readonly) BOOL isCopy;
@property (nonatomic, readonly) BOOL isWeak;

@end
