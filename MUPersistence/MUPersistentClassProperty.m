//
//  MUPersistentClassProperty.m
//  MUPersistence
//
//  Created by Muer on 16/4/1.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUPersistentClassProperty.h"
#import <objc/runtime.h>

static NSArray * MUPrimitiveTypes() {
    static NSArray *types = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = @[@(_C_BFLD), @(_C_BOOL), @(_C_CHR), @(_C_UCHR), @(_C_SHT), @(_C_USHT),
                  @(_C_INT), @(_C_UINT), @(_C_LNG), @(_C_ULNG), @(_C_LNG_LNG), @(_C_ULNG_LNG),
                  @(_C_FLT), @(_C_DBL)];
    });
    return types;
}

@interface MUPersistentClassProperty ()

@property (nonatomic, copy) NSString *typeEncoding;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray *protocolNames;

@property (nonatomic, assign) char objcType;
@property (nonatomic, assign) BOOL isPrimitiveType;
@property (nonatomic, assign) BOOL isReadonly;

@property (nonatomic, assign) BOOL isRetain;
@property (nonatomic, assign) BOOL isCopy;
@property (nonatomic, assign) BOOL isWeak;

@end

@implementation MUPersistentClassProperty

+ (void)enumeratePropertyAttributesWithClass:(Class)objectClass usingBlock:(void(^)(MUPersistentClassProperty *property, BOOL *stop))block
{
    if (!block) {
        return;
    }
    Class currentClass = objectClass;
    BOOL stop = NO;
    while (!stop && currentClass != [NSObject class]) {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++) {
            MUPersistentClassProperty *muProperty = [[MUPersistentClassProperty alloc] init];
            objc_property_t itemProperty = properties[i];
            muProperty.name = @(property_getName(itemProperty));
            unsigned int attrCount = 0;
            objc_property_attribute_t *attrs = property_copyAttributeList(itemProperty, &attrCount);
            for (unsigned int j = 0; j < attrCount; j++) {
                switch (*attrs[j].name) {
                    case 'T': {
                        const char *code = attrs[j].value;
                        muProperty.objcType = *code;
                        if (muProperty.objcType == _C_ID) {
                            if (code[1] == '\0') {
                                muProperty.typeEncoding = @"@";
                            }
                            else {
                                NSString *typeString = @(attrs[j].value);
                                // get class @"NSObject<>" -> NSObject<>
                                typeString = [typeString substringWithRange:NSMakeRange(2, typeString.length - 3)];
                                NSString *className = typeString;
                                // contain protocol "Class<Protocol>"
                                NSArray *protocolNames = nil;
                                NSUInteger lessThanSignLocation = [className rangeOfString:@"<"].location;
                                if (lessThanSignLocation != NSNotFound) {
                                    // is id type
                                    if (lessThanSignLocation == 0) {
                                        className = nil;
                                    }
                                    else {
                                        className = [className substringToIndex:lessThanSignLocation];
                                    }
                                    // "<P1><P2>" -> "P1><P2>"
                                    NSString *protocolsString = [typeString substringFromIndex:lessThanSignLocation + 1];
                                    // "P1><P2>" -> Array[P1, P2]
                                    protocolNames = [[protocolsString stringByReplacingOccurrencesOfString:@">" withString:@""] componentsSeparatedByString:@"<"];
                                }
                                muProperty.className = className;
                                muProperty.typeEncoding = className ? : @"@";
                                muProperty.protocolNames = protocolNames;
                            }
                        }
                        else {
                            if ([MUPrimitiveTypes() containsObject:@(muProperty.objcType)]) {
                                muProperty.isPrimitiveType = YES;
                            }
                            muProperty.typeEncoding = @(code);
                        }
                    }
                        break;
                    case 'N':// nonatomic
                        break;
                    case 'D':// dynamic
                        break;
                    case 'R':
                        muProperty.isReadonly = YES;
                        break;
                    case '&':
                        muProperty.isRetain = YES;
                        break;
                    case 'C':
                        muProperty.isCopy = YES;
                        break;
                    case 'W':
                        muProperty.isWeak = YES;
                        break;
                    case 'G':// setter
                        break;
                    case 'S':// setter
                        break;
                    case 'P':// garbage collection
                        break;
                    default:
                        break;
                }
            }
            
            block(muProperty, &stop);
            if (stop) {
                break;
            }
        }
        free(properties);
        // next super class
        currentClass = [currentClass superclass];
    }
}

@end
