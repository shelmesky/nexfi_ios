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
#import "VertifyCodeVC.h"
#import "NFUserLocationVC.h"

#import "AppDelegate.h"

#import "RegisterVC.h"

@interface NeighbourVC ()<UITableViewDataSource,UITableViewDelegate,NFNearbyUserCellDelegate,MAMapViewDelegate>

@property (nonatomic, assign)BOOL reachable;
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

    [self setBaseVCAttributesWith:@"附近的人" left:@"067.png" right:@"060.png" WithInVC:self];
    //配置地图
//    [self initMapView];
    
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    //网络可用
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reachable = YES;
        });
    };
    //网络不可用
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reachable = NO;
        });
    };
    
    [reach startNotifier];

    
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
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"userInfo" object:nil];

    //检测蓝牙是否开启
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blueToothMsgFail:) name:@"blueToothFail" object:nil];
    
}
#pragma -mark 检查好友是否根连接数相等
- (void)inqueryFriend{
    
    double delayInSeconds = 100.0;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        NSLog(@"Grand Center Dispatch!");
        if (self.handleByUsers.count == [UnderdarkUtil share].node.links.count) {
            return;
        }
        for (id<UDLink>myLink in [UnderdarkUtil share].node.links) {
            for (UserModel *user in self.handleByUsers) {
                if (![user.nodeId isEqualToString:[NSString stringWithFormat:@"%lld",myLink.nodeId]]) {//如果有连接没显示好友 再请求一下
                    [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_requestUserInfo WithLink:myLink]];
                }
            }
        }
    });
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
- (void)refreshTable:(NSDictionary *)userJson{
    
    //获取到进度 进度消失
    WGradientProgress *pro = [WGradientProgress sharedInstance];
    [pro hide];
    
    
    NSDictionary *userDic = userJson[@"user"];
    NSString *nodeId = userJson[@"nodeId"];
    NSMutableDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:userDic[@"userMessage"]];

    
    UserModel *users = [UserModel mj_objectWithKeyValues:user];
    users.nodeId = nodeId;
    
    //所有用户id集合
    NSMutableArray *userIdList = [[NSMutableArray alloc]initWithCapacity:0];
    //所有nodeId的集合
    NSMutableArray *nodeIdList = [[NSMutableArray alloc]initWithCapacity:0];
    for (UserModel *user in self.handleByUsers) {
        [userIdList addObject:user.userId];
        [nodeIdList addObject:user.nodeId];
    }
    //过滤多余的用户信息
    NSString *update = userJson[@"update"];
    NSString *updateLocation = userJson[@"updateLocation"];
    
    if (update) {
        for (int i = 0; i < self.handleByUsers.count; i ++) {
            UserModel *user = [self.handleByUsers objectAtIndex:i];
            if ([user.userId isEqualToString:users.userId]) {
                [self.handleByUsers replaceObjectAtIndex:i withObject:users];
            }
        }
        if (updateLocation) {//更新位置之后  不用再做刷新动画
            NSLog(@"return");
            //更新地图里面好友位置
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateFriendInfo" object:nil];
            return;
        }
    }else{
        if (self.handleByUsers.count == 0) {
            [self.handleByUsers addObject:users];
        }else{
            if (![self.handleByUsers containsObject:users] && ![userIdList containsObject:users.userId]) {
                [self.handleByUsers addObject:users];
            }else if (![self.handleByUsers containsObject:users] && [userIdList containsObject:users.userId]){//蓝牙和wifi 同时开启 一个用户 两个nodeId
                
                /*
                NSDictionary *repeatUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"repeatUser"];
                NSMutableDictionary *repeatUsers = [[NSMutableDictionary alloc]initWithDictionary:repeatUser];
                NSMutableArray *nodes = repeatUsers[users.userId];
                if (!nodes) {
                    nodes = [NSMutableArray array];
                    [nodes addObject:users.nodeId];
                    repeatUsers[users.userId] = nodes;
                }else{
                    [nodes addObject:users.nodeId];
                    repeatUsers[users.userId] = nodes;
                }
                
                [[NSUserDefaults standardUserDefaults]setObject:repeatUsers forKey:@"repeatUser"];
                 */
                
            }
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
    

    
    //显示多少人
    self.navigationItem.title =  [NSString stringWithFormat:@"附近的人(%ld)",self.handleByUsers.count];
    
    
    //延迟100秒查询好友是否残缺
    [self inqueryFriend];
    
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
    
    /*
    UserModel *user = [[UserManager shareManager]getUser];

    if (user.phoneNumber) {//已经注册直接去私聊
        UserModel *to_user = [self.handleByUsers objectAtIndex:indexPath.row];
        NFSingleChatInfoVC *chat = [[NFSingleChatInfoVC alloc]init];
        chat.to_user = to_user;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        VertifyCodeVC *vc = [[VertifyCodeVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
     */
    
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
    
    /*
    UserModel *mySelf = [[UserManager shareManager]getUser];
    if (mySelf.phoneNumber) {
        UserModel *user = [self.handleByUsers objectAtIndex:indexPath.row];
        OtherInfoVC *otherVc= [[OtherInfoVC alloc]init];
        otherVc.user = user;
        [self.navigationController pushViewController:otherVc animated:YES];
    }else{
        RegisterVC *registerVc = [[RegisterVC alloc]init];
        [self.navigationController pushViewController:registerVc animated:YES];
    }
    */
    
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
- (void)leftBarBtnClick:(id)sender{
    NFUserLocationVC *vc = [[NFUserLocationVC alloc]init];
    vc.friendList = [[NSMutableArray alloc]initWithArray:self.handleByUsers];
    [self.navigationController pushViewController:vc animated:YES];
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
