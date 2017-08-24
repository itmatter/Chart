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
    NSArray *dataSource = @[@1212,@4642,@7321,@464,@1442,@7111,@2823,@353,@464,@464,@144];
    FoldingChart *chartV = [[FoldingChart alloc]initWithFrame:self.charView.bounds
                                               WithDataSource:dataSource
                                                    withCount:5
                                                     timeType:mCustom];
    
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
