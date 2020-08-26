//
//  TSClipView.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSClipView.h"
#import "TSDragAreaView.h"
#import "UIView+LayoutMethods.h"

#define VIEW_POINT_RADIUS  12.0                                  //视图上点的半径
#define VIEW_POINT_DISTANCE 50.0                                 //点与点的最小距离 为50

typedef NS_ENUM(NSInteger,TSClipViewDragType){
    TSClipViewDragTypeArea = 0,  //拖动区域
    TSClipViewDragTypePoint,     //拖动点
    TSClipViewDragTypeNone       //未拖动
};

@interface TSClipView()


@property (nonatomic, assign) TSClipViewDragType dargType;
@property (nonatomic, assign) CGPoint originPoint;

@property (nonatomic, strong) TSDragAreaView *dragView;
@property (nonatomic, assign) NSInteger dragPointIndex; //默认-1


@end

@implementation TSClipView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.isCanMove = YES;
    }
    return self;
}

- (void)setViewSize:(CGSize)size{
    _dargType = TSClipViewDragTypeNone;
    
    CGFloat wh = 150;
    if( wh > size.width || wh > size.height ){
        wh = MIN(size.width, size.height)-10;
    }
    CGFloat ih = wh;
    CGFloat iw = ih*9/16;
    
    CGFloat ix = (size.width-iw)/2;
    CGFloat iy = (size.height-ih)/2;

    _pointArr = @[[NSValue valueWithCGPoint:CGPointMake(ix, iy)],
                  [NSValue valueWithCGPoint:CGPointMake(ix+iw, iy)],
                  [NSValue valueWithCGPoint:CGPointMake(ix+iw, iy+ih)],
                  [NSValue valueWithCGPoint:CGPointMake(ix, iy+ih)]];
    
    [self setNeedsDisplay];
}

#pragma mark - Private

//点是否在四个端点上
- (BOOL)pointIsAtCornerPoint:(CGPoint)point{

    for( NSUInteger i=0; i<self.pointArr.count; i++ ){
        NSValue *val = _pointArr[i];
        CGPoint cornerPoint = val.CGPointValue;
        CGFloat px = point.x,py = point.y;
        CGFloat cx = cornerPoint.x, cy = cornerPoint.y;
        CGFloat radius = VIEW_POINT_RADIUS;
        if(  px >= cx-radius && px <= cx+radius &&
           py >= cy-radius && py <= cy+radius ){
            
            _dragPointIndex = i;
            return YES;
        }
    }
    
    return NO;
}

//点是否在 选区内部，在点上不算内部，在线上算内部
- (BOOL)pointIsAtInnerOfArea:(CGPoint)point{
    BOOL isAtCorner = [self pointIsAtCornerPoint:point];
    if( isAtCorner ) return NO;
    
    if( _pointArr.count > 2 ){
        CGPoint pa = ((NSValue*)(_pointArr[0])).CGPointValue;
        CGPoint pc = ((NSValue*)(_pointArr[2])).CGPointValue;
        
        CGFloat px = point.x,py = point.y;
        if( px >= pa.x && px <=pc.x &&
           py >= pa.y && py <= pc.y ){
            return YES;
        }
    }
    
    return NO;
}

//根据改变的x和y的多少，来修改整个区域point的值
- (void)updateAreaCornerPointWithDx:(CGFloat)dx dy:(CGFloat)dy{
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:4];
    BOOL isCanUpdate = YES;
    for( NSValue *val in self.pointArr ){
        CGPoint pt = val.CGPointValue;
        pt.x += dx;
        pt.y += dy;
        if( pt.x < 0 || pt.y <0 || pt.x > self.bounds.size.width ||
           pt.y > self.bounds.size.height ){
            if( _isCanMove == NO )
                isCanUpdate = NO;
        }
        
        if( isCanUpdate )
            
            [newArr addObject:[NSValue valueWithCGPoint:pt]];
    }
    
    if( isCanUpdate ){
        _pointArr = newArr;
    }
}

- (void)updateCornerPointWithDx:(CGFloat)dx dy:(CGFloat)dy{
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:4];
    
//    CGFloat dx = (currPoint.x-_originPoint.x);
//    CGFloat dy = (currPoint.y-_originPoint.y);
    
