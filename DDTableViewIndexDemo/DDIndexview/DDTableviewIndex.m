//
//  DDTableviewIndex.m
//
//  Created by dong on 2019/1/28.
//  Copyright © 2019 d. All rights reserved.
//

#import "DDTableviewIndex.h"


// 根据section值获取CATextLayer的中心点y值
static inline CGFloat DDGetTextLayerCenterY(NSUInteger position, CGFloat margin, CGFloat space)
{
    return margin + (position + 1.0 / 2) * space;
}

// 根据y值获取CATextLayer的section值
static inline NSInteger DDPositionOfTextLayerInY(CGFloat y, CGFloat margin, CGFloat space)
{
    CGFloat position = (y - margin) / space - 1.0 / 2;
    if (position <= 0) return 0;
    NSUInteger bigger = (NSUInteger)ceil(position);
    NSUInteger smaller = bigger - 1;
    CGFloat biggerCenterY = DDGetTextLayerCenterY(bigger, margin, space);
    CGFloat smallerCenterY = DDGetTextLayerCenterY(smaller, margin, space);
    return biggerCenterY + smallerCenterY > 2 * y ? smaller : bigger;
}


@interface DDTableviewIndex()
{
    NSInteger _sentryIndex;
    NSArray<NSString *>  *_titles;
    UIFont  *_font;
    NSInteger _selectedSection;
    bool _pastTop;
    bool _pastBottom;
    CGSize _cachedSize;
    CGSize _cachedSizeToFit;
    UIColor *_indexColor;
    UIColor *_indexBackgroundColor;
    UIColor *_selectedColor;
    UIColor *_selectedBackgroundColor;
    double _topPadding;
    double _bottomPadding;
    double _verticlaTextHeightEstimate;
    NSArray *_entries;
    long long _idiom;
    
}
@property (copy, nonatomic)DD_SelectAtSection selectBlock;
@end
@implementation DDTableviewIndex
// 构造初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withMode:(DDIndexViewMode *)mode{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (void)setupNeedData:(NSDictionary *)data withBlock:(DD_SelectAtSection)block{
    [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [self setValue:obj forKeyPath:key];
    }];
    if (block) {
        _selectBlock = [block copy];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    // 让我看看没有实现的字段是什么
    NSLog(@"value ==== %@,key ====== %@",value,key);
}
#pragma mark - UITouch and UIEvent
- (void)setTitles:(NSArray<NSString *> *)titles{
    // 如果文字数组已经被初始化，或者同上次初始化相同，则保持不变
    if ([_titles isEqual:titles]) {
        return;
    }
    // 使用copy，防止随意修改数据源
    _titles = titles.copy;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // 如果触碰点不在索引范围内
    if (!CGRectContainsPoint(self.bounds, point)) return NO;
    return YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    if (location.x < 0) return NO;
    NSInteger currentPosition = DDPositionOfTextLayerInY(location.y, _topPadding, _cachedSize.width);
    if (currentPosition < 0 || currentPosition >= (NSInteger)_titles.count) return YES;
    if (currentPosition != self.currentSection || currentPosition == 0) {
        [self configCurrentSection:currentPosition];
        if (_selectBlock) {
            _selectBlock(currentPosition);
        }
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    if (location.x < 0) return NO;

    NSInteger currentPosition = DDPositionOfTextLayerInY(location.y, _topPadding, _cachedSize.width);
    if (currentPosition < 0 || currentPosition >= (NSInteger)_titles.count) return YES;
    if (currentPosition != self.currentSection || currentPosition == 0) {
        [self configCurrentSection:currentPosition];
        if (_selectBlock) {
            _selectBlock(currentPosition);
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{

}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{

}

// 子类布局方法，外部最好不要访问
- (void)configSubLayersAndSubviews{
    // 判断当前tableview是否存在搜索
    // 此方法暂时没有使用，暂时保留
//    BOOL hasSearchLayer = [_titles.firstObject isEqualToString:UITableViewIndexSearch];
    if (self.layer.sublayers.count > 1) {
        return;
    }
    // 写之前我权衡了一下，使用一个textlayer，还是循环创建多个，最后还是觉得多个在判断位置的时候更方便
    for (NSString *title in _titles) {
        CATextLayer *titleLayer = [CATextLayer layer];
        titleLayer.string = title;
        [titleLayer setName:title];
        [self.layer addSublayer:titleLayer];
    }
    // Core Animation显示事务默认动画开启，渲染没那么生硬
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    double lastHeight = 0;
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CATextLayer class]]) {
            CATextLayer *textLayer = (CATextLayer *)layer;
            textLayer.frame = CGRectMake(0, _topPadding + lastHeight, _cachedSize.width, _cachedSize.width);
            //set layer font
            CFStringRef fontName = (__bridge CFStringRef)_font.fontName;
            CGFontRef fontRef = CGFontCreateWithFontName(fontName);
            textLayer.font = fontRef;
            textLayer.fontSize = 12;
            textLayer.cornerRadius = _cachedSize.width/2;
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.contentsScale = UIScreen.mainScreen.scale;
            textLayer.backgroundColor = _indexBackgroundColor.CGColor;
            textLayer.foregroundColor = _indexColor.CGColor;
            // 设置上一次高度
            lastHeight = lastHeight + _cachedSize.width;
        }
    }
    [CATransaction commit];
    // 默认选择第一个
    [self configCurrentSection:0];
}

- (void)configCurrentSection:(NSInteger)index{
    if (index >= _titles.count || index < 0 || (index == _sentryIndex && _sentryIndex != 0)) {
        return;
    }
    self.currentSection = index;
    
    NSString *layerName = _titles[index];
    CATextLayer *textLayer = [[self getLayerWithName:layerName] isKindOfClass:[CATextLayer class]] ? (CATextLayer *)[self getLayerWithName:layerName] : nil;
    
    NSString *sentryName = _titles[_sentryIndex];
     CATextLayer *sentryLayer = [[self getLayerWithName:sentryName] isKindOfClass:[CATextLayer class]] ? (CATextLayer *)[self getLayerWithName:sentryName] : nil;
    if (textLayer) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        textLayer.backgroundColor = _selectedBackgroundColor.CGColor;
        textLayer.foregroundColor = _selectedColor.CGColor;
        if (![layerName isEqualToString:sentryName]) {
            sentryLayer.backgroundColor = _indexBackgroundColor.CGColor;
            sentryLayer.foregroundColor = _indexColor.CGColor;
        }
        _sentryIndex = index;
        [CATransaction commit];
    }
}

- (CALayer *)getLayerWithName:(NSString *)name{
    
    for (CALayer *layer in [self.layer sublayers]) {
        
        if ([[layer name] isEqualToString:name]) {
            return layer;
        }
    }
    return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
