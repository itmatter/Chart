
//
//  MapView.m
//  Chart
//
//  Created by 李礼光 on 2017/8/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "FoldingChart.h"

#define MARGIN 30.0

#define Y_HEIGHT (self.bounds.size.height - 2 * MARGIN)
#define X_WIDTH (self.bounds.size.width - 2 * MARGIN)

#define START_POINT_X MARGIN
#define START_POINT_Y (self.bounds.size.height - MARGIN)

#define END_POINT_X (self.bounds.size.width - MARGIN)
#define END_POINT_Y MARGIN

#define LINE_WIDTH 1

#define FILL_COLOR [UIColor blackColor].CGColor
#define STROKE_COLOR [UIColor blackColor].CGColor

typedef NS_ENUM(NSInteger, AxisType) {
    xAxis = 0,
    yAxis,
};

@interface FoldingChart()<UIGestureRecognizerDelegate>
@property (nonatomic, assign) int yCount;
@property (nonatomic, assign) XType xType;
@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSArray *xAxisDayPoint;   //x轴坐标点
@property (nonatomic, strong) NSArray *xAxisWeekPoint;   //x轴坐标点
@property (nonatomic, strong) NSArray *xAxisMonthPoint;   //x轴坐标点

@property (nonatomic, strong) NSMutableArray *dataSourcePoint;   //数据源坐标点
@property (nonatomic, strong) NSMutableArray *customDataXAxisPoint;   //X轴数据坐标点
@property (nonatomic, strong) NSMutableArray *customDataXAxisPointValue;   //X数据坐标点数


@property (nonatomic, strong) NSArray *xAxisDayValues;  //x轴的标尺数值
@property (nonatomic, strong) NSArray *xAxisWeekValues;  //x轴的标尺数值
@property (nonatomic, strong) NSMutableArray *xAxisMonthValues;  //x轴的标尺数值


@end


@implementation FoldingChart {
    NSMutableArray *_yAxisPoint;    //y轴坐标点
    NSMutableArray *_yAxisValues;   //y轴的标尺数值
    
    UIBezierPath *_instructionsLine; //指示图层
    CAShapeLayer *_instructionsLayer; //指示图层
    UILabel *_instructionsLabel; //指示图层
}

#pragma mark - 懒加载