//    CGPoint lastCenter = _dragView.center;
    

    if( _dragPointIndex == 0 ){
        //A点X增大缩小 Y增大缩小
        dx = -dx; dy = -dy;
    }else if( _dragPointIndex == 1 ){
        //B点X增大增大 Y增大缩小
        dy = -dy;
    }else if( _dragPointIndex == 2 ){
        //C点X增大增大 Y增大增大
    }else if( _dragPointIndex == 3 ){
        //D点X增大缩小 Y增大增大
        dx = -dx;
    }
    
    if( fabs(dx) > fabs(dy) ){
        dy = dx*16/9;
    }
    else{
        dx = dy *9/16;
    }
    
    //计算两点之间的距离,限制缩小的最小范围
    if( _pointArr.count > 3 ){
        CGPoint pA = ((NSValue*)(_pointArr[0])).CGPointValue;
        CGPoint pC = ((NSValue*)(_pointArr[2])).CGPointValue;
        CGFloat px = pC.x - pA.x;
        CGFloat py = pC.y - pA.y;
        BOOL isChangeToSmallX = NO; //是否是缩小
        BOOL isChangeToSmallY = NO; //是否是缩小
        if( _dragPointIndex == 0 ){
            //A点X增大缩小 Y增大缩小
            if( dx < 0 ) isChangeToSmallX = YES;
            if( dy < 0 ) isChangeToSmallY = YES;
            
        }else if( _dragPointIndex == 1 ){
            //B点X增大增大 Y增大缩小
            if( dx < 0 ) isChangeToSmallX = YES;
            if( dy < 0 ) isChangeToSmallY = YES;
     
        }else if( _dragPointIndex == 2 ){
            //C点X增大增大 Y增大增大
            if( dx < 0 ) isChangeToSmallX = YES;
            if( dy < 0 ) isChangeToSmallY = YES;
        }else if( _dragPointIndex == 3 ){
            //D点X增大缩小 Y增大增大
            if( dx < 0 ) isChangeToSmallX = YES;
            if( dy < 0 ) isChangeToSmallY = YES;
        }
        if( isChangeToSmallX && px <= VIEW_POINT_DISTANCE){
            //说明超过的最小距离
            dx = 0;
            //////
            dy = 0;
        }
        if( isChangeToSmallY  && py <= VIEW_POINT_DISTANCE){
            dy = 0;
            ///////
            dx = 0;
        }
    }
    
    BOOL isCanUpdate = YES;
    NSUInteger i=0;
    for( NSValue *val in self.pointArr ){
        CGPoint pt = val.CGPointValue;
        if( i== 0 || i==3){
            pt.x -= dx;
        }
        else{
            pt.x += dx;
        }
        
        if( i==0 || i==1 ){
            pt.y -= dy;
        }else{
            pt.y += dy;
        }
        
        if( pt.x < 0 || pt.y <0 || pt.x > self.bounds.size.width ||
           pt.y > self.bounds.size.height ){
            isCanUpdate = NO;
        }
        if( isCanUpdate )
            [newArr addObject:[NSValue valueWithCGPoint:pt]];
        
        i++;
    }
    
    if( isCanUpdate ){
        _pointArr = newArr;
    }
}

- (NSInteger)pointMaxCount{
    return 4;
}

//获取touch时所在的点
-(CGPoint)touchLocationWithTouchs:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint currLocation = [touch locationInView:self];
    
    return currLocation;
}

//画圆 半径为12 颜色为黄色
-(void)drawCircleWithOrigin:(CGPoint)op
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:op radius:VIEW_POINT_RADIUS startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    if( self.pointColor == nil )
        self.pointColor = [UIColor whiteColor];// [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
    [ self.pointColor setFill];
    
    [path fill];
    
    [self drawCrossWithOrigin:op];
}

//画十字 长度为VIEW_POINT_RADIUS*2
-(void)drawCrossWithOrigin:(CGPoint)op
{
//    CGPoint pa1 = CGPointMake(op.x+VIEW_POINT_RADIUS, op.y);
//    CGPoint pa2 = CGPointMake(op.x-VIEW_POINT_RADIUS, op.y);
//
//    CGPoint pb1 = CGPointMake(op.x, op.y+VIEW_POINT_RADIUS);
//    CGPoint pb2 = CGPointMake(op.x, op.y-VIEW_POINT_RADIUS);
//
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [[UIColor whiteColor] setStroke];
//    [path moveToPoint:pa1];
//    [path addLineToPoint:pa2];
//    [path stroke];
//
//    [[UIColor whiteColor] setStroke];
//    [path moveToPoint:pb1];
//    [path addLineToPoint:pb2];
//    [path stroke];
}

