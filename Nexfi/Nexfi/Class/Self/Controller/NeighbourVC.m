//
//  NeighbourVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UnderdarkUtil.h"

#import "NFNearbyUserCell.h"
#import "NeighbourVC.h"

@interface NeighbourVC ()<UITableViewDataSource,UITableViewDelegate,NFNearbyUserCellDelegate>

@property (nonatomic,strong) UITableView *usersTable;
@property (nonatomic,strong) NSMutableArray *nearbyUsers;
@property (nonatomic,strong) NSMutableArray *handleByUsers;


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
//    [UnderdarkUtil share].node.controller = self;
    
    [[UnderdarkUtil share].node start];
    

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.usersTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-64) style:UITableViewStyleGrouped];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    self.usersTable.rowHeight = 60;
    [self.view addSubview:self.usersTable];
    
    [self.usersTable registerNib:[UINib nibWithNibName:@"NFNearbyUserCell" bundle:nil] forCellReuseIdentifier:@"NFNearbyUserCell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"userInfo" object:nil];
    
}
#pragma -mark NSNotification 用户信息更新
- (void)refreshTable:(NSNotification *)notify{
    NSDictionary *userDic = notify.userInfo[@"user"];
    //过滤多余的用户信息
    if (self.nearbyUsers.count == 0) {
        [self.nearbyUsers addObject:userDic];
    }else{
        for (NSDictionary *dic in self.nearbyUsers) {
            if (![userDic isEqualToDictionary:dic]) {
                [self.nearbyUsers addObject:userDic];
            }
        }
    }

    
    [self handleNearByUsers];
    
}
- (void)handleNearByUsers{
    for (NSDictionary *dic in self.nearbyUsers) {
        UserModel *user = [[UserModel alloc]initWithaDic:dic];
        [self.handleByUsers addObject:user];
    }
    
    [self.usersTable reloadData];
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
