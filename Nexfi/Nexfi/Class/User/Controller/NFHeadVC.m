//
//  NFHeadVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UnderdarkUtil.h"
#import "NFHeadVC.h"
#import "FCHeadCollectionCell.h"
#import "FCPersonCell.h"
#import "FCHeadAddCollectionCell.h"
@interface NFHeadVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic, assign)NSInteger nowRow;//标示 点击哪一个item

@end

@implementation NFHeadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self initView];
    
    [self setBaseVCAttributesWith:@"头像" left:nil right:@"保存" WithInVC:self];

    
    self.nowRow = -1;//区别于indexPath

}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _dataArr;
}
- (void)initView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(70 , 70);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    for (int i = 0; i < 14; i++) {
        UIImage *image;
        if (i<8) {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"img_head_0%d",i+2]];
        }else{
            image = [UIImage imageNamed:[NSString stringWithFormat:@"img_head_%d",i+2]];
        }
        [self.dataArr addObject:image];
    }
    
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerNib:[UINib nibWithNibName:@"FCHeadCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    FCHeadCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.item == _dataArr.count) {
        [collectionView registerNib:[UINib nibWithNibName:@"FCHeadAddCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"addCell"];
        FCHeadAddCollectionCell *cells = [collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:indexPath];
        [cells.addTribe setTitle:@"" forState:UIControlStateNormal];
        [cells.addTribe setBackgroundImage:[UIImage imageNamed:@"102"] forState:UIControlStateNormal];
        [cells.addTribe addTarget:self action:@selector(addTribeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cells;
        
    }
    
    //点击哪一行 标示哪一行
    if (self.nowRow == indexPath.row) {
        cell.backView.hidden = NO;
    }else{
        cell.backView.hidden = YES;
    }
    //    cell.backgroundColor = [UIColor blueColor];
    cell.headImg.tag = 10000 + indexPath.item;
    
    UIImage *image = [_dataArr objectAtIndex:indexPath.item];

    cell.headImg.image = image;
    
    
    
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(70, 70);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    FCHeadCollectionCell *cell = (FCHeadCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    if (self.delegate&&[self.delegate respondsToSelector:@selector(imgClick:)]) {
//        [self.delegate imgClick:cell];
//    }
    //刷新和展示点击item 展示的状态
    [self refreshSelectStatusAndShowWithIndexPath:indexPath];
    
    
}
- (void)refreshSelectStatusAndShowWithIndexPath:(NSIndexPath *)indexPath{
    
    for (int i = 0; i < _dataArr.count; i ++) {
        FCHeadCollectionCell *cell = (FCHeadCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        cell.backView.hidden = YES;
    }
    
    FCHeadCollectionCell *cell = (FCHeadCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.backView.hidden = NO;
    
    self.nowRow = indexPath.row;
}

- (void)addTribeClick:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"修改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [sheet showInView:self.view];
}
#pragma mark - image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    [self.dataArr addObject:image];
    
//    [self refreshSelectStatusAndShowWithIndexPath:[NSIndexPath indexPathForItem:self.dataArr.count -1 inSection:0]];
    [self.collectionView reloadData];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //头像
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

- (void)RightBarBtnClick:(id)sender{
    if (self.nowRow == -1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
//    FCHeadCollectionCell *cell = (FCHeadCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.nowRow inSection:0]];
    
    UserModel *user = [[UserManager shareManager]getUser];
//    NSData *data = UIImageJPEGRepresentation(cell.headImg.image, 1);
//    user.headImg = cell.headImg.image;
//    user.headImgStr = [data base64Encoding];
    if (self.nowRow<8) {
        user.headImgPath = [NSString stringWithFormat:@"img_head_0%ld",self.nowRow+2];
    }else{
        user.headImgPath = [NSString stringWithFormat:@"img_head_%ld",self.nowRow+2];
    }
    NSLog(@"headIm ==== %@",user.headImgPath);
    [[UserManager shareManager]loginSuccessWithUser:user];
    //更新数据库用户数据
    [[SqlManager shareInstance]updateUserName:user];
    
    if ([UnderdarkUtil share].node.links.count > 0) {
        for (int i = 0; i < [UnderdarkUtil share].node.links.count; i++) {
            id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
            [myLink sendData:[[UnderdarkUtil share].node sendMsgWithMessageType:eMessageType_UpdateUserInfo]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
