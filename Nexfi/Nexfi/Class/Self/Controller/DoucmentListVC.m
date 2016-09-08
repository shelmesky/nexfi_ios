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
        NSLog(@"nod=====%@",model.fileAbsolutePath);
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
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:model];
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
    NSDictionary *fileDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"historyFiles"];
    
    NSMutableDictionary *files = fileDic?[[NSMutableDictionary alloc]initWithDictionary:fileDic]:[[NSMutableDictionary alloc]initWithCapacity:0];
    
    //查询本地要删除的文件 并作删除
    [files.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *fileDataArr = files[obj];
        for (NSData *data in fileDataArr) {
            if ([fileData isEqualToData:data]) {
                NSMutableArray *fileArr = [[NSMutableArray alloc]initWithArray:fileDataArr];
                [fileArr removeObject:data];
                [files removeObjectForKey:obj];
                if (fileArr.count != 0) {
                    [files setObject:fileArr forKey:obj];
                }
            }
        }
        
    }];
    //存储最终删除的数据
    NSDictionary *finallyFileDic = [NSDictionary dictionaryWithDictionary:files];
    
    [[NSUserDefaults standardUserDefaults]setObject:finallyFileDic forKey:@"historyFiles"];
    
    //移除tableView中的数据
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView reloadData];
    [self.fileKindTable reloadData];
    
    /*
     
    FileModel *model = [self.fileDic allValues][indexPath.section][indexPath.row];
 
    //移除数据源
    [self.fileList removeObject:model];
    
    //删除本地
    if (model.fileAbsolutePath) {
        [[NSFileManager defaultManager]removeItemAtPath:model.fileAbsolutePath error:nil];
        //删除本地文件记录
//        NSArray *saveFiles = [NSArray arrayWithArray:self.fileList];
        
        NSMutableArray *files = [[NSMutableArray alloc]initWithCapacity:0];
        for (FileModel *file in self.fileList) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:file];
            [files addObject:data];
        }
        NSArray *historyFiles = [NSArray arrayWithArray:files];

        [[NSUserDefaults standardUserDefaults]setObject:historyFiles forKey:@"historyFiles"];
        
    }

    //移除tableView中的数据
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    
    */
    
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

    /*
    NSMutableArray *files = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *historyFiles = [[NSUserDefaults standardUserDefaults]objectForKey:@"historyFiles"];
    for (NSData *data in historyFiles) {
        FileModel *file = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [files addObject:file];
    }
    
    self.fileList = files;
    */
    
    /*测试数据
    self.fileDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    for (int i = 0; i < 20; i ++ ) {
        NSMutableArray *arr3 = [[NSMutableArray alloc]initWithCapacity:0];
        for (int i = 0; i < 7; i ++ ) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [NSString stringWithFormat:@"jilei%d",i];
            [arr3 addObject:file];
        }
        [self.fileDic setObject:arr3 forKey:[NSString stringWithFormat:@"%d",i]];
    }
    */
    //{@"文档":[文档1的data，文档2的data]}
    self.fileDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    NSDictionary *fileDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"historyFiles"];
    
    NSMutableDictionary *files = fileDic?[[NSMutableDictionary alloc]initWithDictionary:fileDic]:[[NSMutableDictionary alloc]initWithCapacity:0];
    
    //{@"文档":[文档1，文档2]}
    [files.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *fileDataArr = files[obj];
        NSMutableArray *fileArr = [[NSMutableArray alloc]initWithCapacity:0];
        for (NSData *data in fileDataArr) {
            FileModel *file = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [fileArr addObject:file];
            [self.fileDic setObject:fileArr forKey:obj];
        }
        
    }];
    
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