//初始化xDay坐标的内容
- (NSArray *)xAxisDayPoint {
    if (_xAxisDayPoint == nil) {
        _xAxisDayPoint = [self calculateIntervalPoints:8];
    }
    return _xAxisDayPoint;
}
- (NSArray *)xAxisWeekPoint {
    if (_xAxisWeekPoint == nil) {
        _xAxisWeekPoint =  [self calculateIntervalPoints:7];
    }
    return _xAxisWeekPoint;
}
- (NSArray *)xAxisMonthPoint {
    if (_xAxisMonthPoint == nil) {
        //计算某一个月的总天数
        _xAxisMonthPoint = [self calculateIntervalPoints:(int)[self getNumberOfDaysInMonth] ];
    }
    return _xAxisMonthPoint;
}
- (NSArray *)xAxisDayValues {
    if (_xAxisDayValues == nil) {
        _xAxisDayValues = [NSMutableArray arrayWithObjects: @"03:00",@"06:00",
                                                            @"09:00",@"12:00",@"15:00",
                                                            @"18:00",@"21:00",@"24:00",
                           nil];
    }
    return _xAxisDayValues;
}
- (NSArray *)xAxisWeekValues {
    if (_xAxisWeekValues == nil) {
        _xAxisWeekValues = [NSMutableArray arrayWithObjects:@"Mon",@"Tues",@"Wed",
                                                            @"Thur",@"Fri",@"Sat",
                                                            @"Sun",
                            nil];
    }
    return _xAxisWeekValues;
}
- (NSMutableArray *)xAxisMonthValues {
    if (_xAxisMonthValues == nil) {
        _xAxisMonthValues = [NSMutableArray array];
        for (int i = 1; i < [self getNumberOfDaysInMonth] + 1  ; i++) {
            [_xAxisMonthValues addObject:[NSString stringWithFormat:@"%@",@(i)]];
        }
    }
    return _xAxisMonthValues;
}
- (NSMutableArray *)dataSourcePoint {
    if (_dataSourcePoint == nil) {
        _dataSourcePoint = [NSMutableArray array];
    }
    return _dataSourcePoint;
}
- (NSMutableArray *)customDataXAxisPoint {
    if (_customDataXAxisPoint == nil) {
        _customDataXAxisPoint = [NSMutableArray array];
    }
    return _customDataXAxisPoint;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame WithDataSource:(NSArray *)data withCount:(int)count timeType:(XType)type {
    if (self = [super initWithFrame:frame]) {
        self.dataSource = data;
        self.yCount = count + 1;
        self.xType = type;
        CGFloat dataMaxValue = [self getMaxFromArray:data];
        self.maxY = Y_HEIGHT > dataMaxValue ? Y_HEIGHT :dataMaxValue;
        [self buidlMap];
    }
    return self;
}


- (void)buidlMap {
    [self drawLine:self.dataSource];
    [self setupYAxis];
    [self setupXAxis];
}


#pragma mark - UI
/**
 画线

 @param data 数据源 : NSNumber类型数组.
 */
- (void)drawLine:(NSArray *)data {
    
    if (self.xType == mDay) {
        NSAssert(data.count == 8, @"请设置8个值");
    }else if (self.xType == mWeek) {
        NSAssert(data.count == 7, @"请设置7个值");
    }else if (self.xType == mMonth) {
        NSInteger count = [self getNumberOfDaysInMonth];
        NSString *info = [NSString stringWithFormat:@"请设置%ld个值",(long)[self getNumberOfDaysInMonth]];
        NSAssert(data.count == count,info);
    }
    
    //核心部分
    CGFloat margin = X_WIDTH / (data.count + 1);
    CGFloat max = self.maxY;
    
    NSMutableArray *circlePointArr = [NSMutableArray array];
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    for (int i = 0; i<data.count; i++) {
        CGFloat yPosition = [(NSNumber *)data[i] floatValue] / max * Y_HEIGHT ;
        if (i == 0) {
            [line moveToPoint:CGPointMake(START_POINT_X + margin, Y_HEIGHT - yPosition + MARGIN)];
            [circlePointArr addObject:[NSValue valueWithCGPoint:CGPointMake(START_POINT_X + margin, Y_HEIGHT - yPosition + MARGIN)]];
        }else {
            [line addLineToPoint:CGPointMake(START_POINT_X + margin * (i + 1), Y_HEIGHT - yPosition + MARGIN)];
            [circlePointArr addObject:[NSValue valueWithCGPoint:CGPointMake(START_POINT_X + margin * (i + 1), Y_HEIGHT - yPosition + MARGIN)]];
        }
        [self.customDataXAxisPoint addObject:[NSValue valueWithCGPoint:CGPointMake(START_POINT_X + margin * (i + 1),START_POINT_Y)]];
    }
    
    self.dataSourcePoint = circlePointArr;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.path = line.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = LINE_WIDTH;
    [self.layer addSublayer:layer];

    CABasicAnimation *strokeEndAni = [CABasicAnimation animation];
    strokeEndAni.keyPath = @"strokeEnd";
    strokeEndAni.fillMode = kCAFillModeForwards;
    strokeEndAni.fromValue = @0;
    strokeEndAni.toValue = @1;
    strokeEndAni.removedOnCompletion = NO;
    strokeEndAni.duration = 2;
    [layer addAnimation:strokeEndAni forKey:nil];

    //添加圆点
    [self addCirclePoint: circlePointArr];
}


/**
 设置Y轴坐标尺
 */
- (void)setupYAxis {
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(START_POINT_X, START_POINT_Y)];
    [xAxisPath addLineToPoint:CGPointMake(START_POINT_X, END_POINT_Y)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.path = xAxisPath.CGPath;
    layer.lineWidth = LINE_WIDTH;
    layer.fillColor = FILL_COLOR;
    layer.strokeColor = STROKE_COLOR;
    [self.layer addSublayer:layer];
}


/**
 设置X轴坐标尺
 */
- (void)setupXAxis {
    _yAxisPoint = [NSMutableArray array];       //y轴的坐标点
    _yAxisValues = [NSMutableArray array];      //y轴的标尺数值
    for (int i = 0 ; i < self.yCount; i ++) {
        
        UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
        [xAxisPath moveToPoint:CGPointMake( START_POINT_X, START_POINT_Y - Y_HEIGHT / self.yCount * i)];
        [xAxisPath addLineToPoint:CGPointMake(END_POINT_X, START_POINT_Y - Y_HEIGHT / self.yCount * i)];
        
        [_yAxisPoint addObject:[NSValue valueWithCGPoint:CGPointMake(START_POINT_X,
                                                                     START_POINT_Y - Y_HEIGHT / self.yCount * i)]];
        
        [_yAxisValues addObject:[NSNumber numberWithFloat:self.maxY / self.yCount * i]];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.path = xAxisPath.CGPath;
        layer.lineWidth = LINE_WIDTH;
        layer.fillColor = FILL_COLOR;
        layer.strokeColor = STROKE_COLOR;
        
        if (i>0) {
            [layer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3],
                                                                [NSNumber numberWithInt:5], nil]];
            layer.fillColor = [UIColor grayColor].CGColor;
            layer.strokeColor = [UIColor grayColor].CGColor;
        }
        [self.layer addSublayer:layer];
    }
    //添加小圆点
    [self addCirclePoint: _yAxisPoint];
    [self addPointCentent:_yAxisPoint AndTexts:_yAxisValues withAxisType:yAxis];

 
    
    
    if (self.xType == mDay) {
        [self addCirclePoint: self.xAxisDayPoint];
        [self addPointCentent:self.xAxisDayPoint AndTexts:self.xAxisDayValues withAxisType:xAxis];
    }else if (self.xType == mWeek) {
        [self addCirclePoint: self.xAxisWeekPoint];
        [self addPointCentent:self.xAxisWeekPoint AndTexts:self.xAxisWeekValues withAxisType:xAxis];
    }else if (self.xType == mMonth) {
        [self addCirclePoint: self.xAxisMonthPoint];
        [self addPointCentent:self.xAxisMonthPoint AndTexts:self.xAxisMonthValues withAxisType:xAxis];
    }else {
        NSMutableArray *xValue = [NSMutableArray array];
        for (int i = 0; i < self.dataSource.count; i++) {
            [xValue addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self addCirclePoint:self.customDataXAxisPoint];
        [self addPointCentent:self.customDataXAxisPoint AndTexts:xValue withAxisType:xAxis];
    }

}


