//
//  NFReportObjectVC.m
//  Nexfi
//
//  Created by fyc on 16/7/21.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFReportObjectVC.h"
#import "NFReportTipsVC.h"
@interface NFReportObjectVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *reportTable;
@property (nonatomic, strong)NSArray *contents;
@property (nonatomic, strong)NSString *content;

@end

@implementation NFReportObjectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:@"投诉" left:nil right:nil WithInVC:self];
    
    self.reportTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height) style:UITableViewStyleGrouped];
    self.reportTable.delegate = self;
    self.reportTable.dataSource = self;
    [self.view addSubview:self.reportTable];
    
    self.contents = @[@"色情低俗",@"赌博",@"政治敏感",@"欺诈骗钱",@"违法(暴力恐怖，违禁品等)"];
    /*
    //投诉须知
    UIButton *reportObject = [UIButton buttonWithType:UIButtonTypeSystem];
    reportObject.bounds = CGRectMake(0, 0, 60, 20);
    reportObject.center = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height - 35 - 64);
    reportObject.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [reportObject setTitle:@"投诉须知" forState:UIControlStateNormal];
    [reportObject setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [reportObject addTarget:self action:@selector(reportSb:) forControlEvents:UIControlEventTouchUpInside];
    [self.reportTable addSubview:reportObject];
     */
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contents.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"请选择投诉原因";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.contents objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.content = [self.contents objectAtIndex:indexPath.row];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要投诉吗?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.delegate = self;
    alert.tag = 10000;
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10000) {
        if (buttonIndex == 0) {
            
        }else{
            [self reportRequestWithContent:self.content];
            
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}
#pragma -mark 投诉须知
- (void)reportSb:(id)sender{
    NFReportTipsVC *vc = [[NFReportTipsVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma -mark 举报接口
- (void)reportRequestWithContent:(NSString *)content{
    
    [HudTool showLoadingHudInView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的投诉已提交审核，我们会尽快处理。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 10001;
        alert.delegate = self;
        [alert show];
    });
    

    
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
