//
//  DDIndexViewMode.h
//
//  Created by dong on 2019/1/28.
//  Copyright © 2019 d. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DDIndexViewModel : NSObject

@property(assign, nonatomic) NSInteger selectedSection;
@property(assign, nonatomic) BOOL pastTop;
@property(assign, nonatomic) BOOL pastBottom;
@property(assign, nonatomic) NSString* selectedSectionTitle;
@property(strong, nonatomic) UIFont* font;
@property(copy, nonatomic) NSArray<NSString *>* titles;
@property(nonatomic) CGSize cachedSize;
@property(copy, nonatomic)UIColor *indexColor;
@property(copy, nonatomic)UIColor *indexBackgroundColor;
@property(copy, nonatomic)UIColor *selectedColor;
@property(copy, nonatomic)UIColor *selectedBackgroundColor;
@end

typedef void(^DD_MakeIndexModel)(DDIndexViewModel *make);

@interface DDIndexViewMode : NSObject

- (instancetype)initMakeIndexviewModel:(DD_MakeIndexModel)block;
// 把初始化好的模型转化成字典，去model化
- (NSDictionary *)dictionaryFromModel;

@property (strong, nonatomic) DDIndexViewModel *model;
@property(assign, nonatomic, readonly)CGFloat topPadding;

@end
