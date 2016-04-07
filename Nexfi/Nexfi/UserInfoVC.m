//
//  UserInfoVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "UserInfoVC.h"
#import "FCPersonCell.h"
#import "UserManager.h"
#import "FCPersonHeadCell.h"
#import "FCCongureInfoVC.h"
#import "FCConfigureDateVC.h"
#import "FCTabHeadView.h"
#import "NFHeadView.h"
#import "NFHeadVC.h"
@interface UserInfoVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,FCTabHeadViewDelegate>

@property (nonatomic, strong)UITableView *userInfoTable;
@property (nonatomic, strong)NSArray *data;
@property (nonatomic, strong)NFHeadView *headView;

@end

@implementation UserInfoVC

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
    if ([[UserManager shareManager]getUser]) {
        _headView.userImg.image = [UIImage imageWithData:[[UserManager shareManager]getUser].userHead];
    }
    
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
    [super viewWillAppear:animated];
}
#pragma mark - table
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0){
        FCPersonCell *cells =  [tableView dequeueReusableCellWithIdentifier:@"FCPersonCell"];
        if (!cells) {
            cells =[[[NSBundle mainBundle]loadNibNamed:@"FCPersonCell" owner:self options:nil] objectAtIndex:0];
            cells.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cells.pTitle.text = _data[indexPath.row];
        cells.user = [[UserManager shareManager] getUser];
        
        return cells;
    }
    FCPersonHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCPersonHeadCell"];
    if (!cell) {
        cell =[[[NSBundle mainBundle]loadNibNamed:@"FCPersonHeadCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //第一行cell
    cell.title.text = _data[indexPath.row];
    UserModel *user = [[UserManager shareManager] getUser];
    if (user.userHead) {
        cell.pHead.image = [UIImage imageWithData:user.userHead];
    }

    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
//        case 0://头像
//        {
//            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"修改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
//            sheet.tag = indexPath.row;
//            [sheet showInView:self.view];
//            
//            break;
//        }
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 3;
}
#pragma mark - image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    UserModel *user = [[UserManager shareManager]getUser];
    user.userHead = UIImageJPEGRepresentation(image, 1);
    NSLog(@"   %@",user.userHead);
    [[UserManager shareManager]loginSuccessWithUser:user];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    FCPersonHeadCell *cell = [self.userInfoTable cellForRowAtIndexPath:indexPath];
//    cell.pHead.image = image;
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
    
    else if (actionSheet.tag == 3){
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
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:3 inSection:0];
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
