//
//  DDIndexViewMode.m
//
//  Created by dong on 2019/1/28.
//  Copyright © 2019 d. All rights reserved.
//

#import "DDIndexViewMode.h"
#import <objc/runtime.h>
@implementation DDIndexViewModel
- (NSInteger)selectedSection{
    if (_selectedSection) {
        return _selectedSection;
    }else{
        return 0;
    }
}
- (BOOL)pastTop{
    if (_pastTop) {
        return _pastTop;
    }else{
        return NO;
    }
}
-(BOOL)pastBottom{
    if (_pastBottom) {
        return _pastBottom;
    }else{
        return NO;
    }
}
- (NSString *)selectedSectionTitle{
    if (_selectedSectionTitle) {
        return _selectedSectionTitle;
    }else{
        if (_titles && _titles.count > 0) {
            return _titles.firstObject;
        }else{
            return @"";
        }
    }
   
}
- (UIFont *)font{
    if (_font) {
        return _font;
    }else{
        return [UIFont systemFontOfSize:15];
    }
}
- (UIColor *)indexColor{
    if (_indexColor) {
        return _indexColor;
    }else{
        return [UIColor blackColor];
    }
}
- (UIColor *)indexBackgroundColor{
    if (_indexBackgroundColor) {
        return _indexBackgroundColor;
    }else{
        return [UIColor whiteColor];
    }
}
- (UIColor *)selectedColor{
    if (_selectedColor) {
        return _selectedColor;
    }else{
        return [UIColor whiteColor];
    }
}
- (UIColor *)selectedBackgroundColor{
    if (_selectedBackgroundColor) {
        return _selectedBackgroundColor;
    }else{
        return [UIColor blackColor];
    }
}
@end

@interface DDIndexViewMode()


@end

@implementation DDIndexViewMode
- (instancetype)initMakeIndexviewModel:(DD_MakeIndexModel)block
{
    self = [super init];
    if (self) {
        DDIndexViewModel *model = [[DDIndexViewModel alloc]init];
        block(model);
        _model = model;
    }
    return self;
}
- (CGFloat)countEnityHeight:(CGFloat)itemHeight{
    CGFloat height = 0;
    if (itemHeight != 0) {
        height = itemHeight * _model.titles.count;
    }
    return height;
}
- (CGFloat)countEquilong:(CGFloat)wholelong withItemHeight:(CGFloat)itemHeight{
    CGFloat height = 0;
    if (wholelong != 0) {
        height = (wholelong - [self countEnityHeight:itemHeight]) / 2;
    }
    return height;
}
- (CGFloat)topPadding
{
    if (self.model) {
        return [self countEquilong:self.model.cachedSize.height withItemHeight:self.model.cachedSize.width];
    }else{
        return 0;
    }
}
- (NSDictionary *)dictionaryFromModel
{
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([DDIndexViewModel class], &count);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self.model valueForKey:key];
        
        //only add it to dictionary if it is not nil
        if (key && value) {
            if ([value isKindOfClass:[NSString class]]
                || [value isKindOfClass:[NSNumber class]]|| [value isKindOfClass:[UIFont class]]|| [value isKindOfClass:[NSValue class]]|| [value isKindOfClass:[UIColor class]]) {
                // 普通类型的直接变成字典的值
                [dict setObject:value forKey:key];
            }
            else if ([value isKindOfClass:[NSArray class]]
                     || [value isKindOfClass:[NSDictionary class]]) {
                // 数组类型或字典类型
                [dict setObject:[self idFromObject:value] forKey:key];
            }
            else {
                // 如果model里有其他自定义模型，则递归将其转换为字典
                [dict setObject:[value dictionaryFromModel] forKey:key];
            }
        } else if (key && value == nil) {
            // 如果当前对象该值为空，设为nil。在字典中直接加nil会抛异常，需要加NSNull对象
            [dict setObject:[NSNull null] forKey:key];
        }
    }
    [dict setObject:[NSNumber numberWithFloat:self.topPadding]
             forKey:@"topPadding"];
    free(properties);
    return dict;
}
- (id)idFromObject:(nonnull id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        if (object != nil && [object count] > 0) {
            NSMutableArray *array = [NSMutableArray array];
            for (id obj in object) {
                // 基本类型直接添加
                if ([obj isKindOfClass:[NSString class]]
                    || [obj isKindOfClass:[NSNumber class]]) {
                    [array addObject:obj];
                }
                // 字典或数组需递归处理
                else if ([obj isKindOfClass:[NSDictionary class]]
                         || [obj isKindOfClass:[NSArray class]]) {
                    [array addObject:[self idFromObject:obj]];
                }
                // model转化为字典
                else {
                    [array addObject:[obj dictionaryFromModel]];
                }
            }
            return array;
        }
        else {
            return object ? : [NSNull null];
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        if (object && [[object allKeys] count] > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSString *key in [object allKeys]) {
                // 基本类型直接添加
                if ([object[key] isKindOfClass:[NSNumber class]]
                    || [object[key] isKindOfClass:[NSString class]]) {
                    [dic setObject:object[key] forKey:key];
                }
                // 字典或数组需递归处理
                else if ([object[key] isKindOfClass:[NSArray class]]
                         || [object[key] isKindOfClass:[NSDictionary class]]) {
                    [dic setObject:[self idFromObject:object[key]] forKey:key];
                }
                // model转化为字典
                else {
                    [dic setObject:[object[key] dictionaryFromModel] forKey:key];
                }
            }
            return dic;
        }
        else {
            return object ? : [NSNull null];
        }
    }
    
    return [NSNull null];
}
@end
