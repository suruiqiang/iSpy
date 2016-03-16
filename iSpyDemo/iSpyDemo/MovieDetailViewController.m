//
//  MovieDetailViewController.m
//  iSpyDemo
//
//  Created by lslin on 15/12/3.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "MovieDetailViewController.h"

@interface MovieDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [NSMutableArray array];
    for (int i = 0; i < 10; ++ i) {
        [self.dataSource addObject:@"cat"];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MovieDetailCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell Index %d", (int)indexPath.row];
    
    return cell;
}

@end
