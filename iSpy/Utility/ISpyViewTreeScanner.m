//
//  ISpyViewTreeScanner.m
//  iSpyDemo
//
//  Created by lslin on 16/3/10.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import "ISpyViewTreeScanner.h"
#import "ISpyConfig.h"

#import <objc/runtime.h>
#import <math.h>
#import <QuartzCore/QuartzCore.h>


#pragma mark - ISpyViewInfo

@implementation ISpyViewInfo

@end


#pragma mark - ISpyViewPropertyCategory

@implementation ISpyViewPropertyCategory

@end


#pragma mark - ISpyViewPropertyInfo

@implementation ISpyViewPropertyInfo

@end


#pragma mark - ISpyViewTreeScanner

@implementation ISpyViewTreeScanner

#pragma mark - Public

+ (NSArray *)allWindowViewInfos {
    UIApplication *app = [UIApplication sharedApplication];
    NSMutableArray *windowViews = [NSMutableArray array];
    
    if (app && app.windows) {
        
        void (^scanViewProperties)() = ^() {
            for (UIWindow *window in app.windows) {
                ISpyViewInfo* viewInfo = [self infoWithView:window];
                if (viewInfo) {
                    [windowViews addObject:viewInfo];
                }
            }
        };
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), scanViewProperties);
    }
    return windowViews;
}

+ (ISpyViewInfo *)infoWithView:(UIView *)view {
    if (view) {
        if (view.tag == kISpyPlaceHolderViewTag || view.tag == kISpyViewTag) {
            return nil;
        }
        ISpyViewInfo *info = [ISpyViewInfo new];
        info.weakView = view;
        info.pointerID = [NSNumber numberWithLong:(long)view];
        
        // Base properties
        NSString *className = [[view class] description];
        NSString *objectName = view.accessibilityLabel ? [NSString stringWithFormat:@"%@ : %@", view.accessibilityLabel, className] : className;
        info.className = objectName;
        
        // Properties from super classes
        NSMutableArray *propertieCategories = [NSMutableArray array];
        
        // UIGeometry properties
        [self safeAddObject:[self propertyCategoryWithName:@"UIGeometry" props:[self uiGeometryPropertiesWithView:view]] toArray:propertieCategories];
        
        // UIRendering
        [self safeAddObject:[self propertyCategoryWithName:@"UIViewRendering" props:[self uiViewRenderingPropertiesWithView:view]] toArray:propertieCategories];
        
        // CALayer
        [self safeAddObject:[self propertyCategoryWithName:@"CALayer" props:[self propertiesWithClass:[CALayer class] object:view.layer]] toArray:propertieCategories];
        
        // Classes
        Class class = [view class];
        if (class != [NSClassFromString(@"UIButtonLabel") class]) {
#warning TODO - will change button label frame
            while (class != [NSObject class]) {
                [self safeAddObject:[self propertyCategoryWithName:[class description] props:[self propertiesWithClass:class object:view]] toArray:propertieCategories];
                class = [class superclass];
            }
        }
        
        info.propertyCategories = propertieCategories;
        
        // Subviews
        NSMutableArray *subviewInfos = [NSMutableArray array];
        for (UIView *subview in [view subviews]) {
            ISpyViewInfo *subviewInfo = [self infoWithView:subview];
            if (subviewInfo) {
                [subviewInfos addObject:subviewInfo];
            }
        }
        info.subviewInfos = subviewInfos;
        return info;
    }
    return nil;
}

