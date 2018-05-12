//
//  CSScrollControlsView.m
//  CSScrollController
//
//  Created by work on 2018/5/12.
//  Copyright © 2018年 work. All rights reserved.
//

#import "CSScrollControlsView.h"

@interface CSScrollControlsView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UIView *topView;/** topView */
@property (nonatomic, strong) UIScrollView* topScrollView;
@property (nonatomic, weak)   UIButton *selectedButton;
@property (nonatomic, weak)   UIView *indicator;
@property (nonatomic, strong) NSMutableArray<UIButton*> *titleButtons;/** 所有按钮 */
@property (nonatomic, strong) NSMutableArray<UIViewController*> *controllers;/** 所有控制器 */
@property(nonatomic,strong)UICollectionView* collection; /** 所有控制器的展示 */
@end
@implementation CSScrollControlsView
#pragma mark - life
- (void)awakeFromNib{
    [super awakeFromNib];
    [self Initlization];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self Initlization];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
     [self addSubview:self.topView];
     [self addSubview:self.collection];
     [self setupSubView];
}
#pragma mark - event
//按钮点击事件
-(void)btnClick:(UIButton*)sender{

    NSInteger idx = [self.titleButtons indexOfObject:sender];
    if (sender == self.selectedButton) {
        NSLog(@"重复点击了按钮");
        return;
    }
    //选中按钮
    [self selectButton:sender];
    
    //切换内容
    [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

//选中按钮
-(void)selectButton:(UIButton*)sender{
    
    //按钮切换
    self.selectedButton.selected = NO;
    sender.selected = YES;
    self.selectedButton = sender;
    
    // 移动下划线
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sframe = self.indicator.frame;
        sframe.origin.x = sender.center.x - 0.5 * sframe.size.width;
        self.indicator.frame = sframe;
    }];

    //topScrollView 滚动
    [self scrollToItemAtIndex:[self.titleButtons indexOfObject:sender]];
}
#pragma mark - delegate
#pragma mark ----------- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.controllers.count;
}
// 每次只要有新的cell出现就会调用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    
    // 移除之前子控制器的View
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 切换子控制器View
    UIViewController* vc = [self.controllers objectAtIndex:indexPath.row];
    // 控制器View尺寸一开始就不对
    vc.view.frame = cell.contentView.frame;
    [cell.contentView addSubview:vc.view];
    
    return cell;
}
#pragma mark ----------- UIScrollViewDelegate

