//
//  LYViewController.m
//  LYSegmentBar
//
//  Created by yqzhouluyao@gmail.com on 11/03/2022.
//  Copyright (c) 2022 yqzhouluyao@gmail.com. All rights reserved.
//

#import "LYViewController.h"
#import <LYSegmentBar/LYSegmentBar.h>
#import <LYSegmentBar/UIView+LYLayout.h>


@interface LYViewController ()<UIScrollViewDelegate, LYSegmentBarDelegate>
@property (nonatomic, strong) LYSegmentBar *segmentBar;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 1. 设置菜单栏
    [self.view addSubview:self.segmentBar];
    
    // 2. 添加内容视图
    [self.view addSubview:self.contentScrollView];


    // 3. 设置数据
    NSArray *items = @[@"相声评书",@"广播剧",@"个人成长",@"相声评书",@"儿童",@"历史",@"情感生活",@"历史",@"外语"];
    [self setUpWithItems:items];
    
}

- (void)setUpWithItems: (NSArray <NSString *>*)items {

    // 0.添加子控制器
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    for (int i = 0; i < items.count; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(255.0))/255.0 green:(arc4random_uniform(255.0))/255.0 blue:(arc4random_uniform(255.0))/255.0 alpha:1];
        [self addChildViewController:vc];
    }

    // 1. 设置菜单项展示
    self.segmentBar.segmentItems = items;

    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.width * items.count, 0);

    self.segmentBar.selectedIndex = 0;
}


#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.width;
    self.segmentBar.selectedIndex = page;
}


#pragma mark - LYSegmentBarDelegate
- (void)segmentBarClickSelectedIndex: (NSInteger)selectedIndex fromIndex: (NSInteger)fromIndex {
    [self showControllerView:selectedIndex];
}

- (void)showControllerView:(NSInteger)index {
    UIViewController *cvc = self.childViewControllers[index];
    UIView *view = cvc.view;
    CGFloat contentViewW = self.contentScrollView.width;
    view.frame = CGRectMake(contentViewW * index, 0, contentViewW, self.contentScrollView.height);
    [self.contentScrollView addSubview:view];
    [self.contentScrollView setContentOffset:CGPointMake(contentViewW * index, 0) animated:YES];
}


#pragma mark - getter
-(LYSegmentBar *)segmentBar
{
    if (!_segmentBar) {
        LYSegmentBarConfig *config = [LYSegmentBarConfig defaultConfig];
        config.isShowMore = YES;
        _segmentBar = [LYSegmentBar segmentBarWithConfig:config];
        _segmentBar.y = 64;
        _segmentBar.backgroundColor = [UIColor whiteColor];
        _segmentBar.delegate = self;
    }
    return _segmentBar;
}

-(UIScrollView *)contentScrollView
{
    if (!_contentScrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + self.segmentBar.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - (64 + self.segmentBar.height))];
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.contentSize = CGSizeMake(scrollView.width * self.childViewControllers.count, 0);
        _contentScrollView = scrollView;
    }
    return _contentScrollView;
}



@end
