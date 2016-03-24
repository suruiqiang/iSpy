//
//  ISpyTreeViewCell.h
//  iSpyDemo
//
//  Created by lslin on 16/3/11.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ISpyViewPropertyInfo;

@interface ISpyTreeViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString  *)reuseIdentifier;

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail level:(NSInteger)level;

@end


@class ISpyPropTableViewCell;


@protocol ISpyPropTableViewCellDelegate <NSObject>

@optional
- (void)ispyPropTableViewCell:(ISpyPropTableViewCell *)cell didChangeValue:(NSString *)value;

@end

@interface ISpyPropTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ISpyPropTableViewCellDelegate> delegate;
@property (strong, nonatomic) ISpyViewPropertyInfo *prop;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString  *)reuseIdentifier;

- (void)configWithPropertyInfo:(ISpyViewPropertyInfo *)prop;

@end
