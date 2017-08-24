//
//  ChartViewVC.m
//  Chart
//
//  Created by 李礼光 on 2017/8/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ChartViewVC.h"
#import "FoldingChart.h"
@interface ChartViewVC ()
@property (strong, nonatomic) IBOutlet UIView *charView;

@end

@implementation ChartViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)showFoldingChart {
    NSArray *dataSource = @[@222,@3134,@123,@523,@543,@523,@111,@452,@238,@122,@23];
    FoldingChart *chartV = [[FoldingChart alloc]initWithFrame:self.charView.bounds
                                               WithDataSource:dataSource];
    
    [self.charView addSubview:chartV];
}
- (IBAction)FoldingChart:(id)sender {
    [self showFoldingChart];
}

- (IBAction)PieChart:(id)sender {
}

- (IBAction)ColumnChart:(id)sender {
}

- (IBAction)RadarChart:(id)sender {
}



@end