+ (UIView *)viewWithId:(long)Id {
    UIApplication *app = [UIApplication sharedApplication];
    if (app) {
        for (UIView *v in [app windows]) {
            UIView *result = [self recursiveSearchForView:Id parent:v];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}

+ (id)valueWithType:(NSString *)type valueString:(NSString *)valueStr {

    if ([type isEqualToString: @"NSString"]) {
        return valueStr;
    }
    if ([type isEqualToString: @"int"]
        || [type isEqualToString: @"float"]
        || [type isEqualToString: @"double"]
        || [type isEqualToString: @"long"]
        || [type isEqualToString: @"BOOL"]
        || [type isEqualToString: @"char"]) {
        NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
        return [formatString numberFromString:valueStr];
    }
    if ([type isEqualToString: @"UIColor"]) {
        return UIColorFromNSString(valueStr);
    }
    if ([type isEqualToString: @"CGRect"]) {
        return [NSValue valueWithCGRect:CGRectFromString(valueStr)];
    }
    if ([type isEqualToString: @"CGPoint"]) {
        return [NSValue valueWithCGPoint:CGPointFromString(valueStr)];
    }
    if ([type isEqualToString: @"CGSize"]) {
        return [NSValue valueWithCGSize:CGSizeFromString(valueStr)];
    }
    if ([type isEqualToString: @"CGAffineTransform"]) {
        return [NSValue valueWithCGAffineTransform:CGAffineTransformFromString(valueStr)];
    }
    if ([type isEqualToString: @"CATransform3D"]) {
        return [NSValue valueWithCATransform3D:CATransform3DFromString(valueStr)];
    }
    if ([type isEqualToString: @"UIEdgeInsets"]) {
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsFromString(valueStr)];
    }
    return nil;
}

#pragma mark - Private

+ (UIView *)recursiveSearchForView:(long)Id parent:(UIView *)parent {
    if ((__bridge void *)parent == (void *)Id) {
        return parent;
    }
    for (UIView *v in [parent subviews]) {
        UIView *result = [self recursiveSearchForView:Id parent:v];
        if (result) {
            return result;
        }
    }
    return nil;
}

+ (NSMutableArray *)propertiesWithClass:(Class)class object:(NSObject *)obj {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    NSMutableArray *propertiesArray = [NSMutableArray array];
    
    // handle UITextInputTraits properties which aren't KVO compilant
    BOOL conformsToUITextInputTraits = [class conformsToProtocol:@protocol(UITextInputTraits)];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:[NSString defaultCStringEncoding]];
        
        if (conformsToUITextInputTraits) {
            if (protocol_getMethodDescription(@protocol(UITextInputTraits), NSSelectorFromString(propertyName), NO, YES).name != NULL) {
                continue;
            }
            if ([@"secureTextEntry" isEqualToString:propertyName]) {
                continue;
            }
        }
        
        [self safeAddObject:[self propertyInfoForOboject:obj withName:propertyName] toArray:propertiesArray];
    }
    free(properties);
    return propertiesArray;
}

+ (NSArray *)uiGeometryPropertiesWithView:(UIView *)view {
    NSMutableArray *properties = [NSMutableArray array];
    
    NSArray *propNames = @[@"frame", @"bounds", @"center", @"transform"];
    
    for (NSString *name in propNames) {
        [self safeAddObject:[self propertyInfoForOboject:view withName:name] toArray:properties];
    }
//    [self safeAddObject:[self propertyInfoWithName:@"layer.transform" type:@"CATransform3D" value:NSStringFromCATransform3D(view.layer.transform)] toArray:properties];
    
    return properties;
}

+ (NSArray *)uiViewRenderingPropertiesWithView:(UIView *)view {
    NSMutableArray *properties = [NSMutableArray array];

    NSArray *propNames = @[@"isHidden", @"backgroundColor", @"alpha", @"opaque", @"clipsToBounds", @"contentMode", @"clearsContextBeforeDrawing"];

    for (NSString *name in propNames) {
        [self safeAddObject:[self propertyInfoForOboject:view withName:name] toArray:properties];
    }
    
    return properties;
}

+ (ISpyViewPropertyCategory *)propertyCategoryWithName:(NSString *)name props:(NSArray *)props  {
    ISpyViewPropertyCategory *info = [ISpyViewPropertyCategory new];
    info.category = name;
    info.propertyInfos = props;
    return info;
}

+ (ISpyViewPropertyInfo *)propertyInfoWithName:(NSString *)name type:(NSString *)type value:(NSString *)value {
    ISpyViewPropertyInfo *info = [ISpyViewPropertyInfo new];
    info.name = name;
    info.type = type;
    info.value = value;
    return info;
}

// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
+ (ISpyViewPropertyInfo *)propertyInfoForOboject:(id)obj withName:(NSString *)name {
    if (obj && name) {
        if ([self.ignorePropertyNames containsObject:name]) {
            return nil;
        }
        
        id value = nil;
        
        if ([obj respondsToSelector:NSSelectorFromString(name)]) {
            @try {
                value = [obj valueForKey:name];
            }
            @catch (NSException *exception) {
                value = nil;
            }
        }
        if (!value) {
            return nil;
        }
        
        NSString *typeStr = nil;
        NSString *valueStr = nil;

        if ([value isKindOfClass:[NSString class]]) {
            typeStr = @"NSString";
            valueStr = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            const char * pObjCType = [value objCType];
            if (strcmp(pObjCType, @encode(int)) == 0) {
                typeStr = @"int";
                valueStr = NSStringFromInt([value intValue]);
            } else if (strcmp(pObjCType, @encode(float)) == 0) {
                typeStr = @"float";
                valueStr = NSStringFromFloat([value floatValue]);
            } else if (strcmp(pObjCType, @encode(double)) == 0) {
                typeStr = @"double";
                valueStr = NSStringFromFloat([value doubleValue]);
            } else if (strcmp(pObjCType, @encode(long)) == 0) {
                typeStr = @"long";
                valueStr = NSStringFromLong([value longValue]);
            } else if (strcmp(pObjCType, @encode(BOOL)) == 0
                       || value == (void*)kCFBooleanFalse
                       || value == (void*)kCFBooleanTrue) {
                typeStr = @"BOOL";
                valueStr = NSStringFromBOOL([value boolValue]);
            } else if (strcmp(pObjCType, @encode(char)) == 0) {
                typeStr = @"char";
                valueStr = NSStringFromInt([value charValue]);
            }
        } else if ([value isKindOfClass:[UIColor class]]) {
            typeStr = @"UIColor";
            valueStr = NSStringFromUIColor(value);
        } else {
            if ([value respondsToSelector:@selector(objCType)]) {
                const char * pObjCType = [value objCType];
                NSString *strObjcType = [NSString stringWithCString:pObjCType encoding:[NSString defaultCStringEncoding]];
                
                if ([strObjcType hasPrefix:@"{CGRect="]) {
                    typeStr = @"CGRect";
                    valueStr = NSStringFromCGRect([value CGRectValue]);
                } else if ([strObjcType hasPrefix:@"{CGPoint="]) {
                    typeStr = @"CGPoint";
                    valueStr = NSStringFromCGPoint([value CGPointValue]);
                } else if ([strObjcType hasPrefix:@"{CGSize="]) {
                    typeStr = @"CGSize";
                    valueStr = NSStringFromCGSize([value CGSizeValue]);
                } else if ([strObjcType hasPrefix:@"{CGAffineTransform="]) {
                    typeStr = @"CGAffineTransform";
                    valueStr = NSStringFromCGAffineTransform([value CGAffineTransformValue]);
                } else if ([strObjcType hasPrefix:@"{CATransform3D="]) {
                    typeStr = @"CATransform3D";
                    
                    CATransform3D *transform3DValue = (__bridge CATransform3D *)value;
                    valueStr = NSStringFromCATransform3D(*transform3DValue);
                } else if ([strObjcType hasPrefix:@"{UIEdgeInsets="]) {
                    typeStr = @"UIEdgeInsets";
                    valueStr = NSStringFromUIEdgeInsets([value UIEdgeInsetsValue]);
                } else if ([strObjcType hasPrefix:@"{"]) {
                    typeStr = [strObjcType substringWithRange:NSMakeRange(1, [strObjcType rangeOfString:@"="].location - 1)];
                    valueStr = [NSString stringWithFormat:@"%@", [value description]];
                } else {
                    //NSLog(@"failed to get propertyInfoForOboject: %@ withName: %@, value: %@", obj, name, value);
                }
            } else {
                typeStr = NSStringFromClass([value class]);
                valueStr = [NSString stringWithFormat:@"%@", [value description]];
            }
        }
        
        if (typeStr && valueStr && ![typeStr isEqualToString:@"?"]) {
            //NSLog(@"propertyInfoForOboject: %@ withName: %@, value: %@", obj, name, valueStr);
            return [self propertyInfoWithName:name type:typeStr value:valueStr];
        }
    }
    
    return nil;
}

+ (void)safeAddObject:(id)obj toArray:(NSMutableArray *)array {
    if (obj) {
        [array addObject:obj];
    }
}

+ (NSArray *)ignorePropertyNames {
    static NSArray *names = nil;
    if (!names) {
        names = @[@"selectedTextRange",
                  @"caretRect",
                  @"unsatisfiableConstraintsLoggingSuspended",
                  @"collisionBoundingPath",
                  @"collisionBoundsType",
                  @"__content",
                  @"_canBeParentTraitEnviroment"
                  ];
    }
    return names;
}

#pragma mark - static

