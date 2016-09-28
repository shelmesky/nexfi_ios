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
#import "TableViewHeaderView.h"
#import "FileCell.h"
#import "FileKindCell.h"

@interface DoucmentListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _selectIndex;
    BOOL _isScrollDown;
}
@property (nonatomic, retain)UITableView *fileTable;
@property (nonatomic, retain)UITableView *fileKindTable;
@property (nonatomic, retain)NSMutableArray *fileList;
@property (nonatomic, retain)NSMutableDictionary *fileDic;
@end

@implementation DoucmentListVC
- (NSMutableArray *)fileList{
    if (!_fileList) {
        _fileList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _fileList;
}
- (UITableView *)fileKindTable{
    if (!_fileKindTable) {
        _fileKindTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 80, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
        _fileKindTable.delegate = self;
        _fileKindTable.dataSource = self;
        [_fileKindTable registerNib:[UINib nibWithNibName:@"FileKindCell" bundle:nil] forCellReuseIdentifier:@"FileKindCell"];
        
        _fileKindTable.tableFooterView = [[UIView alloc]init];
    }
    return _fileKindTable;
}
- (UITableView *)fileTable{
    if (!_fileTable) {
        _fileTable = [[UITableView alloc]initWithFrame:CGRectMake(80, 0, SCREEN_SIZE.width - 80, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
        _fileTable.delegate = self;
        _fileTable.dataSource = self;
        _fileTable.separatorColor = [UIColor clearColor];
        [_fileTable registerNib:[UINib nibWithNibName:@"FileCell" bundle:nil] forCellReuseIdentifier:@"FileCell"];
        
        _fileTable.tableFooterView = [[UIView alloc]init];
    }
    return _fileTable;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.fileKindTable) {
        return 1;
    }else{
        return self.fileDic.allKeys.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.fileKindTable) {
        return self.fileDic.allKeys.count;
    }
    NSMutableArray *arr = [[self.fileDic allValues] objectAtIndex:section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.fileKindTable) {
        FileKindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileKindCell"];
        cell.name.text = [[self.fileDic allKeys] objectAtIndex:indexPath.row];
        return cell;
    }else{
        FileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
        FileModel *file = [self.fileDic allValues][indexPath.section][indexPath.row];
        cell.model = file;
        return cell;
    }

    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.fileTable)
    {
        return 20;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.fileTable)
    {
        TableViewHeaderView *view = [[TableViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 20)];
        view.name.text = [self.fileDic allKeys][section];
        return view;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fileKindTable == tableView) {
        
 
        [UIView animateWithDuration:0.3 animations:^{
            [self.fileKindTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } completion:^(BOOL finished) {
            [self.fileTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
        
    }else{
        
        DocumentLoadVC *vc = [[DocumentLoadVC alloc]init];
        FileModel *model = [self.fileDic allValues][indexPath.section][indexPath.row];
        vc.title = model.fileName;
        model.fileAbsolutePath = [NSHomeDirectory() stringByAppendingPathComponent:model.partPath];
        vc.currentFileModel = model;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fileTable == tableView) {
        return YES;
    }
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fileTable == tableView) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fileTable == tableView) {
        return @"删除";
    }
    return @"";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FileModel *model = [self.fileDic allValues][indexPath.section][indexPath.row];
    
    //移除数据源
    for (int i = 0; i < self.fileDic.allKeys.count; i ++ ) {
        NSString *key = [[self.fileDic allKeys] objectAtIndex:i];
        NSArray *temArr = [self.fileDic objectForKey:key];
        if ([temArr containsObject:model]) {
            NSMutableArray *temA = [[NSMutableArray alloc]initWithArray:temArr];
            [temA removeObject:model];
            [self.fileDic removeObjectForKey:key];
            if (temA.count != 0) {
                [self.fileDic setObject:temA forKey:key];
            }
        }
    }
    //删除本地
    NSMutableArray *copyFileList = [[SqlManager shareInstance]getCopyFileData];
    for (FileModel *file in copyFileList) {
        if ([file.fileName isEqualToString:model.fileName]) {
            //删除数据库某个文件
            [[SqlManager shareInstance]deleteCopyFile:model];
            
            NSString *path = model.fileData?[[NSFileManager getDocumentDirectoryPath] stringByAppendingPathComponent:model.partPath]:[NSHomeDirectory() stringByAppendingPathComponent:model.partPath];
            if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
                if ([[NSFileManager defaultManager]removeItemAtPath:path error:nil]) {
                    NSLog(@"移除本地文件成功");
                }
                
            }
        }
        
    }
    
    if ([copyFileList containsObject:model]) {
        [copyFileList removeObject:model];
        //删除数据库某个文件
        [[SqlManager shareInstance]deleteCopyFile:model];
    }

    [tableView reloadData];
    [self.fileKindTable reloadData];
    
}
// TableView分区标题即将展示
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section
{
    // 当前的tableView是RightTableView，RightTableView滚动的方向向上，RightTableView是用户拖拽而产生滚动的（（主要判断RightTableView用户拖拽而滚动的，还是点击LeftTableView而滚动的）
    if ((self.fileTable == tableView) && !_isScrollDown && self.fileTable.dragging)
    {
        [self selectRowAtIndexPath:section];
    }
    
}

// TableView分区标题展示结束
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // 当前的tableView是RightTableView，RightTableView滚动的方向向下，RightTableView是用户拖拽而产生滚动的（（主要判断RightTableView用户拖拽而滚动的，还是点击LeftTableView而滚动的）
    if ((self.fileTable == tableView) && _isScrollDown && self.fileTable.dragging)
    {
        [self selectRowAtIndexPath:section + 1];
    }
}
//滑动右面table刷新左面table
- (void)selectRowAtIndexPath:(NSInteger)index
{
    //防止超出滑动row后程序crash
    if (self.fileDic.allKeys.count - 1 < index) {
        return;
    }
    [self.fileKindTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [self docLsCreateSourceData];
    
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:@"历史文件" left:nil right:nil WithInVC:self];
    
    // 如果是 从appDelegate里面，跳转过来， 主要用于打开别的软件的共享过来的文档；
    [self.view addSubview:self.fileTable];
    [self.view addSubview:self.fileKindTable];
    
    
//    [self.fileKindTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}
#pragma mark - 生成数据源
/** 生成数据源 */
- (void)docLsCreateSourceData {


    //{@"文档":[文档1的data，文档2的data]}
    self.fileDic = [[NSMutableDictionary alloc]initWithCapacity:0];

    
    NSMutableArray *copyFileList = [[SqlManager shareInstance]getCopyFileData];
    
    for (FileModel *file in copyFileList) {
        NSArray *arr = self.fileDic[file.fileKind];
        if (!arr) {
            NSMutableArray *fileList = [[NSMutableArray alloc]initWithCapacity:0];
            [fileList addObject:file];
            [self.fileDic setObject:fileList forKey:file.fileKind];
        }else{
            NSMutableArray *fileList = [[NSMutableArray alloc]initWithArray:arr];
            [fileList addObject:file];
            [self.fileDic setObject:fileList forKey:file.fileKind];
        }
    }
    
    
    [self.fileKindTable reloadData];
    [self.fileTable reloadData];
}
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static CGFloat beforeOffsetY = 0;
    if (self.fileTable == (UITableView *)scrollView) {
        _isScrollDown = beforeOffsetY < scrollView.contentOffset.y;
        beforeOffsetY = scrollView.contentOffset.y;
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
