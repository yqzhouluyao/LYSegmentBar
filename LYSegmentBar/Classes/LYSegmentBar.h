//
//  LYSegmentBar.h
//  LYSegmentBar_Example
//
//  Created by zhouluyao on 2022/11/3.
//  Copyright © 2022 LYSegmentBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYSegmentBarConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LYSegmentBarDelegate <NSObject>

- (void)segmentBarClickSelectedIndex: (NSInteger)atIndex fromIndex: (NSInteger)fromIndex;

@end

@interface LYSegmentBar : UIView

+ (instancetype)segmentBarWithConfig: (LYSegmentBarConfig *)config;

//修改配置后，需要调用该方法生效
- (void)updateSegmentBarWithConfig: (void(^)(LYSegmentBarConfig *config))configBlock;

@property (nonatomic, strong) NSArray *segmentItems;


@property (nonatomic, weak) id<LYSegmentBarDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END
