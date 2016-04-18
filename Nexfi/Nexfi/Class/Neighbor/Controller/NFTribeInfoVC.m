//
//  FNTribeInfoVC.m
//  Nexfi
//
//  Created by fyc on 16/4/14.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFTribeInfoVC.h"
#import "NFTribeInfoCell.h"
#import "NeighbourVC.h"

@interface NFTribeInfoVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain)UITableView *tribeTable;
@property (nonatomic, retain)NSMutableArray *handleByUsers;

@end

@implementation NFTribeInfoVC
- (NSMutableArray *)handleByUsers{
    if (!_handleByUsers) {
        _handleByUsers = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _handleByUsers;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:@"聊天信息" left:nil right:nil WithInVC:self];
    
    self.tribeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
    self.tribeTable.delegate = self;
    self.tribeTable.dataSource = self;
    self.tribeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tribeTable];

    
    [self getHandleUsers];
}
- (void)getHandleUsers{
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[NeighbourVC class]]) {
            NeighbourVC *NeighbourVc = (NeighbourVC *)vc;
            self.handleByUsers = NeighbourVc.handleByUsers;
            
        }
    }
    
    [self.handleByUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UserModel *user = (UserModel *)obj;
        if (![user.userId isEqualToString:[[UserManager shareManager]getUser].userId]) {
            [self.handleByUsers addObject:[[UserManager shareManager]getUser]];
        }
    }];
}
#pragma mark - table
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 0.1;
//    }
//    return 3;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.handleByUsers.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NFTribeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFTribeInfoCell"
                             ];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"NFTribeInfoCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UserModel *user = self.handleByUsers[indexPath.row];
    cell.userModel = user;
    
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
