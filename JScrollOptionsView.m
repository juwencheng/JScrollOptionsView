//
//  JScrollOptionsView.m
//  JScrollOptionsView
//
//  Created by Juwencheng on 2016/11/8.
//  Copyright © 2016年 scics. All rights reserved.
//

#import "JScrollOptionsView.h"

@interface JScrollOptionsView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *components;

@end

@implementation JScrollOptionsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.scrollView];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.components) {
        view.layer.cornerRadius = CGRectGetWidth(view.frame)/2;
    }
}

- (void)resetSelections {
    for (UIButton *view in self.components) {
        view.selected = NO;
        
        [self updateSelectedStyle:view];
    }
}

- (void)setupSubViewWithData:(NSArray *)data {
    if (data.count <= 0) {
        NSLog(@"传入数据不能为空");
        return;
    }
    
    UIView *preView;
    for (NSDictionary *item in data) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        // button 配置
        [button setTitle:item[@"title"] forState:UIControlStateNormal];
        [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
        [button setTitleColor:self.normalColor forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.borderColor = self.selectedColor.CGColor;
        button.layer.borderWidth = 1;
        button.selected = NO;
        [button addTarget:self action:@selector(tapView:) forControlEvents:UIControlEventTouchUpInside];
//        [button addTarget:self action:@selector(didSelectItem:) forControlEvents:UIControlEventTouchUpInside];
        // 添加到scrollView和数组中
        [self.scrollView addSubview:button];
        [self.components addObject:button];
        
        // 添加约束
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        if (preView) {
            [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:preView attribute:NSLayoutAttributeRight multiplier:1 constant:8]];
        }else {
            [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        }
        //强制刷新button，在父视图高度确定后可以正确的计算出自身的尺寸
        [button layoutIfNeeded];
        preView = button;
    }
    // 约束收尾
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:preView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)tapView:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self updateSelectedStyle:sender];
    [self didSelectItem:self.selectionsData];
}

- (void)updateSelectedStyle:(UIButton *)btn {
    if (btn.selected) {
        btn.backgroundColor = self.selectedColor;
    }else {
        btn.backgroundColor = self.normalColor;
    }
}

- (void)didSelectItem:(NSArray *)selectArray {
    if ([self.jScrollDelegate respondsToSelector:@selector(didSelectItem:)]){
        [self.jScrollDelegate didSelectItem:self.selectionsData];
    }
}

- (void)reLayout {
    // 删除所有子视图
    NSArray *subViews = self.scrollView.subviews;
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
    [self.components removeAllObjects];
    
    // 设置子视图
    [self setupSubViewWithData:self.data];
    
    // 强制刷新，会执行layouSubViews:方法
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (NSArray *)selectionsData {
    NSMutableArray *selected = [NSMutableArray array];
    for (NSInteger i = 0 , len = self.components.count; i < len; i++) {
        UIButton *btn = self.components[i];
        if (btn.selected) {
            [selected addObject:self.data[i]];
        }
    }
    return selected;
}

- (void)setSelectionsData:(NSArray *)selectionsData {
    for (id data in selectionsData) {
        NSInteger idx = [self.data indexOfObject:data];
        if (idx < self.components.count) {
            UIButton *btn = self.components[idx];
            btn.selected = YES;
            [self updateSelectedStyle:btn];
        }
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)components {
    if (!_components) {
        _components = [NSMutableArray array];
    }
    return _components;
}

@end
