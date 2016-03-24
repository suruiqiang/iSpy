//
//  ISpyTreeViewCell.m
//  iSpyDemo
//
//  Created by lslin on 16/3/11.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import "ISpyTreeViewCell.h"
#import "ISpyConfig.h"
#import "ISpyViewTreeScanner.h"

#import "UIView+ISpyLayer.h"

@interface ISpyTreeViewCell ()

@property (assign, nonatomic) NSInteger level;

@end

@implementation ISpyTreeViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString  *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.detailTextLabel.textColor = [ISpyViewConfig defaultConfig].textDisableColor;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat xOffset = 20 + self.level * 10;
    self.textLabel.frame = CGRectMake(xOffset, 0, self.frame.size.width - xOffset, 20);
    xOffset += 10;
    self.detailTextLabel.frame = CGRectMake(xOffset, 20, self.frame.size.width - xOffset, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIColor *color = selected ? [ISpyViewConfig defaultConfig].textHighlightColor : [ISpyViewConfig defaultConfig].textNormalColor;
    self.textLabel.textColor = color;
}

- (void)configWithTitle:(NSString *)title detail:(NSString *)detail level:(NSInteger)level {
    self.level = level;
    self.textLabel.text = title;
    self.detailTextLabel.text = detail;
}

@end

#pragma mark - ISpyPropTableViewCell

@interface ISpyPropTableViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *valueTextField;

@end

@implementation ISpyPropTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString  *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 40, 14)];
        _titleLabel.textColor = [ISpyViewConfig defaultConfig].textDisableColor;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_titleLabel];
        
        _valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 14, self.frame.size.width - 40, 28)];
        _valueTextField.backgroundColor = ISpyColorRGBA(0, 0, 0, 0.25);
        _valueTextField.textColor = [ISpyViewConfig defaultConfig].textNormalColor;
        _valueTextField.font = [UIFont systemFontOfSize:14];
        _valueTextField.returnKeyType = UIReturnKeyDone;
        _valueTextField.delegate = self;
        [_valueTextField is_setCornerRadius:2];
        [self addSubview:_valueTextField];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(20, 0, self.frame.size.width - 40, 14);
    _valueTextField.frame = CGRectMake(20, 14, self.frame.size.width - 40, 28);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configWithPropertyInfo:(ISpyViewPropertyInfo *)prop {
    // name type value
    self.prop = prop;
    self.titleLabel.text = [NSString stringWithFormat:@"name: %@, type: %@, value:", prop.name, prop.type];
    self.valueTextField.text = prop.value;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate ispyPropTableViewCell:self didChangeValue:textField.text];
    [textField resignFirstResponder];
    return NO;
}

@end

