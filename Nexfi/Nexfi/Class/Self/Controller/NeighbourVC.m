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

@interface NeighbourVC ()<UITableViewDataSource,UITableViewDelegate,NFNearbyUserCellDelegate>

@property (nonatomic, assign)BOOL reachable;
@property (nonatomic, assign)BOOL isNeedUpdate;;
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

    [self setBaseVCAttributesWith:@"附近的人" left:@"地图" right:@"群聊" WithInVC:self];
    
    [self initMapView];
    
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
- (void)showProgress{
    WGradientProgress *pro = [WGradientProgress sharedInstance];

    [pro setProgress:1.0];
    
}
#pragma -mark 初始化MapView
- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    
    self.mapView.showsCompass = NO;   //是否显示罗盘
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;  //跟随模式  持续更新用户定位
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES; //是否支持缩放
    //    self.mapView.zoomLevel = 12.0; //缩放级别
    //    self.mapView.zoomLevel = self.mapView.minZoomLevel;  //最小缩放级别
    //    [self.mapView setCompassImage:[UIImage imageNamed:@"bg-x@2x"]];//罗盘图片
    [self.view addSubview:self.mapView];
    
    //需要开启定位
    self.isNeedUpdate = YES;
    
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
        NSLog(@"userId === %@===nodeId ===== %@",user.userId,user.nodeId);
    }
    NSLog(@"usersId=====%@====nodesId=====%@",users.userId,users.nodeId);
    //过滤多余的用户信息
    NSString *update = userJson[@"update"];
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
    NSLog(@"11111111111111111111111111111");
    //设置用户上线动画
    NSUInteger index = [self.handleByUsers indexOfObject:users];
    NFNearbyUserCell *cell = (NFNearbyUserCell *)[self.usersTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self playBounceAnimation:cell.nickNameLabel];
    
    //显示多少人
    self.navigationItem.title =  [NSString stringWithFormat:@"附近的人(%d)",self.handleByUsers.count];
    
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
     
    /*
    UserModel *to_user = [self.handleByUsers objectAtIndex:indexPath.row];
    NFSingleChatInfoVC *chat = [[NFSingleChatInfoVC alloc]init];
    chat.to_user = to_user;
    [self.navigationController pushViewController:chat animated:YES];
     */

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
- (void)leftBarBtnClick:(id)sender{
    NFUserLocationVC *vc = [[NFUserLocationVC alloc]init];
    vc.friendList = self.nearbyUsers;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma -mark 地理位置编码
- (void)getFGocode:(NSString*)address{
    
}
#pragma mark - AMapSearchDelegate  地理位置编码  回调方法
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    
}
#pragma -mark 反地理位置编码
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    
}
#pragma -mark 反地理位置编码  回调方法
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    //response.regeocode
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    //    self.mapView.userTrackingMode = MAUserTrackingModeNone;  //不追踪用户的location更新
    
    
    //10分钟发送一次定位位置
    if (self.isNeedUpdate) {
        //更新用户信息
        UserModel *user = [[UserManager shareManager]getUser];
        user.lattitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.latitude];
        user.longitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
        [[UserManager shareManager]loginSuccessWithUser:user];
        
        self.isNeedUpdate = NO;
        
        NSTimeInterval second = 600.0f;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, second * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            self.isNeedUpdate = YES;
            if ([UnderdarkUtil share].node.links.count > 0) {
                for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
                    id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
                    [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UserLocationUpdate WithLink:myLink]];
                }
            }
        });
        dispatch_resume(timer);
    }
    
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