static NSString* NSStringFromInt(int value) {
    return [NSString stringWithFormat:@"%d", value];
}

static NSString* NSStringFromBOOL(BOOL value) {
    return value ? @"YES" : @"NO";
}

static NSString* NSStringFromFloat(float value) {
    return [NSString stringWithFormat:@"%f", value];
}

static NSString* NSStringFromLong(long value) {
    return [NSString stringWithFormat:@"%ld", value];
}

static NSString* NSStringFromUIColor(UIColor *color) {
    if (color) {
        CGColorSpaceRef colorSpace = CGColorGetColorSpace([color CGColor]);
        CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
        
        NSString *prefix = @"A???";
        switch (model) {
            case kCGColorSpaceModelCMYK:
                prefix = @"CMYKA";
                break;
            case kCGColorSpaceModelDeviceN:
                prefix = @"DeviceNA";
                break;
            case kCGColorSpaceModelIndexed:
                prefix = @"IndexedA";
                break;
            case kCGColorSpaceModelLab:
                prefix = @"LabA";
                break;
            case kCGColorSpaceModelMonochrome:
                prefix = @"MONOA";
                break;
            case kCGColorSpaceModelPattern:
                prefix = @"APattern";
                break;
            case kCGColorSpaceModelRGB:
                prefix = @"RGBA";
                break;
            case kCGColorSpaceModelUnknown:
                prefix = @"A???";
                break;
        }
        size_t n = CGColorGetNumberOfComponents([color CGColor]);
        const CGFloat *componentsArray = CGColorGetComponents([color CGColor]);
        
        NSMutableArray *array = [NSMutableArray array];
        //[array addObject:[NSNumber numberWithInt:(int)(CGColorGetAlpha([color CGColor])*255.0f)]];
        for (size_t i = 0; i < n; ++i) {
            [array addObject:[NSNumber numberWithInt:(int)(componentsArray[i] * 255.0f)]];
        }
        NSString *components = [array componentsJoinedByString:@","];
        
        return [NSString stringWithFormat:@"%@(%@)", prefix, components];
    }
    return @"nil";
}

static UIColor* UIColorFromNSString(NSString *str) {
    NSInteger location = [str rangeOfString:@"("].location;
    if (location == NSNotFound) {
        return nil;
    }
    NSString *prefix = [str substringToIndex:location];
    if ([prefix isEqualToString:@"RGBA"]) {
        NSString *colorComponent = [str substringWithRange:NSMakeRange(location + 1, str.length - (location + 1) - 1)];
        NSArray *compoents = [colorComponent componentsSeparatedByString:@","];
        if (compoents.count < 3) {
            return nil;
        }
        NSInteger r = [compoents[0] integerValue];
        NSInteger g = [compoents[1] integerValue];
        NSInteger b = [compoents[2] integerValue];
        NSInteger a = compoents.count > 3 ? [compoents[3] integerValue] : 0;
        
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
    } else {
        //TODO
        return nil;
    }
}

static NSString* NSStringFromCATransform3D(CATransform3D transform) {
    return [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f",
            (transform.m11),
            (transform.m12),
            (transform.m13),
            (transform.m14),
            (transform.m21),
            (transform.m22),
            (transform.m23),
            (transform.m24),
            (transform.m31),
            (transform.m32),
            (transform.m33),
            (transform.m34),
            (transform.m41),
            (transform.m42),
            (transform.m43),
            (transform.m44)
            ];
}

static CATransform3D CATransform3DFromString(NSString *str) {
    CATransform3D transform = CATransform3DIdentity;
    NSArray *list = [str componentsSeparatedByString:@","];
    if (list.count == 12) {
        transform.m11 = [list[0] floatValue];
        transform.m12 = [list[1] floatValue];
        transform.m13 = [list[2] floatValue];
        transform.m14 = [list[3] floatValue];
        transform.m21 = [list[4] floatValue];
        transform.m22 = [list[5] floatValue];
        transform.m23 = [list[6] floatValue];
        transform.m24 = [list[7] floatValue];
        transform.m31 = [list[8] floatValue];
        transform.m32 = [list[9] floatValue];
        transform.m33 = [list[10] floatValue];
        transform.m34 = [list[11] floatValue];
        transform.m41 = [list[12] floatValue];
        transform.m42 = [list[13] floatValue];
        transform.m43 = [list[14] floatValue];
        transform.m44 = [list[15] floatValue];
    }
    return transform;
}

@end
