//
//  LYSegmentBar.m
//  LYSegmentBar_Example
//
//  Created by zhouluyao on 2022/11/3.
//  Copyright © 2022 LYSegmentBar. All rights reserved.
//

#import "LYSegmentBar.h"
#import "LYDropDownMenuListController.h"
#import "UIView+LYLayout.h"
#import "LYSegmentModelProtocol.h"

@interface LYDropDownButton : UIButton
@property (nonatomic, assign) CGFloat radio;
@end

@implementation LYDropDownButton

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

-(CGFloat)radio {
    return 0.7;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{

    return CGRectMake(0, 0, contentRect.size.width * self.radio, contentRect.size.height);

}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(contentRect.size.width * self.radio, 0, contentRect.size.width * ( 1 - self.radio - 0.2), contentRect.size.height);
    
}
@end

@interface LYSegmentBar ()<UICollectionViewDelegate>

/** 用于放按钮列表*/
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) UIView *indicatorView;

/** 用于SegmentBar Item的数组 */
@property (nonatomic, strong) NSMutableArray <UIButton *>*segmentBarButtons;

/** 用于记录上次选项 */
@property (nonatomic, weak) UIButton *lastBtn;

@property (nonatomic, strong) LYSegmentBarConfig *segmentConfig;

@property (nonatomic, strong) LYDropDownButton *dropDownBtn;
@property (nonatomic, nonnull, strong) UIView *coverView;
@property (nonatomic, strong) LYDropDownMenuListController *menuListController;

@end


@implementation LYSegmentBar

+ (instancetype)segmentBarWithConfig: (LYSegmentBarConfig *)config {

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect defaultFrame = CGRectMake(0, 0, width, 40);
    LYSegmentBar *segmentBar = [[LYSegmentBar alloc] initWithFrame:defaultFrame];
    segmentBar.segmentConfig = config;
    return segmentBar;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.segmentConfig = [LYSegmentBarConfig defaultConfig];
    }
    return self;
}

/**
 *  监听选项卡配置的改变
 *
 *  @param segmentConfig 选项卡配置模型
 */
- (void)updateSegmentBarWithConfig: (void(^)(LYSegmentBarConfig *config))configBlock
{
    if (configBlock != nil) {
        configBlock(self.segmentConfig);
    }
    self.segmentConfig = self.segmentConfig;

}
-(void)setSegmentConfig:(LYSegmentBarConfig *)segmentConfig
{
    _segmentConfig = segmentConfig;

    // 指示器颜色
    self.indicatorView.backgroundColor
    = segmentConfig.indicatorColor;
    self.indicatorView.height = segmentConfig.indicatorHeight;
    
    // 选项颜色/字体
    for (UIButton *btn in self.segmentBarButtons) {
        [btn setTitleColor:segmentConfig.segNormalColor forState:UIControlStateNormal];
        if (btn != self.lastBtn) {
            btn.titleLabel.font = segmentConfig.segNormalFont;
        }else {
            btn.titleLabel.font = segmentConfig.segSelectedFont;
        }
        [btn setTitleColor:segmentConfig.segSelectedColor forState:UIControlStateSelected];
    }

    // 最小间距
    [self layoutIfNeeded];
    [self layoutSubviews];

}
/**
 *  根据配置, 更新视图
 */
- (void)updateViewWithConfig {
    self.segmentConfig = self.segmentConfig;
}

/**
 *  监听选项卡数据源的改变
 *
 *  @param segmentItems 选项卡数据源
 */
