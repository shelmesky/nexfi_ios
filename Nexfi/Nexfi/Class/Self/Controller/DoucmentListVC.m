//
//  DoucmentListVC.m
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "DoucmentListVC.h"
#import "FileModel.h"
#import "DocumentLoadVC.h"
@interface DoucmentListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain)UITableView *fileTable;
@property (nonatomic, retain)NSMutableArray *fileList;

@end

@implementation DoucmentListVC
- (NSMutableArray *)fileList{
    if (!_fileList) {
        _fileList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _fileList;
}
- (UITableView *)fileTable{
    if (!_fileTable) {
        _fileTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
        _fileTable.delegate = self;
        _fileTable.dataSource = self;
        [_fileTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _fileTable;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.fileList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    FileModel *file = self.fileList[indexPath.row];
    cell.textLabel.text = file.fileName;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DocumentLoadVC *vc = [[DocumentLoadVC alloc]init];
    FileModel *model = self.fileList[indexPath.row];
    vc.title = model.fileName;
    vc.currentFileModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self docLsCreateSourceData];
    
}
#pragma mark - 生成数据源
/** 生成数据源 */
- (void)docLsCreateSourceData {
    // 如果是 从appDelegate里面，跳转过来， 主要用于打开别的软件的共享过来的文档；
    [self.view addSubview:self.fileTable];
    if (_appFilePath.length) {
        FileModel *model = [[FileModel alloc] init];
        model.fileName  = [[_appFilePath componentsSeparatedByString:@"/"] lastObject];
        model.fileAbsolutePath = _appFilePath;
        [self.fileList addObject:model];
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