/**
 添加小圆点

 @param points 坐标点数组 : NSValue类型数组
 */
- (void)addCirclePoint : (NSArray *)points {
    NSAssert(points.count != 0, @"y轴没有数据");
    for (int i = 0 ; i < points.count; i ++) {
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:[points[i] CGPointValue]
                                                                 radius:2
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.path = circlePath.CGPath;
        layer.lineWidth = LINE_WIDTH;
        layer.fillColor = FILL_COLOR;
        layer.strokeColor = STROKE_COLOR;
        [self.layer addSublayer:layer];
    }
    
}

/**
 添加标尺内容

 @param points x轴或y轴的坐标点,NSValue类型数组
 @param texts x轴或y轴的坐标点上的值,NSString类型数组
 @param type x轴或者是Y轴
 */
- (void)addPointCentent:(NSArray *)points AndTexts:(NSArray *)texts withAxisType:(AxisType)type{
    if (type == yAxis) {
        //这里用self.yCount主要是为了可以自定义y轴的范围值
        for (int i = 0; i<self.yCount; i++) {
            CGPoint point = [points[i] CGPointValue];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x - MARGIN ,
                                                                      point.y - MARGIN * 0.5 ,
                                                                      MARGIN,MARGIN)];
            NSNumber *num = (NSNumber *)texts[i];
            label.text = [NSString stringWithFormat:@"%.f", num.floatValue];
            label.numberOfLines = 1;
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blackColor];
            [self addSubview:label];
        }

    }else if (type == xAxis){
        for (int i = 0; i < points.count; i++) {
            CGPoint point = [(NSValue *)points[i] CGPointValue];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x - MARGIN * 0.5,point.y,MARGIN,MARGIN)];
            label.text = texts[i];
            label.numberOfLines = 1;
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blackColor];
            [self addSubview:label];
        }
    }
    
    
}