-(void)setSegmentItems:(NSArray<id<LYSegmentModelProtocol>> *)segmentItems
{
    _segmentItems = segmentItems;

    if (self.segmentConfig.isShowMore) {
        self.menuListController.items = _segmentItems;
        self.menuListController.collectionView.height = 0;
    }

    // 移除之前所有的子控件
    [self.segmentBarButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.segmentBarButtons = nil;
    self.lastBtn = nil;
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;

    // 添加最新的子控件
    for (NSString *title in segmentItems) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = self.segmentBarButtons.count;
        [btn addTarget:self action:@selector(segClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = self.segmentConfig.segNormalFont;
        [btn setTitleColor:self.segmentConfig.segNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.segmentConfig.segSelectedColor forState:UIControlStateSelected];
        [btn setTitle:title forState:UIControlStateNormal];
        [self.contentScrollView addSubview:btn];
        [btn sizeToFit];

        // 保存到一个数组中
        [self.segmentBarButtons addObject:btn];

    }
    // 重新布局
    [self layoutIfNeeded];
    [self layoutSubviews];


    // 默认选中第一个选项卡
    [self segClick:[self.segmentBarButtons firstObject]];

}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;

    for (UIButton *btn in self.segmentBarButtons) {
        if (btn.tag == selectedIndex) {
            [self segClick:btn];
            break;
        }
    }

}


/**
 *  点击某个选项卡调用的事件
 */
- (void)segClick: (UIButton *)btn {

    // 通知代理
    if ([self.delegate respondsToSelector:@selector(segmentBarClickSelectedIndex:fromIndex:)])
    {
        _selectedIndex = btn.tag;
        [self.delegate segmentBarClickSelectedIndex:_selectedIndex fromIndex:self.lastBtn.tag];
    }

    // 修改状态
    self.lastBtn.selected = NO;
    self.lastBtn.titleLabel.font = self.segmentConfig.segNormalFont;
    [self.lastBtn sizeToFit];
    self.lastBtn.height = self.contentScrollView.height - self.segmentConfig.indicatorHeight;

    btn.selected = YES;
    btn.titleLabel.font = self.segmentConfig.segSelectedFont;
    [btn sizeToFit];
    btn.height = self.contentScrollView.height - self.segmentConfig.indicatorHeight;
    self.lastBtn = btn;

    if (self.segmentConfig.isShowMore) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.lastBtn.tag inSection:0];
        [self.menuListController.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [self hideDetailPane];
    }


    // 移动指示器位置
    [UIView animateWithDuration:0.2 animations:^{

        // 控制宽度, 和中心
        NSString *text = btn.titleLabel.text;
        NSDictionary *fontDic = @{
                                  NSFontAttributeName : btn.titleLabel.font
                                  };
        CGSize size = [text sizeWithAttributes:fontDic];
        self.indicatorView.y = self.contentScrollView.height - self.segmentConfig.indicatorHeight;
        self.indicatorView.width = size.width + self.segmentConfig.indicatorExtraWidth;
        self.indicatorView.centerX = btn.centerX;

    }];


    // 自动滚动到中间位置
    CGFloat shouldScrollX = btn.centerX - self.contentScrollView.width * 0.5;

    if (shouldScrollX < 0) {
        shouldScrollX = 0;
    }

    if (shouldScrollX > self.contentScrollView.contentSize.width - self.contentScrollView.width) {
        shouldScrollX = self.contentScrollView.contentSize.width - self.contentScrollView.width;
    }

    [self.contentScrollView setContentOffset:CGPointMake(shouldScrollX, 0) animated:YES];
    


}

- (void)showOrHide: (UIButton *)btn {

    btn.selected = !btn.selected;
    if (btn.selected) {
        [self showDetailPane];
    }else {
        [self hideDetailPane];
    }
    
}

- (void)showDetailPane {

    self.dropDownBtn.selected = YES;
    self.menuListController.collectionView.hidden = NO;
    self.coverView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.menuListController.collectionView.height = self.menuListController.expectedHeight;
        self.coverView.height = [UIScreen mainScreen].bounds.size.height;
    }];
    
}

- (void)hideDetailPane {
    self.dropDownBtn.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.menuListController.collectionView.height = 0;
        self.coverView.height = 0;
    } completion:^(BOOL finished) {
        self.coverView.hidden = YES;
        self.menuListController.collectionView.hidden = YES;
    }];
}



