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
    

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.usersTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-64) style:UITableViewStyleGrouped];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    self.usersTable.rowHeight = 60;
    self.usersTable.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
    [self.view addSubview:self.usersTable];
    
    [self.usersTable registerNib:[UINib nibWithNibName:@"NFNearbyUserCell" bundle:nil] forCellReuseIdentifier:@"NFNearbyUserCell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"userInfo" object:nil];
    
    //检测是否接收到数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getText:) name:@"singleChat" object:nil];
    
}
#pragma -mark 获取接收到的数据
- (void)getText:(NSNotification *)notify{
    NSDictionary *text = notify.userInfo[@"text"];
    NSString *nodeId = notify.userInfo[@"nodeId"];

    PersonMessage *msg = [[PersonMessage alloc]initWithaDic:text];
    msg.nodeId = nodeId;
    if (msg.fileType != eMessageBodyType_Text && msg.file) {
        msg.pContent = msg.file;
    }
    UserModel *user = [[UserModel alloc]init];
    user.headImgStr = msg.senderFaceImageStr;
    user.userName = msg.senderNickName;
    user.userId = msg.sender;
    
    //保存聊天记录
    [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:user WithMsg:msg];
    //增加未读消息数量
    [[SqlManager shareInstance]addUnreadNum:[[UserManager shareManager]getUser].userId];
    
    
}
#pragma -mark NSNotification 用户信息更新
- (void)refreshTable:(NSNotification *)notify{
    NSDictionary *userDic = notify.userInfo[@"user"];
    NSString *nodeId = notify.userInfo[@"nodeId"];
    NSMutableDictionary *user = [[NSMutableDictionary alloc]initWithDictionary:userDic];
    [user removeObjectForKey:@"nodeId"];
    [user setObject:nodeId forKey:@"nodeId"];
    //过滤多余的用户信息
    
    UserModel *users = [[UserModel alloc]initWithaDic:user];

    
    if (self.handleByUsers.count == 0) {
        [self.handleByUsers addObject:users];
    }else{
        if (![self.handleByUsers containsObject:users]) {
            [self.handleByUsers addObject:users];
        }
    }
    
    [self.usersTable reloadData];
    
    
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
