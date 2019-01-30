//
//  DDTableviewIndex.h
//
//  Created by dong on 2019/1/28.
//  Copyright © 2019 d. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIndexViewMode.h"

@class DDTableviewIndex;

@protocol DDIndexViewDelegate <NSObject>

@optional
/**
 当点击或者滑动索引视图时，回调这个方法
 
 @param indexView 索引视图
 @param section   索引位置
 */
- (void)indexView:(DDTableviewIndex *)indexView didSelectAtSection:(NSUInteger)section;

@end

typedef void(^DD_SelectAtSection)(NSInteger currentSection);

@interface DDTableviewIndex : UIControl
@property (nonatomic, assign)NSInteger currentSection;
@property (nonatomic, weak) id<DDIndexViewDelegate> delegate;

- (void)setupNeedData:(NSDictionary *)data withBlock:(DD_SelectAtSection)block;
- (void)configSubLayersAndSubviews;
- (void)configCurrentSection:(NSInteger)index;
@end
