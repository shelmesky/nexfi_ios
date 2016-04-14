//
//  SelfVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SelfVC.h"

#import "UserInfoVC.h"
#import "FCPersonCell.h"
#import "UserManager.h"
#import "FCPersonHeadCell.h"
#import "FCCongureInfoVC.h"
#import "FCConfigureDateVC.h"
#import "FCTabHeadView.h"
#import "NFHeadView.h"
#import "NFHeadVC.h"

@interface SelfVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NFHeadViewDelegate>

@property (nonatomic, strong)UITableView *userInfoTable;
@property (nonatomic, strong)NSArray *data;
@property (nonatomic, strong)NFHeadView *headView;

@end

@implementation SelfVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:@"我的信息" left:nil right:nil WithInVC:self];
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
    NFHeadVC *vc = [[NFHeadVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [self.userInfoTable reloadData];
    if ([[UserManager shareManager]getUser]) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:[[UserManager shareManager]getUser].headImgStr];
        _headView.userImg.image = [UIImage imageWithData:data];
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
    if (indexPath.section == 0){
        FCPersonCell *cells =  [tableView dequeueReusableCellWithIdentifier:@"FCPersonCell"];
        if (!cells) {
            cells =[[[NSBundle mainBundle]loadNibNamed:@"FCPersonCell" owner:self options:nil] objectAtIndex:0];
            cells.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        cells.pTitle.text = _data[indexPath.row];
        cells.user = [[UserManager shareManager] getUser];
        
        return cells;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orginalCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"orginalCell"];
    }
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    UIButton *go = [UIButton buttonWithType:UIButtonTypeSystem];
    go.bounds = CGRectMake(0, 0, 230, 30);
    go.center = CGPointMake(SCREEN_SIZE.width/2, 24);
    [go setTitle:@"去看看" forState:UIControlStateNormal];
    [go setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cell.contentView addSubview:go];
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0://昵称
            {
                FCCongureInfoVC *vc = [[FCCongureInfoVC alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                
                break;
            }
            case 1://年龄
            {
                FCConfigureDateVC *vc = [[FCConfigureDateVC alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2://性别
            {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"修改性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
                sheet.tag = indexPath.row;
                [sheet showInView:self.view];
                break;
            }
            default:
                break;
        }
        
    }
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
#pragma mark - image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    
    _headView.userImg.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //头像
    if (actionSheet.tag == 0) {
        if (buttonIndex <= 1) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
            if (buttonIndex == 0) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }else{
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    
    else if (actionSheet.tag == 2){
        if (buttonIndex == 2) {
            return;
        }
        //1为男，2为女
        NSString *gender = buttonIndex==0 ? @"1" : @"2";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [self modifyGender:gender];
            UserModel *user = [[UserManager shareManager]getUser];
            user.sex = gender;
            [[UserManager shareManager]loginSuccessWithUser:user];
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:2 inSection:0];
            FCPersonCell *cell = [self.userInfoTable cellForRowAtIndexPath:indexpath];
            cell.user = user;
        });
        
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
