//
//  ISpyTreeView.m
//  iSpyDemo
//
//  Created by lslin on 16/3/11.
//  Copyright © 2016年 lessfun.com. All rights reserved.
//

#import "ISpyTreeView.h"
#import "ISpyTreeViewCell.h"
#import "ISpyConfig.h"
#import "ISpyViewTreeScanner.h"

#import "UIView+ISpyPlaceHolder.h"
#import <RATreeView.h>

static const CGFloat kISpySectionFontSize = 16;

@interface ISpyTreeView () </*UISearchBarDelegate,*/ RATreeViewDataSource, RATreeViewDelegate, UITableViewDataSource, UITableViewDelegate, ISpyPropTableViewCellDelegate>

//@property (strong, nonatomic) UISearchBar *searchBar;
//@property (assign, nonatomic) BOOL isSearching;

@property (strong, nonatomic) RATreeView *treeView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *allResults;

@property (strong, nonatomic) UITableView *propTableView;
@property (strong, nonatomic) NSDictionary *currentItem;
@property (strong, nonatomic) NSArray *currentItemProps;

@end

@implementation ISpyTreeView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit {
    self.tag = kISpyViewTag;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth
                            | UIViewAutoresizingFlexibleHeight
                            | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat yOffset = 4;
    CGFloat width = self.bounds.size.width;
    // SearchBar
    CGFloat height = 40;
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width - 60, 40)];
//    self.searchBar.delegate = self;
//    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
////    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor whiteColor]];
//    [self.searchBar setBarTintColor:[UIColor blackColor]];
//    [self addSubview:self.searchBar];
//    
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelButton setTitleColor:[ISpyViewConfig defaultConfig].textNormalColor forState:UIControlStateNormal];
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(onCancelSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:cancelButton];
//    yOffset += height;
    
    // TableView
    height = (self.bounds.size.height - yOffset) / 2;
    self.propTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, width, height) style:UITableViewStylePlain];
    self.propTableView.autoresizingMask = self.autoresizingMask;
    self.propTableView.dataSource = self;
    self.propTableView.delegate = self;
    self.propTableView.tableFooterView = [UIView new];
    self.propTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.propTableView];
    yOffset += height;
    
    // Line
    height = 20;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, width, height)];
    lineView.backgroundColor = [ISpyViewConfig defaultConfig].backgroundColor;
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleTopMargin
                                | UIViewAutoresizingFlexibleBottomMargin;
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width - 20, height)];
    lineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineLabel.backgroundColor = [UIColor clearColor];
    lineLabel.textColor = [ISpyViewConfig defaultConfig].textHighlightColor;
    lineLabel.font = [UIFont systemFontOfSize:kISpySectionFontSize];
    lineLabel.text = @"All Window Views";
    [lineView addSubview:lineLabel];
    [self addSubview:lineView];
    yOffset += height;
    
    // TreeView
    height = self.bounds.size.height - yOffset;
    self.treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, yOffset, width, height)];
    self.treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleTopMargin;;
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    
    self.treeView.treeFooterView = [UIView new];
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(onRefreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.treeView.scrollView addSubview:self.refreshControl];
    [self addSubview:self.treeView];
    
    [self refresh];
}

