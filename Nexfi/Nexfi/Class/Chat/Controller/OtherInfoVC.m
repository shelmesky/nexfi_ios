//
//  OtherInfoVC.m
//  Nexfi
//
//  Created by fyc on 16/4/17.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "OtherInfoVC.h"

#import "FCPersonCell.h"
#import "UserManager.h"
#import "FCPersonHeadCell.h"
#import "FCTabHeadView.h"
#import "NFHeadView.h"

@interface OtherInfoVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NFHeadViewDelegate>

@property (nonatomic, strong)UITableView *userInfoTable;
@property (nonatomic, strong)NSArray *data;
@property (nonatomic, strong)NFHeadView *headView;

@end

@implementation OtherInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:[NSString stringWithFormat:@"%@的信息",self.user.userName] left:nil right:nil WithInVC:self];
    self.data = @[@"昵称",@"年龄",@"性别"];
    
    [self initView];
    
    
    
}
- (void)initView{
    
    int width = SCREEN_SIZE.width;
    float nav = NAV_HEIGHT;
    int height = nav + 150;
    
    _headView = [[NFHeadView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    _headView.exclusiveTouch = YES;
    _headView.delegate = self;
    
    self.userInfoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height) style:UITableViewStyleGrouped];
    self.userInfoTable.delegate = self;
    self.userInfoTable.dataSource = self;
    [self.view addSubview:self.userInfoTable];
    self.userInfoTable.tableHeaderView = _headView;
    
}
- (void)imgClick:(id)sender{
  
}
- (void)viewWillAppear:(BOOL)animated{
    [self.userInfoTable reloadData];
    if ([[UserManager shareManager]getUser]) {
        //        NSData *data = [[NSData alloc]initWithBase64EncodedString:[[UserManager shareManager]getUser].headImgStr];
        //        _headView.userImg.image = [UIImage imageWithData:data];
        UIImage *img = [UIImage imageNamed:[[UserManager shareManager]getUser].headImgPath];
        _headView.userImg.image = img;
    }
    [super viewWillAppear:animated];
}
#pragma mark - table
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.data.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FCPersonCell *cells =  [tableView dequeueReusableCellWithIdentifier:@"FCPersonCell"];
    if (!cells) {
        cells =[[[NSBundle mainBundle]loadNibNamed:@"FCPersonCell" owner:self options:nil] objectAtIndex:0];
        cells.selectionStyle = UITableViewCellSelectionStyleNone;
//        cells.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    cells.pTitle.text = _data[indexPath.row];
    if (self.user) {
        cells.user = self.user;

    }
    
    return cells;
    

}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 0;
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