-(void)layoutSubviews {
    [super layoutSubviews];

    self.contentScrollView.frame = self.bounds;

    if (!self.segmentConfig.isShowMore) {
        self.contentScrollView.frame = self.bounds;
        self.dropDownBtn.width = -1;
    }else {
        self.contentScrollView.frame = CGRectMake(0, 0, self.width - (self.bounds.size.height + 30), self.height);
        self.dropDownBtn.frame = CGRectMake(self.width - (self.bounds.size.height + 30), 0, (self.bounds.size.height + 30), self.height);
    }


    // 1. 计算间距
    CGFloat titleTotalW = 0;
    for (int i = 0; i < self.segmentBarButtons.count; i++)  {
        [self.segmentBarButtons[i] sizeToFit];
        CGFloat width = self.segmentBarButtons[i].width;
        titleTotalW += width;
    }

    CGFloat margin = (self.contentScrollView.width - titleTotalW) / (self.segmentItems.count + 1);
    margin = margin < self.segmentConfig.limitMargin ? self.segmentConfig.limitMargin : margin;


    // 布局topmMenue 内部控件
    CGFloat btnY = 0;

    CGFloat btnHeight = self.contentScrollView.height - self.segmentConfig.indicatorHeight;
    UIButton *lastBtn;
    for (int i = 0; i < self.segmentBarButtons.count; i++) {

        // 计算每个控件的宽度
        CGFloat btnX = CGRectGetMaxX(lastBtn.frame) + margin;
        self.segmentBarButtons[i].x = btnX;
        self.segmentBarButtons[i].y = btnY;
        self.segmentBarButtons[i].height = btnHeight;

        lastBtn = self.segmentBarButtons[i];

    }
    self.contentScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastBtn.frame) + margin, 0);


    // 修正指示器的位置, 控制宽度, 和中心
    if (self.lastBtn) {
        NSString *text = self.lastBtn.titleLabel.text;
        NSDictionary *fontDic = @{
                                  NSFontAttributeName : self.lastBtn.titleLabel.font
                                  };
        CGSize size = [text sizeWithAttributes:fontDic];
        self.indicatorView.y = self.contentScrollView.height - self.segmentConfig.indicatorHeight;
        self.indicatorView.width = size.width + self.segmentConfig.indicatorExtraWidth;
        self.indicatorView.centerX = self.lastBtn.centerX;
    }


}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self hideDetailPane];

}


#pragma mark -getter
- (LYDropDownMenuListController *)menuListController {
    if (!_menuListController) {
        _menuListController = [[LYDropDownMenuListController alloc] init];
        _menuListController.collectionView.delegate = self;
    }
    if (_menuListController.collectionView.superview != self.superview) {
        _menuListController.collectionView.frame = CGRectMake(0, self.y + self.height, self.width, 0);
        [self.superview addSubview:_menuListController.collectionView];
    }

    return _menuListController;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y + self.height, self.width, 0)];
        _coverView.backgroundColor = [UIColor colorWithRed:55 / 255.0 green:55 / 255.0 blue:55 / 255.0 alpha:0.4];
        UITapGestureRecognizer *gester = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailPane)];
        [_coverView addGestureRecognizer:gester];
    }
    if (!_coverView.superview) {
        [self.superview insertSubview:_coverView belowSubview:self.menuListController.collectionView];
    }
    return _coverView;
}

- (LYDropDownButton *)dropDownBtn
{
    if (!_dropDownBtn) {

        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSString *sourcePath = [currentBundle.infoDictionary[@"CFBundleName"] stringByAppendingString:@".bundle"];
        NSString *showImgPath = [currentBundle pathForResource:@"icon_radio_show@2x" ofType:@".png" inDirectory:sourcePath];
        UIImage *showImage = [UIImage imageWithContentsOfFile:showImgPath];

        NSString *hideImgPath = [currentBundle pathForResource:@"icon_radio_hide@2x" ofType:@".png" inDirectory:sourcePath];
        UIImage *hideImage = [UIImage imageWithContentsOfFile:hideImgPath];
        
        _dropDownBtn = [[LYDropDownButton alloc] init];
        [_dropDownBtn setTitle:@"更多" forState:UIControlStateNormal];
        [_dropDownBtn setImage:showImage forState:UIControlStateNormal];
        [_dropDownBtn setTitle:@"收起" forState:UIControlStateSelected];
        [_dropDownBtn setImage:hideImage forState:UIControlStateSelected];
        _dropDownBtn.imageView.contentMode = UIViewContentModeCenter;
        [_dropDownBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //        _dropDownBtn.backgroundColor = [UIColor greenColor];
        _dropDownBtn.titleLabel.font = [UIFont systemFontOfSize:13];

        // 添加分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 1, 20)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_dropDownBtn addSubview:line];


        [_dropDownBtn addTarget:self action:@selector(showOrHide:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_dropDownBtn];
    }
    return _dropDownBtn;
}

#pragma mark - 懒加载属性
/** 用于显示内容选项卡的视图 */
- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_contentScrollView];
    }
    return _contentScrollView;
}


/** 用于标识选项卡的指示器 */
- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - self.segmentConfig.indicatorHeight, 0, self.segmentConfig.indicatorHeight)];
        _indicatorView.backgroundColor = self.segmentConfig.indicatorColor;
        [self.contentScrollView addSubview:_indicatorView];
    }
    return _indicatorView;
}

/** 用于存储选项卡的数组 */
- (NSMutableArray<UIButton *> *)segmentBarButtons
{
    if (!_segmentBarButtons) {
        _segmentBarButtons = [NSMutableArray array];
    }
    return _segmentBarButtons;
}


@end