//画虚线
-(void)drawVirtualLine
{
    NSUInteger i = 0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for ( NSValue *val in self.pointArr ) {
        
//        CGFloat dashArr[3];
//        dashArr[0] = 5;
//        dashArr[1]= 5;
//        dashArr[2] = 5;
//        [path setLineDash:dashArr count:3 phase:0.0];
        
        path.lineWidth = 4.0;
        if( i == 0 )
        {
            [path moveToPoint:val.CGPointValue];
        }
        else
            [path addLineToPoint:val.CGPointValue];
        i++;
    }
    
    if( self.pointArr.count == [self pointMaxCount] )
        [path closePath];
    
    if( [self.pointArr count]>1  )          //至少有两个点
    {
        [[UIColor whiteColor] setStroke];
        [path stroke];
    }
}

#pragma mark - Touch Event

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [[UIColor colorWithWhite:0 alpha:0.6] setFill];
    //半透明区域
    UIRectFill(rect);
    //透明的区域
    CGPoint pa = ((NSValue*)(_pointArr[0])).CGPointValue;
    CGPoint pc = ((NSValue*)(_pointArr[2])).CGPointValue;
    CGRect holeRection = CGRectMake(pa.x, pa.y, pc.x-pa.x, pc.y-pa.y);
    /** union: 并集
     CGRect CGRectUnion(CGRect r1, CGRect r2)
     返回并集部分rect
     */
    /** Intersection: 交集
     CGRect CGRectIntersection(CGRect r1, CGRect r2)
     返回交集部分rect
     */
    CGRect holeiInterSection = CGRectIntersection(holeRection, rect);
    [[UIColor clearColor] setFill];
    //CGContextClearRect(ctx, <#CGRect rect#>)
    //绘制
    //CGContextDrawPath(ctx, kCGPathFillStroke);
    UIRectFill(holeiInterSection);
    
    for( NSValue *va in self.pointArr )
    {
        [self drawCircleWithOrigin:va.CGPointValue];
    }
    [self drawVirtualLine];
}

//滑动时调用
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( [[event allTouches] count] == 1 )
    {//单指拖动
        CGPoint currPoint = [self touchLocationWithTouchs:touches];
        
//        UITouch *touch = [touches anyObject];
//
//        //当前的point
//        CGPoint currentP = [touch locationInView:self];
//
//        //以前的point
//        CGPoint preP = [touch previousLocationInView:self];
//
//        //x轴偏移的量
//        CGFloat offsetX = currentP.x - preP.x;
//
//        //Y轴偏移的量
//        CGFloat offsetY = currentP.y - preP.y;
//
//        self.dragView.transform = CGAffineTransformTranslate(self.dragView.transform, offsetX, offsetY);
        
        if( _dargType == TSClipViewDragTypePoint  )
        {//拖动点
            
            CGFloat dx = currPoint.x-_originPoint.x;
            CGFloat dy = currPoint.y-_originPoint.y;
            
            [self updateCornerPointWithDx:dx dy:dy];
        }
        else if( _dargType == TSClipViewDragTypeArea )
        {//拖动选区
            [self updateAreaCornerPointWithDx:currPoint.x-_originPoint.x dy:currPoint.y-_originPoint.y];
        }
//
        if( _dargType != TSClipViewDragTypeNone ){
             [self setNeedsDisplay];
        }
        
        _originPoint = currPoint;
    }
}

//触摸时调用
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _dargType = TSClipViewDragTypeNone;
    //单指触摸
    if( [[event allTouches] count] == 1 )
    {
        _originPoint = [self touchLocationWithTouchs:touches];
        if( [self pointIsAtCornerPoint:_originPoint] ){
            _dargType = TSClipViewDragTypePoint;
        }else if( [self pointIsAtInnerOfArea:_originPoint] ){
            _dargType = TSClipViewDragTypeArea;
        }
    }
}

//有触摸但无滑动  结束触摸时调用
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

//触摸及滑动结束时调用
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( [[event allTouches] count] == 1 )
    {//单指
        if( _dargType == TSClipViewDragTypeArea ){
            
            if( _delegate && [_delegate respondsToSelector:@selector(dragSelectAreaEnd:)]){
                [_delegate dragSelectAreaEnd:self];
            }
            
            _dargType = TSClipViewDragTypeNone;
        }
    }
    
    //将新形成的区域添加到undoAreaArr中
//    [self updateUndoAreaArr];
}

//-(NSMutableArray*)pointArr
//{
//    if( !_pointArr )
//    {
//        _pointArr = [[NSMutableArray alloc] initWithCapacity:4];
//    }
//    return _pointArr;
//}

@end
