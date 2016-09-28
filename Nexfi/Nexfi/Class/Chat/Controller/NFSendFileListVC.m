//
//  NFSendFileListVC.m
//  Nexfi
//
//  Created by fyc on 16/9/26.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFSendFileListVC.h"
#import "NFTribeInfoCell.h"
@interface NFSendFileListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain)UITableView *fileTable;
@end

@implementation NFSendFileListVC
- (UITableView *)fileTable{
    if (!_fileTable) {
        _fileTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
        _fileTable.delegate = self;
        _fileTable.dataSource = self;
        //    [fileTable registerNib:[UINib nibWithNibName:@"FileKindCell" bundle:nil] forCellReuseIdentifier:@"FileKindCell"];
        
        _fileTable.tableFooterView = [[UIView alloc]init];
    }
    return _fileTable;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseVCAttributesWith:@"历史文件" left:@"title-icon-向左返回.png" right:@"发送" WithInVC:self];
    
    [self.view addSubview:self.fileTable];
    [self.fileTable deselectRowAtIndexPath:self.fileTable.indexPathForSelectedRow animated:YES];
    [self.fileTable setEditing:YES animated:NO];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileList.count;
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
    FileModel *file = self.fileList[indexPath.row];
    cell.nameLa.text = file.fileName;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode == FileListModeMultipleSelection) {
        return;
    }
    else if (self.mode == FileListModeSingleSelection) {
        // 取消选中之前已选中的 cell
        NSMutableArray *selectedRows = [[tableView indexPathsForSelectedRows] mutableCopy];
        [selectedRows removeObject:indexPath];
        for (NSIndexPath *indexPath in selectedRows) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == FileListModeMultipleSelection || self.mode == FileListModeSingleSelection) {
        return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.mode == SPContactListModeNormal) {
//        NSString *sectionKey = self.sortedSectionTitles[(NSUInteger)indexPath.section];
//        NSMutableArray *array = self.sections[sectionKey];
//        Account *account = array[(NSUInteger)indexPath.row];
//        
//        [array removeObjectAtIndex:indexPath.row];
//        
//        YWPerson *person = [AccountManager getPersonWithAccount:account];
//        [[SPContactManager defaultManager] removeContact:person];
//        
//        [tableView deleteRowsAtIndexPaths:@[indexPath]
//                         withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
}

- (void)RightBarBtnClick:(id)sender{
    FileModel *file = [self.fileList objectAtIndex:self.fileTable.indexPathForSelectedRow.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendFile:)]) {
        [self.delegate sendFile:file];
    }
}

- (void)leftBarBtnClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