#pragma mark - 其他方法


/**
 遍历数组求最大值

 @param arr 数组 : NSNumber类型
 @return 返回数组中的最大的值.
 */
- (CGFloat)getMaxFromArray:(NSArray *)arr {
    CGFloat max = 0.0;
    for (int i=0; i<arr.count; i++) {
        max = max > [(NSNumber *)arr[i] floatValue] ? max : [(NSNumber *)arr[i] floatValue];
    }
    return max;
}


/**
 计算坐标轴的坐标点

 @param interval 计算点数
 @return 间距相同的坐标轴坐标点
 */
- (NSArray *)calculateIntervalPoints:(int)interval {
    NSMutableArray *tmp = [NSMutableArray array];
    CGFloat margin = X_WIDTH / (interval + 1);
    for (int i = 0; i < interval; i++) {
        [tmp addObject:[NSValue valueWithCGPoint:CGPointMake(START_POINT_X + margin * (i + 1), START_POINT_Y)]];
    }
    return tmp;
}

/**
 获取月份天数

 @return 当前月份的天数
 */
- (NSInteger)getNumberOfDaysInMonth {
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * currentDate = [NSDate date];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth
                                  forDate:currentDate];
    return range.length;
}

#pragma mark - 动作手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (int i = 0; i<self.dataSourcePoint.count; i++) {
        if (fabs( touchPoint.x - [(NSValue *)self.dataSourcePoint[i] CGPointValue].x) < 5 ){
            if (_instructionsLine) {
                _instructionsLine = nil;
            }
            if (_instructionsLayer) {
                _instructionsLayer = nil;
            }
            if (_instructionsLabel) {
                _instructionsLabel = nil;
            }
            CGFloat x = [(NSValue *)self.dataSourcePoint[i] CGPointValue].x;
            CGFloat y = [(NSValue *)self.dataSourcePoint[i] CGPointValue].y;
            
            
            _instructionsLine = [UIBezierPath bezierPath];
            [_instructionsLine moveToPoint:CGPointMake(x,y)];
            [_instructionsLine addLineToPoint:CGPointMake(x,START_POINT_Y)];
            
            _instructionsLayer = [CAShapeLayer layer];
            _instructionsLayer.strokeColor = [UIColor blueColor].CGColor;
            _instructionsLayer.frame = self.bounds;
            _instructionsLayer.path = _instructionsLine.CGPath;
            _instructionsLayer.lineWidth = 1;
            [self.layer addSublayer:_instructionsLayer];
            
            
            _instructionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(x + 2,y - 15, 60, 30)];
            _instructionsLabel.text = [NSString stringWithFormat:@"%.f",[(NSNumber *)self.dataSource[i] floatValue]];
            _instructionsLabel.font = [UIFont systemFontOfSize:10];
            _instructionsLabel.textAlignment = NSTextAlignmentLeft;
            _instructionsLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:_instructionsLabel];
            
            
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_instructionsLine) {
        [_instructionsLine removeAllPoints];
        _instructionsLine = nil;
    }
    if (_instructionsLayer) {
        [_instructionsLayer removeFromSuperlayer];
        _instructionsLayer = nil;
    }
    if (_instructionsLabel) {
        [_instructionsLabel removeFromSuperview];
        _instructionsLabel = nil;
    }
}




@end
