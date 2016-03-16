//
//  MovieListViewController.m
//  iSpyDemo
//
//  Created by lslin on 15/12/3.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "MovieListViewController.h"
#import "UIView+ISpyLayer.h"
#import "MovieDetailViewController.h"

@interface MovieListViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end


@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.startButton is_setRoundCorner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)onStartButtonClicked:(id)sender {
    MovieDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
