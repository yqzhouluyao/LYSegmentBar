//
//  LYDropDownMenuListController.m
//  LYSegmentBar_Example
//
//  Created by zhouluyao on 2022/11/3.
//  Copyright © 2022 LYSegmentBar. All rights reserved.
//

#import "LYDropDownMenuListController.h"
#import "UIView+LYLayout.h"
#import "LYSegmentModelProtocol.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kColumnCount 3
#define kMargin 6
#define kCellH 30


@interface LYMenuCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *menuLabel;

@end

@implementation LYMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _menuLabel = [UILabel new];
        _menuLabel.frame = self.bounds;
        _menuLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_menuLabel];
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected) {
        self.backgroundColor = [UIColor redColor];
    }else {
        self.backgroundColor = [UIColor colorWithRed:160 / 255.0 green:160 / 255.0 blue:160 / 255.0 alpha:0.4];
    }
}

@end


@interface LYDropDownMenuListController ()

@end

@implementation LYDropDownMenuListController

-(void)setItems:(NSArray<id<LYSegmentModelProtocol>> *)items
{

    _items = items;

    NSInteger rows = (_items.count + (kColumnCount - 1)) / kColumnCount;
    CGFloat height = rows * (kCellH + kMargin);
    self.collectionView.height = height;
    self.expectedHeight = height;
    [self.collectionView reloadData];
}


-(instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (kScreenWidth - kMargin * (kColumnCount + 1)) / kColumnCount;
    CGFloat height = kCellH;
    flowLayout.itemSize = CGSizeMake(width, height);
    flowLayout.minimumLineSpacing = kMargin;
    flowLayout.minimumInteritemSpacing = kMargin;

    return [super initWithCollectionViewLayout:flowLayout];

}
-(instancetype)init
{
    return [self initWithCollectionViewLayout:[UICollectionViewLayout new]];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[LYMenuCell class] forCellWithReuseIdentifier:NSStringFromClass([LYMenuCell class])];
    self.collectionView.backgroundColor = [UIColor whiteColor];

}



#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    LYMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LYMenuCell class]) forIndexPath:indexPath];
    cell.selected = NO;
    cell.menuLabel.text = (NSString *)self.items[indexPath.row];
    
    return cell;
}

@end
