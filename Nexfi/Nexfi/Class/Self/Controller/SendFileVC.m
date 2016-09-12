//
//  SendFileVC.m
//  Nexfi
//
//  Created by fyc on 16/9/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SendFileVC.h"
#import "NeighbourVC.h"
#import "NFTribeInfoCell.h"

@interface SendFileVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain)UITableView *sendObjectTable;
@property (nonatomic, retain)NSMutableArray *sendObjectList;

@end

@implementation SendFileVC
- (NSMutableArray *)sendObjectList{
    if (!_sendObjectList) {
        _sendObjectList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _sendObjectList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:@"聊天信息" left:nil right:nil WithInVC:self];
    
    self.sendObjectTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
    self.sendObjectTable.delegate = self;
    self.sendObjectTable.dataSource = self;
    self.sendObjectTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.sendObjectTable];
    
    UIBarButtonItem *addNew = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendFileToObject:)];
    self.navigationItem.rightBarButtonItem = addNew;
    
}
#pragma mark -发送文件
- (void)sendFileToObject:(id)sender{
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [self getHandleUsers];
    
    [super viewWillAppear:animated];
}
//获取好友群里所有的好友
- (void)getHandleUsers{
    //好友
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[NeighbourVC class]]) {
            NeighbourVC *NeighbourVc = (NeighbourVC *)vc;
            self.sendObjectList = [[NSMutableArray alloc]initWithArray:NeighbourVc.handleByUsers];
        }
    }
    //自己
    if (![self.sendObjectList containsObject:[[UserManager shareManager]getUser]]) {
        [self.sendObjectList addObject:[[UserManager shareManager]getUser]];
    }
    //群聊
    
    [self.sendObjectTable reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sendObjectList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NFTribeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFTribeInfoCell"
                             ];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"NFTribeInfoCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UserModel *user = self.sendObjectList[indexPath.row];
    cell.userModel = user;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

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
