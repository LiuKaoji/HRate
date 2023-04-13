#import "YOLineChartImage.h"

@implementation YOLineChartImage

- (instancetype)init {
    self = [super init];
    if (self) {
        _strokeWidth = 1.0;
        _strokeColor = [UIColor whiteColor];
        _smooth = YES;
        _values = [NSArray array];
    }
    return self;
}

- (NSNumber *) maxValue {
    return _maxValue ? _maxValue : [NSNumber numberWithFloat:[[_values valueForKeyPath:@"@max.floatValue"] floatValue]];
}

- (UIImage *)drawImageIn:(CGRect)frame scale:(CGFloat)scale edgeInsets:(UIEdgeInsets)edgeInsets
{
    NSAssert(_values.count > 1, @"YOLineChartImage // must assign values property which is an array of NSNumber");
    
    NSUInteger valuesCount = _values.count;
    CGFloat pointXSpacing = (frame.size.width - edgeInsets.left - edgeInsets.right) / (valuesCount - 1);
    NSMutableArray<NSValue *> *points = [NSMutableArray array];
    CGFloat maxValue = self.maxValue.floatValue;
    
    [_values enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *_) {
        CGFloat ratioY = number.floatValue / maxValue;
        CGFloat offsetY = ratioY == 0.0 ? -_strokeWidth / 2 : _strokeWidth / 2;
        NSValue *pointValue = [NSValue valueWithCGPoint:(CGPoint){
            (float)idx * pointXSpacing + edgeInsets.left,
            (frame.size.height - edgeInsets.top - edgeInsets.bottom) * (1 - ratioY) + offsetY + edgeInsets.top
        }];
        
        [points addObject:pointValue];
    }];
    
    UIGraphicsBeginImageContextWithOptions(frame.size, false, scale);
    
    UIBezierPath *path = [self quadCurvedPathWithPoints:points frame:frame];
    path.lineWidth = _strokeWidth;
    
    if (_strokeColor) {
        [_strokeColor setStroke];
        [path stroke];
    }
    
    if (self.pointColor != nil) {
        [self drawPoints:points color:self.pointColor];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawPoints:(NSArray<NSValue *> *)points color:(UIColor *)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint point = obj.CGPointValue;
        CGRect rect = CGRectMake(point.x - 4, point.y - 4, 8, 8);
        
        [color setFill];
        CGContextFillEllipseInRect(context, rect);
        
        //        NSString *string = @"123";
        //
        //        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        //        attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
        //        attributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        //
        //        [string drawAtPoint:point withAttributes:attributes];
    }];
}

#pragma mark - Path generator

- (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points frame:(CGRect)frame {
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    UIBezierPath *fillBottom = [[UIBezierPath alloc] init];
    
    CGPoint startPoint = (CGPoint){0, frame.size.height};
    CGPoint endPoint = (CGPoint){frame.size.width, frame.size.height};
    [fillBottom moveToPoint:endPoint];
    [fillBottom addLineToPoint:startPoint];
    
    __block CGPoint p1 = [points[0] CGPointValue];
    [linePath moveToPoint:p1];
    
    [fillBottom addLineToPoint:p1];
    
    if (points.count == 2) {
        CGPoint p2 = [points[1] CGPointValue];
        [linePath addLineToPoint:p2];
        [fillBottom addLineToPoint:p2];
        if (_fillColor) {
            [_fillColor setFill];
            [fillBottom fill];
        }
        return linePath;
    }
    
    [points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *_) {
        CGPoint p2 = value.CGPointValue;
        
        if (_smooth) {
            CGFloat deltaX = p2.x - p1.x;
            CGFloat controlPointX = p1.x + (deltaX / 2);
            CGPoint controlPoint1 = (CGPoint){controlPointX, p1.y};
            CGPoint controlPoint2 = (CGPoint){controlPointX, p2.y};
            
            [linePath addCurveToPoint:p2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
            [fillBottom addCurveToPoint:p2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            [linePath addLineToPoint:p2];
            [fillBottom addLineToPoint:p2];
        }
        
        p1 = p2;
    }];
    
    if (_fillColor) {
        [_fillColor setFill];
        [fillBottom fill];
    }
    
    return linePath;
}

@end
