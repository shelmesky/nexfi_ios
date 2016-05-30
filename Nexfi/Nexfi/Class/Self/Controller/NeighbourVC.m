//
//  NeighbourVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UnderdarkUtil.h"
#import "NFSingleChatInfoVC.h"
#import "NFNearbyUserCell.h"
#import "NeighbourVC.h"
#import "NFAllUserChatInfoVC.h"
#import "OtherInfoVC.h"

@interface NeighbourVC ()<UITableViewDataSource,UITableViewDelegate,NFNearbyUserCellDelegate>

@end

@implementation NeighbourVC
- (NSMutableArray *)nodeList{
    if (!_nodeList) {
        _nodeList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _nodeList;
}
- (NSMutableArray *)handleByUsers{
    if (!_handleByUsers) {
        _handleByUsers = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _handleByUsers;
}
- (NSMutableArray *)nearbyUsers{
    if (!_nearbyUsers) {
        _nearbyUsers = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _nearbyUsers;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setBaseVCAttributesWith:@"附近的人" left:nil right:@"群聊" WithInVC:self];

    
    [[UnderdarkUtil share].node start];
    [UnderdarkUtil share].node.neighbourVc = self;
    

    
    self.usersTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height-64 - 49) style:UITableViewStyleGrouped];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    self.usersTable.rowHeight = 60;
    self.usersTable.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
    [self.view addSubview:self.usersTable];
    
    [self.usersTable registerNib:[UINib nibWithNibName:@"NFNearbyUserCell" bundle:nil] forCellReuseIdentifier:@"NFNearbyUserCell"];
    

    
    //展示进度
    WGradientProgress *gradProg = [WGradientProgress sharedInstance];
    [gradProg showOnParent:self.navigationController.navigationBar position:WProgressPosDown];
    
    [self showProgress];
    //好友列表
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"userInfo" object:nil];

    //检测蓝牙是否开启
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blueToothMsgFail:) name:@"blueToothFail" object:nil];
    
}
- (void)showProgress{
    WGradientProgress *pro = [WGradientProgress sharedInstance];

    [pro setProgress:1.0];
    
}
#pragma -mark  蓝牙打开失败信息
- (void)blueToothMsgFail:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"蓝牙开启请求" message:@"此app需要通过蓝牙和其他用户进行通信" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });

    
}
#pragma -mark NSNotification 用户信息更新
- (void)refreshTable:(NSNotification *)notify{
    //获取到进度 进度消失
    WGradientProgress *pro = [WGradientProgress sharedInstance];
    [pro hide];
    
    NSDictionary *userDic = notify.userInfo[@"user"];
    NSString *nodeId = notify.userInfo[@"nodeId"];
    NSMutableDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:userDic[@"userMessage"]];
    
    UserModel *users = [UserModel mj_objectWithKeyValues:user];
    users.nodeId = nodeId;
    //过滤多余的用户信息
    NSString *update = notify.userInfo[@"update"];
    if (update) {
        
        for (int i = 0; i < self.handleByUsers.count; i ++) {
            UserModel *user = [self.handleByUsers objectAtIndex:i];
            if ([user.userId isEqualToString:users.userId]) {
                [self.handleByUsers replaceObjectAtIndex:i withObject:users];
            }
        }
        
        
    }else{
    

        if (self.handleByUsers.count == 0) {
                [self.handleByUsers addObject:users];
        }else{
            for (UserModel *user in self.handleByUsers) {
                if (![user.userId isEqualToString:users.userId] && ![self.handleByUsers containsObject:users]) {
                    [self.handleByUsers addObject:users];
                }
            }
//            if (![self.handleByUsers containsObject:users]) {
//                [self.handleByUsers addObject:users];
//            }
        }
        
        self.handleByUsers = (NSMutableArray *)[[self.handleByUsers reverseObjectEnumerator]allObjects];
        
        
    }
    
    //获取所有用户的nodeId
    [self getAllNodeId];
    
    [self.usersTable reloadData];
    
    //设置用户上线动画
    NSUInteger index = [self.handleByUsers indexOfObject:users];
    NFNearbyUserCell *cell = (NFNearbyUserCell *)[self.usersTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self playBounceAnimation:cell.nickNameLabel];
    
}
- (NSMutableArray *)getAllNodeId{
    for (UserModel *user in self.handleByUsers) {
        [self.nodeList addObject:user.nodeId];
    }
    return self.nodeList;
}
#pragma -mark 设置用户上线的动画
- (void)playBounceAnimation:(UILabel *)nameLa{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.values = @[@(1),@(1.5),@(0.9),@(0.5),@(1)];
    animation.duration = 0.7;
    animation.calculationMode = kCAAnimationCubic;
    
    [nameLa.layer addAnimation:animation forKey:@"playBounceAnimation"];
}
#pragma -mark 私聊
- (void)nearbyUserCellDidClickChatButtonForIndexPath:(NSIndexPath *)indexPath{
    UserModel *to_user = [self.handleByUsers objectAtIndex:indexPath.row];
    NFSingleChatInfoVC *chat = [[NFSingleChatInfoVC alloc]init];
    chat.to_user = to_user;
    [self.navigationController pushViewController:chat animated:YES];
}
#pragma mark - table
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 3;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserModel *user = [self.handleByUsers objectAtIndex:indexPath.row];
    OtherInfoVC *otherVc= [[OtherInfoVC alloc]init];
    otherVc.user = user;
    [self.navigationController pushViewController:otherVc animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.handleByUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NFNearbyUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFNearbyUserCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.indexPath = indexPath;
    UserModel *user = self.handleByUsers[indexPath.row];
    cell.user = user;
    return cell;
}
- (void)rightButtonPressed:(UIButton *)sender
{
    NFAllUserChatInfoVC *allUserVC = [[NFAllUserChatInfoVC alloc]init];
    allUserVC.peersCount = self.peesCount;
    [self.navigationController pushViewController:allUserVC animated:YES];
}
- (void)RightBarBtnClick:(id)sender{
    NFAllUserChatInfoVC *allUserVC = [[NFAllUserChatInfoVC alloc]init];
    allUserVC.peersCount = self.peesCount;
    [self.navigationController pushViewController:allUserVC animated:YES];
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
