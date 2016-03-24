//
//  ISpyViewTreeScanner.h
//  iSpyDemo
//
//  Created by lslin on 16/3/10.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark -

@interface ISpyViewInfo : NSObject

@property (strong, nonatomic) NSString *className;
@property (weak, nonatomic) UIView *weakView;
@property (strong, nonatomic) NSNumber *pointerID;
@property (strong, nonatomic) NSArray *propertyCategories; /**< ISpyViewPropertyCategory */
@property (strong, nonatomic) NSArray *subviewInfos; /**< ISpyViewInfo */

@end


#pragma mark -


@interface ISpyViewPropertyCategory : NSObject

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSArray *propertyInfos; /**< ISpyViewPropertyEntry */

@end


#pragma mark -


@interface ISpyViewPropertyInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *value;

@end


#pragma mark -


@interface ISpyViewTreeScanner : NSObject

/**
 *  Get all views and infos
 *
 *  @return NSArray<ISpyViewInfo>
 */
+ (NSArray *)allWindowViewInfos;

/**
 *  Get view info
 *
 *  @param view
 *
 *  @return ISpyViewInfo
 */
+ (ISpyViewInfo *)infoWithView:(UIView *)view;

/**
 *  Find view by pointer value
 *
 *  @param Id pointer value
 *
 *  @return view
 */
+ (UIView *)viewWithId:(long)Id;

+ (id)valueWithType:(NSString *)type valueString:(NSString *)valueStr;

@end
