//
//  SendFileVC.m
//  Nexfi
//
//  Created by fyc on 16/9/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "SendFileVC.h"
#import "NeighbourVC.h"
#import "NFTribeInfoCell.h"
#import "UnderdarkUtil.h"

@interface SendFileVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain)UITableView *sendObjectTable;
@property (nonatomic, retain)NSMutableArray *sendObjectList;

@end

@implementation SendFileVC
- (NSMutableArray *)sendObjectList{
    if (!_sendObjectList) {
        _sendObjectList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _sendObjectList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:@"聊天信息" left:nil right:nil WithInVC:self];
    
    self.sendObjectTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64) style:UITableViewStylePlain];
    self.sendObjectTable.delegate = self;
    self.sendObjectTable.dataSource = self;
    self.sendObjectTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.sendObjectTable];
    

    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [self getHandleUsers];
    
    [super viewWillAppear:animated];
}
//获取好友群里所有的好友
- (void)getHandleUsers{
    //好友
    self.sendObjectList = [[NSMutableArray alloc]initWithArray:[UnderdarkUtil share].node.neighbourVc.handleByUsers];


    //群聊
    UserModel *user = [[UserModel alloc]init];
    user.userNick = @"群聊";
    user.userAvatar = @"qunliao";
    [self.sendObjectList insertObject:user atIndex:0];
    [self.sendObjectTable reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sendObjectList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NFTribeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NFTribeInfoCell"
                             ];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"NFTribeInfoCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UserModel *user = self.sendObjectList[indexPath.row];
    cell.userModel = user;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        UserModel *user = self.sendObjectList[indexPath.row];

        dispatch_async(dispatch_get_main_queue(), ^{
            //Alert
            [[[ForwardAlert alloc]initWithTitle:user.userNick images:@[user.userAvatar] content:[NSString stringWithFormat:@"[文件]%@",self.currentFileModel.fileName] contentType:Content_Text buttonHandler:^(NSInteger buttonClickIndex) {
                if (buttonClickIndex == 1) {
                    
                    self.currentFileModel.fileSize = [NSString stringWithFormat:@"%@",[NexfiUtil fileSizeWithUnitAtPath:self.currentFileModel.fileAbsolutePath]];
                    NSData *voiceData = [[NSData alloc]initWithContentsOfFile:self.currentFileModel.fileAbsolutePath];
//                    [[NSData alloc]initWithContentsOfURL:[NSURL fileURLWithPath:self.currentFileModel.fileAbsolutePath]];
                    self.currentFileModel.fileData = [voiceData base64Encoding];
                    
                    UserModel *user = self.sendObjectList[indexPath.row];
                    
                    //0群聊 其他单聊
                    indexPath.row == 0?[self allUserChatWithUserModel:user]:[self singleChatWithUserModel:user];
                }
            }] show];
            
        });
    });

    //alert

    
}
#pragma mark -单聊
- (void)singleChatWithUserModel:(UserModel *)user{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
        
        NSData *newData;
        PersonMessage *msg = [[PersonMessage alloc]init];
        NSString *deviceUDID = [NexfiUtil uuid];
        
        FileMessage *fileMessage = [[FileMessage alloc]init];
        fileMessage.fileData = self.currentFileModel.fileData;//消息数据
        fileMessage.isRead = @"1";//已读未读
        fileMessage.fileName = self.currentFileModel.fileName;
        NSString *pathExtation = [[self.currentFileModel.fileName componentsSeparatedByString:@"."] lastObject];
        fileMessage.fileType = pathExtation;
        
        NSDictionary *fileDic = [NexfiUtil getSaveFilePathWithFileType:pathExtation];
        [[NSData dataWithBase64EncodedString:self.currentFileModel.fileData] writeToFile:fileDic[@"fullPath"] atomically:YES];
        fileMessage.filePath = fileDic[@"partPath"];
        
        fileMessage.fileSize = self.currentFileModel.fileSize;
        msg.fileMessage = fileMessage;
        
        msg.messageBodyType = eMessageBodyType_File;
        msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        msg.receiver = user.userId;//发送对像
        msg.msgId = deviceUDID;//msgId
        msg.userMessage = [[UserManager shareManager]getUser];
        
        msg.messageType = eMessageType_SingleChat;
        newData = [NSJSONSerialization dataWithJSONObject:msg.mj_keyValues options:0 error:0];
        
        
        //插入数据库
        [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:user WithMsg:msg];
        
        
        return newData;
        
    }];
    
    //发送消息
    for (int i = 0; i < [UnderdarkUtil share].node.links.count; i ++) {
        id<UDLink>myLink = [UnderdarkUtil share].node.links[i];
        if ([[NSString stringWithFormat:@"%lld",myLink.nodeId] isEqualToString:user.nodeId]) {
            [myLink sendData:result];
        }
    }
    
}
#pragma mark -群聊
- (void)allUserChatWithUserModel:(UserModel *)user{

    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
        TribeMessage *msg = [[TribeMessage alloc]init];
        NSString *deviceUDID = [NexfiUtil uuid];
        
        FileMessage *fileMessage = [[FileMessage alloc]init];
        fileMessage.fileData = self.currentFileModel.fileData;//消息数据
        fileMessage.isRead = @"1";//已读未读
        fileMessage.fileName = self.currentFileModel.fileName;
        NSString *pathExtation = [[self.currentFileModel.fileName componentsSeparatedByString:@"."] lastObject];
        fileMessage.fileType = pathExtation;
        
        NSDictionary *fileDic = [NexfiUtil getSaveFilePathWithFileType:pathExtation];
        [[NSData dataWithBase64EncodedString:self.currentFileModel.fileData] writeToFile:fileDic[@"fullPath"] atomically:YES];
        fileMessage.filePath = fileDic[@"partPath"];
        
        fileMessage.fileSize = self.currentFileModel.fileSize;
        msg.fileMessage = fileMessage;
        
        msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        msg.messageBodyType = eMessageBodyType_File;//文本类型
        msg.msgId = deviceUDID;//msgId
        
        msg.userMessage = [[UserManager shareManager]getUser];//json
        
        msg.messageType = eMessageType_AllUserChat;
        
        NSData *newData;
        
        newData = [NSJSONSerialization dataWithJSONObject:msg.mj_keyValues options:0 error:0];
        
        //插入数据库
        [[SqlManager shareInstance]insertAllUser_ChatWith:[[UserManager shareManager]getUser] WithMsg:msg];
            
        return newData;
        
    }];
    
    //发送消息
    [[UnderdarkUtil share].node allUserChatWithFrame:result];
    
}
#pragma -mark 获取当前时间
-(NSString *)getDateWithFormatter:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", strDate);
    return strDate;
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
