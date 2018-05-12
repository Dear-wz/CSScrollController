//
//  ViewController.m
//  CSScrollController
//
//  Created by work on 2018/5/12.
//  Copyright © 2018年 work. All rights reserved.
//

#import "ViewController.h"
#import "CSScrollControlsView.h"
@interface ViewController ()<CSScrollControlsViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self addChildViewControllerWithTitle:@"child1"];
    [self addChildViewControllerWithTitle:@"child2"];
    [self addChildViewControllerWithTitle:@"child3"];
    [self addChildViewControllerWithTitle:@"child4"];
    [self addChildViewControllerWithTitle:@"child5"];
    [self addChildViewControllerWithTitle:@"child6"];
    [self addChildViewControllerWithTitle:@"child7"];
    [self addChildViewControllerWithTitle:@"child8"];
    [self addChildViewControllerWithTitle:@"child9"];
    [self addChildViewControllerWithTitle:@"child10"];

 
    CSScrollControlsView* scrollControl = [[CSScrollControlsView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20)];
    scrollControl.dataSource = self;
    [self.view addSubview:scrollControl];
    
    
}
-(void)addChildViewControllerWithTitle:(NSString*)title{
    UIViewController* child = [[UIViewController alloc]init];
    child.title = title;
    child.view.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1.0];
    [self addChildViewController:child];
}
#pragma mark - CSScrollControlsViewDataSource
- (NSArray<UIViewController*>*)controlOfScrollControlsView:(CSScrollControlsView *)scrollControlsView{
    return self.childViewControllers;
}
@end
