//
//  LYDropDownMenuListController.h
//  LYSegmentBar_Example
//
//  Created by zhouluyao on 2022/11/3.
//  Copyright © 2022 LYSegmentBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYSegmentModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface LYDropDownMenuListController : UICollectionViewController

@property (nonatomic, assign) CGFloat expectedHeight;

@property (nonatomic, strong) NSArray <id<LYSegmentModelProtocol>>*items;

@end

NS_ASSUME_NONNULL_END
