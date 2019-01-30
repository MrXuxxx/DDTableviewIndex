//
//  UITableView+DDCoustomIndexView.m
//
//  Created by dong on 2019/1/29.
//  Copyright © 2019 d. All rights reserved.
//

#import "UITableView+DDCoustomIndexView.h"
#import <objc/runtime.h>
#import "DDTableviewIndex.h"

@implementation UITableView (DDCoustomIndexView)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzledSelector:@selector(dd_layoutSubviews) originalSelector:@selector(layoutSubviews)];
    });
}
// 交换方法
+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
static NSInteger indexTag = 100001;
- (void)dd_layoutSubviews{
    if (self.dd_mode) {
        // 如果代理不响应设置index方法，就别浪费资源了
        if ([self judgeIndexTitles]) {
            UIView *needView = nil;
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
                    needView = subview;
                    // 使用tag值标记，避免每次循环浪费资源
                    needView.tag = indexTag;
                    // 把原索引隐藏一下，避免出现两个索引很尴尬。
                    needView.hidden = YES;
                    [self creatIndexView:needView.frame];
                }
            }
        }else if(self.dd_indexView){
            UIView *needView = [self viewWithTag:indexTag];
            self.dd_indexView.frame = needView.frame;
        }
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:self.contentOffset];
        [self.dd_indexView configCurrentSection:indexPath.section];
        [self dd_layoutSubviews];
        [self bringSubviewToFront:self.dd_indexView];
    }else{
        [self dd_layoutSubviews];
    }
   

}
- (void)creatIndexView:(CGRect)rect{
  
    // 判断如果代理实现，且代理与当前数据源相同，则不需要刷新
    if ([self judgeIndexTitles]) {
        if (!self.dd_indexView) {
            DDTableviewIndex *indexView = [[DDTableviewIndex alloc]init];
            [self setDd_indexViewDataSource:indexView];
        }
        self.dd_mode.model.cachedSize = rect.size;
        self.dd_mode.model.titles = [self.dataSource sectionIndexTitlesForTableView:self];
        UITableView * __weak weakSelf = self;
        [self.dd_indexView setupNeedData:[self.dd_mode dictionaryFromModel] withBlock:^(NSInteger currentSection) {
            [weakSelf scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:currentSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
        }];
        
        [self.dd_indexView configSubLayersAndSubviews];
    }

    self.dd_indexView.frame = rect;

}
// 判断和当前数据源是否相同
- (BOOL)judgeIndexTitles{
    if ([self.dataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)] && ![[self.dd_indexView valueForKey:@"titles"] isEqual:[self.dataSource sectionIndexTitlesForTableView:self]]) {
        return YES;
    }else{
        return NO;
    }
}
// 动态绑定indexview方法。
- (DDTableviewIndex *)dd_indexView
{
    return objc_getAssociatedObject(self, @selector(dd_indexView));
}
- (void)setDd_indexViewDataSource:(DDTableviewIndex *)dd_indexView
{
    if (self.dd_indexView == dd_indexView) return;
    
    [self addSubview:dd_indexView];
    [self bringSubviewToFront:dd_indexView];
    
    objc_setAssociatedObject(self, @selector(dd_indexView), dd_indexView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)addIndexViewStyleWithMode:(DDIndexViewMode *)mode{
    if (mode) {
        [self setDd_mode:mode];
    }else{
        // 如果模版不存在，就给一个默认模版
        DDIndexViewMode *mode = [[DDIndexViewMode alloc]initMakeIndexviewModel:^(DDIndexViewModel *make) {
            make.indexColor = [UIColor blackColor];
            make.indexBackgroundColor = [UIColor whiteColor];
            make.selectedColor = [UIColor whiteColor];
            make.selectedBackgroundColor = [UIColor blackColor];
        }];
        [self setDd_mode:mode];
    }
}
// 动态绑定indexview方法。
- (DDIndexViewMode *)dd_mode
{
    return objc_getAssociatedObject(self, @selector(dd_mode));
}
- (void)setDd_mode:(DDIndexViewMode *)dd_mode
{
    if (self.dd_mode == dd_mode) return;
    
    objc_setAssociatedObject(self, @selector(dd_mode), dd_mode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
