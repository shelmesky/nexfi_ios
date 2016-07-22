//
//  NFReportTipsVC.m
//  Nexfi
//
//  Created by fyc on 16/7/21.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFReportTipsVC.h"

@interface NFReportTipsVC ()<UIScrollViewDelegate>

@end

@implementation NFReportTipsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:@"投诉须知" left:nil right:nil WithInVC:self];
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64)];
    scroll.pagingEnabled = YES;
    scroll.bounces = NO;
    scroll.delegate = self;
    [self.view addSubview:scroll];
    
    scroll.contentSize = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.height - 63);
    
    UILabel *ComplaintTitle = [[UILabel alloc]init];
    ComplaintTitle.bounds = CGRectMake(0, 0, 100, 30);
    ComplaintTitle.font = [UIFont systemFontOfSize:14.0];
    ComplaintTitle.center = CGPointMake(SCREEN_SIZE.width/2, 35);
    ComplaintTitle.text = @"投诉须知";
    [scroll addSubview:ComplaintTitle];
    
    UILabel *complaintContent = [[UILabel alloc]init];
    complaintContent.frame = CGRectMake(10, ComplaintTitle.frame.origin.y + 30, SCREEN_SIZE.width - 20, 100);
    complaintContent.font = [UIFont systemFontOfSize:11.0];
    complaintContent.text = @"你应保证你的投诉行为基于善意，并代表你本人的真实意思，我们收到你的投诉后，会根据相关法律的规定进行处理，保护你的个人信息，除法律规定的情形外，未经用户许可我们不会向第三方公开、透露你的个人信息";
    [scroll addSubview:complaintContent];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