// 滚动完成的时候调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        NSInteger page = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
        [self selectButton:[self.titleButtons objectAtIndex:page]];
    }
}
#pragma mark - private
-(void)Initlization{
    _space = 10;
    _scrollItemHeight = 40;
    _normalColor = [UIColor colorWithRed:73/256.0 green:73/256.0 blue:73/256.0 alpha:1.0];
    _selectColor = [UIColor colorWithRed:0 green:202/256.0 blue:183/256.0 alpha:1.0];
    _titleFont   = [UIFont systemFontOfSize:14];
    _tintColor   = [UIColor whiteColor];
    _canScroll   = YES;
}
//所在控制器
-(UIViewController*)viewController{
    UIView* view = self.superview;
    while (view) {
        if ([[view nextResponder] isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)[view nextResponder];
        }
        view = view.superview;
    }
    return nil;
}
-(UIButton*)setScrollButton:(NSString*)title{
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    [sender setTitleColor:_normalColor forState:UIControlStateNormal];
    [sender setTitleColor:_selectColor forState:UIControlStateSelected];
    [sender setTitle:title forState:UIControlStateNormal];
    sender.titleLabel.font = _titleFont;
    [sender addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return sender;
}

// 文本的宽度
- (CGFloat)widthForText:(NSString*)aString{
    return [aString sizeWithAttributes:@{NSFontAttributeName:self.titleFont}].width;
}
// 滚动头部的item
-(void)scrollToItemAtIndex:(NSUInteger)index{
    //不够一屏
    if (self.topScrollView.bounds.size.width >= self.topScrollView.contentSize.width) {
        return;
    }
    
    CGFloat centerX  = [self.titleButtons objectAtIndex:index].center.x;
    CGFloat minX = self.topScrollView.bounds.size.width * 0.5;
    CGFloat maxX = self.topScrollView.contentSize.width - minX;
    if (centerX < minX) {
        self.topScrollView.contentOffset = CGPointMake(0, 0);
    }else if(centerX > maxX){
        self.topScrollView.contentOffset = CGPointMake(maxX - minX, 0);
    }else{
        self.topScrollView.contentOffset = CGPointMake(centerX - minX, 0);
    }
}

#pragma mark - setup
-(void)setupSubView{
    // !!!: 没有数据源，直接返回
    if (self.dataSource == nil) return;
    
    // !!!: 判断之前是否添加过,添加过就不添加了
    if (self.titleButtons.count) return;
    
    // !!!: 代理的实现
    if (![self.dataSource respondsToSelector:@selector(controlOfScrollControlsView:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"未实现(controlOfScrollControlsView:)" userInfo:nil];
    }

    //保存控制器
    [self.controllers removeAllObjects];
    [self.controllers addObjectsFromArray:[self.dataSource controlOfScrollControlsView:self]];
    
    //创建头部滚动按钮
  
    for (NSUInteger idx = 0; idx < self.controllers.count; idx ++) {
        UIViewController* controll = [self.controllers objectAtIndex:idx];
        
        NSString* title = [controll valueForKeyPath:@"_title"];
        NSAssert(title.length != 0, @"Could not set title of [%@]", NSStringFromClass([controll class]));
        UIButton* btn = [self setScrollButton:title];
        
        [self.topScrollView addSubview:btn];
        [self.titleButtons addObject:btn];
        
        if (idx == 0) {
            //默认选中第一个按钮
            [self btnClick:btn];
        }
    }
    //按钮布局
    [self layoutTitles];
    
    [self.collection reloadData];
}
- (void)layoutTitles{
    CGFloat  startX = self.space;
    for (NSUInteger idx = 0; idx < self.titleButtons.count; idx ++) {
        UIButton* btn = self.titleButtons[idx];
        CGFloat w = [self widthForText:btn.currentTitle] + 20;
        btn.frame = CGRectMake(startX, 0, w , self.scrollItemHeight);
        startX += w + self.space;
    }
    //更新topScrollView的可视区
    _topScrollView.contentSize = CGSizeMake(startX, self.topScrollView.bounds.size.height);
}

#pragma mark - setter & getter
- (void)setDataSource:(id<CSScrollControlsViewDataSource>)dataSource{
    _dataSource = dataSource;
}

- (void)setSpace:(CGFloat)space{
    _space = space;
    [self layoutIfNeeded];
}
- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    [self setNeedsDisplay];
}
- (void)setSelectColor:(UIColor *)selectColor{
    _selectColor = selectColor;
    [self setNeedsDisplay];
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    [self setNeedsDisplay];
}
- (void)setScrollItemHeight:(CGFloat)scrollItemHeight{
    _scrollItemHeight = scrollItemHeight;
    [self layoutIfNeeded];
}
- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    [self layoutIfNeeded];
}

#pragma mark ------ lazyloading
- (NSMutableArray<UIViewController*> *)controllers{
    if (!_controllers) {
        _controllers = [[NSMutableArray alloc]init];
    }
    return _controllers;
}
- (NSMutableArray<UIButton*>*)titleButtons{
    if (!_titleButtons) {
        _titleButtons = [[NSMutableArray alloc]init];
    }
    return _titleButtons;
}
- (UICollectionView *)collection{
    if (!_collection) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - self.scrollItemHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        // UICollectionView
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.scrollItemHeight, layout.itemSize.width, layout.itemSize.height) collectionViewLayout:layout];
        _collection.dataSource = self;
        _collection.delegate = self;
        [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        _collection.backgroundColor = [UIColor lightGrayColor];
        _collection.scrollsToTop = NO;
        _collection.showsVerticalScrollIndicator = NO;
        _collection.showsHorizontalScrollIndicator = NO;
        _collection.bounces = NO;
        _collection.pagingEnabled = YES;
        _collection.scrollEnabled = _canScroll;
    }
    return _collection;
}
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.scrollItemHeight)];
        _topView.backgroundColor = self.tintColor;
        [_topView addSubview:self.topScrollView];
    }
    return _topView;
}
- (UIScrollView *)topScrollView{
    if (!_topScrollView) {
        _topScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.scrollItemHeight)];
        _topScrollView.delegate = self;
        _topScrollView.showsVerticalScrollIndicator = NO;
        _topScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _topScrollView;
}
#pragma mark - networking
@end