#pragma mark - RATreeViewDataSource

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        return [self.allResults count];
    }
    
    return [[ISpyViewTreeScanner subviewsForProperties:item] count];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item {
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [[ISpyViewTreeScanner subviewsForProperties:item] count];
//    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    
    static NSString *treeCellID = @"ISpyTreeViewCell";
    ISpyTreeViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:treeCellID];
    if (!cell) {
        cell = [[ISpyTreeViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:treeCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *prefix = numberOfChildren ? @"-" : @"*";
    [cell configWithTitle:[NSString stringWithFormat:@"%@ %@", prefix, [ISpyViewTreeScanner classNameForProperties:item]]
                   detail:[NSString stringWithFormat:@"%ld subview%@, id: %ld", (long)numberOfChildren, numberOfChildren > 1 ? @"s" : @"", [ISpyViewTreeScanner idForProperties:item]]
                    level:level];

    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return [self.allResults objectAtIndex:index];
    }
    
    return [[ISpyViewTreeScanner subviewsForProperties:item] objectAtIndex:index];//NSDictionary
}

#pragma mark - RATreeViewDelegate

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    return 44;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    UIView *view = [ISpyViewTreeScanner viewForProperties:item];
    if (view) {
        [view is_highlightBorder];
    }
    
    [self updatePropsWithItem:item];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currentItemProps.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSDictionary *props = [self.currentItemProps objectAtIndex:section];
//    return props[kISpyViewPropKeyName];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *props = [self.currentItemProps objectAtIndex:section];
    return [props[kISpyViewPropKeyProps] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * cellID = @"ISpyPropTableViewCell";
    ISpyPropTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[ISpyPropTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    NSDictionary *props = [self.currentItemProps objectAtIndex:indexPath.section];
    NSArray *list = props[kISpyViewPropKeyProps];
    NSDictionary *prop = [list objectAtIndex:indexPath.row];
    [cell configWithProps:prop];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * cellID = @"ISpyPropTableViewCellSection";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if (headerView == nil) {
        [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:cellID];
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    }
    if (!headerView.backgroundView) {
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [ISpyViewConfig defaultConfig].backgroundColor;
        headerView.backgroundView = backView;
    }
    
    UILabel *titleLabel = (UILabel *)[headerView.contentView viewWithTag:1];
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width, 20)];
        titleLabel.tag = 1;
        titleLabel.textColor = [ISpyViewConfig defaultConfig].textHighlightColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:kISpySectionFontSize];
        [headerView.contentView addSubview:titleLabel];
    }
    
    NSDictionary *props = [self.currentItemProps objectAtIndex:section];
    titleLabel.text = props[kISpyViewPropKeyName];
    
    return headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

#pragma mark - ISpyPropTableViewCellDelegate

- (void)ispyPropTableViewCell:(ISpyPropTableViewCell *)cell didChangeValue:(NSString *)value {
    //TODO:
    UIView *view = [ISpyViewTreeScanner viewForProperties:self.currentItem];
    if (view) {
        NSValue *newValue = [ISpyViewTreeScanner valueWithType:cell.props[kISpyViewPropValueKeyType] valueString:value];
        if (newValue) {
            @try {
                [view setValue:newValue forKey:cell.props[kISpyViewPropValueKeyName]];
            }
            @catch (NSException *exception) {
                
            }
        }
    }
}

//#pragma mark - UISearchBarDelegate
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self endEditing:YES];
//    self.isSearching = YES;
//    [self loadResults];
//}

#pragma mark - Action

- (void)onRefreshControlChanged:(id)sender {
    [self refresh];
}

//- (void)onCancelSearchButtonClicked:(id)sender {
//    [self endEditing:YES];
//    self.searchBar.text = @"";
//    self.isSearching = NO;
//    [self loadResults];
//}

#pragma mark - Helpers

- (void)refresh {
    [self loadResults];
    [self.refreshControl endRefreshing];
    [self.treeView reloadData];
    
    // Load first view's props
    NSDictionary *item = self.allResults.count ? self.allResults[0] : nil;
    [self.treeView selectRowForItem:item animated:NO scrollPosition:RATreeViewScrollPositionNone];
    [self updatePropsWithItem:item];
}

- (void)loadResults {
    self.allResults = [ISpyViewTreeScanner allWindowViewProperties];
}

- (void)updatePropsWithItem:(NSDictionary *)item {
    self.currentItem = item;
    self.currentItemProps = item ? [ISpyViewTreeScanner propsForProperties:item] : nil;
    [self.propTableView reloadData];
}

@end
