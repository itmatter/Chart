//
//  MapView.h
//  Chart
//
//  Created by 李礼光 on 2017/8/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoldingChart : UIView

//data里面的内容以NSNumber类型解析
- (instancetype)initWithFrame:(CGRect)frame
               WithDataSource:(NSArray *)data;


@end
