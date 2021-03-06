//
//  ChatInfoVC.m
//  Nexify
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "Photo.h"
#import "FCMsgCell.h"
#import "UnderdarkUtil.h"
#import "NFSingleChatInfoVC.h"
#import "NexfiUtil.h"
#import "Message.h"
#import "NFChatCacheFileUtil.h"
#import "OtherInfoVC.h"
#import "NFReportObjectVC.h"
#import "DocumentLoadVC.h"
#import "FileModel.h"

#import "SenderTextCell.h"
#import "SenderAvatarCell.h"
#import "SenderFileCell.h"
#import "ReceiverFileCell.h"
#import "ReceiverAvatarCell.h"
#import "ReceiverVoiceCell.h"
#import "SenderVoiceCell.h"
#import "TextCell.h"
#import "ChatCell.h"


@interface NFSingleChatInfoVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,XMChatBarDelegate,FCMsgCellDelegate,MWPhotoBrowserDelegate,NodeDelegate,chatCellDelegate>
{
        //用来保存输入框中的信息
    NSMutableArray * _textArray;//消息数List
    BOOL sendOnce;//只发送一次
}
@property (nonatomic,assign) NSInteger count;
@property (strong, nonatomic) XMChatBar *chatBar;//工具栏
@property (nonatomic,strong) UITableView *tableView;//展示table
@property (nonatomic,strong) NSArray *historyMsgs;//历史数据List
@property (nonatomic,strong) NSMutableArray *mwPhotos;//图片List
@property (nonatomic,strong) FCMsgCell *msgCell;//展示消息的UI
@property (nonatomic,strong) NSMutableArray *msgCellHeightList;//消息文本高度的List

@end

@implementation NFSingleChatInfoVC

- (NSMutableArray *)msgCellHeightList{
    if (!_msgCellHeightList) {
        _msgCellHeightList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _msgCellHeightList;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBaseVCAttributesWith:self.to_user.userNick left:nil right:nil WithInVC:self];
    
    UIBarButtonItem *addNew = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(jumpToAddressBookVc)];
    self.navigationItem.rightBarButtonItem = addNew;
    
    _textArray=[[NSMutableArray alloc]init];
    
    [UnderdarkUtil share].node.singleVC = self;
    [UnderdarkUtil share].node.delegate = self;
    //背景图片
    UIImageView *backImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64 - kMinHeight)];
    backImg.image = [UIImage imageNamed:@"1465808627942"];
    backImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:backImg];
    //毛玻璃
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithFrame:backImg.frame];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    effectView.effect = effect;
    [self.view addSubview:effectView];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height-64 -kMinHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    [self.view addSubview:self.chatBar];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //获取历史数据
    [self showHistoryMsg];
    [self setupDownRefresh];
    //清除该用户的未读消息
    [[SqlManager shareInstance]clearUnreadNum:self.to_user.userId];
    
}
- (void)jumpToAddressBookVc{
    NSArray *menuItems;
    
    menuItems =
    @[
      [KxMenuItem menuItem:@"ta的信息"
                     image:nil
                    target:self
                    action:@selector(userInfos:)],
      [KxMenuItem menuItem:@"投诉"
                     image:nil
                    target:self
                    action:@selector(complaint:)],
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(SCREEN_SIZE.width - 64, - 28, 74.0f, 34.0f)
                 menuItems:menuItems];
    
}
//个人信息
- (void)userInfos:(id)sender{
    OtherInfoVC *otherVc= [[OtherInfoVC alloc]init];
    otherVc.user = self.to_user;
    [self.navigationController pushViewController:otherVc animated:YES];
    
}
//举报
- (void)complaint:(id)sender{
    NFReportObjectVC *reportVc = [[NFReportObjectVC alloc]init];
    [self.navigationController pushViewController:reportVc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}
#pragma -mark 刚进页面获取历史数据
- (void)showHistoryMsg{
    self.historyMsgs = [[SqlManager shareInstance]getChatHistory:self.to_user.userId withToId:self.to_user.userId withStartNum:0];
    for (PersonMessage *msg in self.historyMsgs) {
        
        [_textArray insertObject:msg atIndex:0];
        
        [_tableView reloadData];
            
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height) animated:YES];
        
    }
    
}
//下拉刷新数据
- (void)setupDownRefresh
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJCommonHeader *header = [MJCommonHeader headerWithRefreshingBlock:^{
        [self showHistoryMsgWithCount:_textArray.count];
    }];
    
    // 设置header
    self.tableView.header = header;
    
//    [header beginRefreshing];
}
//刷新数据
- (void)showHistoryMsgWithCount:(NSInteger)count{
    //别人发我，我发别人都要取出来
    self.historyMsgs = [[SqlManager shareInstance]getChatHistory:self.to_user.userId withToId:self.to_user.userId withStartNum:count];
    
    for (PersonMessage *msg in self.historyMsgs) {
        [self showHistoryTableMsg:msg];
    }

    [self.tableView.header endRefreshing];
}
//获取最新数据并刷新UI
-(void)showHistoryTableMsg:(PersonMessage *)msg{
    
    [_textArray insertObject:msg atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_tableView reloadData];
        
    });

}
//获取最新数据并刷新UI
-(void)showTableMsg:(PersonMessage *) msg
{
    
    [_textArray addObject:msg];
    
    [_tableView reloadData];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    
}
#pragma mark -FNMsgCellDelegate
- (void)msgCellTappedBlank:(FCMsgCell *)msgCell{
    [self.chatBar endInputing];
}
#pragma mark -点击文件
- (void)msgCellTappedContentWithFile:(ChatCell *)msgCell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:msgCell];
    
    PersonMessage *msg = _textArray[indexPath.row];
    DocumentLoadVC *vc = [[DocumentLoadVC alloc]init];
    FileModel *file = [[FileModel alloc]init];
    file.fileName = msg.fileMessage.fileName;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //拷贝文件的前半路径
    if ([msg.fileMessage.filePath rangeOfString:@"Documents/"].length > 0) {
        file.fileAbsolutePath = [NSHomeDirectory() stringByAppendingPathComponent:msg.fileMessage.filePath];

    }else{//聊天发送过的文件的前半路径
        file.fileAbsolutePath = [documentPath stringByAppendingPathComponent:msg.fileMessage.filePath];
    }
    vc.currentFileModel = file;
    vc.title = file.fileName;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma -mark 点击bubble
- (void)msgCellTappedContent:(ChatCell *)msgCell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:msgCell];
    
    PersonMessage *msg = _textArray[indexPath.row];
    
    ReceiverVoiceCell *cell = (ReceiverVoiceCell *)msgCell;
    NSArray<ReceiverVoiceCell *>*cells = [self.tableView visibleCells];
    for (ReceiverVoiceCell *cell in cells) {
        if (cell.msg.messageBodyType == eMessageBodyType_Voice) {
            [cell sendVoiceMesState:FNVoiceMessageStateNormal];
        }
    }
    cell.voice.animationRepeatCount = [msg.voiceMessage.durational intValue];
    //播放动画
    [cell.voice startAnimating];
    //播放声音
    [[FNAVAudioPlayer sharePlayer] playAudioWithvoiceData:[NSData dataWithBase64EncodedString:msg.voiceMessage.fileData] atIndex:indexPath.row];
    
    //设为已读
    if ([msgCell isKindOfClass:[ReceiverVoiceCell class]]) {
        [cell updateIsRead:YES];//UI
        [[SqlManager shareInstance]clearMsgOfSingleWithmsg_id:msg.msgId];//数据库
        msg.voiceMessage.isRead = @"1";
        [_textArray replaceObjectAtIndex:indexPath.row withObject:msg];
    }
}
//点击用户头像
- (void)clickUserHeadPic:(NSUInteger)index{

    UserModel *user = [[UserModel alloc]init];
    PersonMessage *pMsg = _textArray[index];
    if ([NexfiUtil isMeSend:pMsg]) {
        user = [UserManager shareManager].getUser;
    }else{
        NSMutableArray *handleByUsers;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[NeighbourVC class]]) {
                NeighbourVC *NeighbourVc = (NeighbourVC *)vc;
                handleByUsers = [[NSMutableArray alloc]initWithArray:NeighbourVc.handleByUsers];
            }
        }
        
        for (UserModel *handleUser in handleByUsers) {
            if ([handleUser.userId isEqualToString:pMsg.userMessage.userId]) {
                user = handleUser;
            }
        }
    }
    
    OtherInfoVC *vc = [[OtherInfoVC alloc]init];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
    
}
//点击发送的图片
- (void)clickPic:(NSUInteger)index{
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    self.mwPhotos = [[NSMutableArray alloc]initWithCapacity:0];
    NSUInteger currentIndex = 0;
    
    for (int i = 0; i < _textArray.count; i ++) {
        PersonMessage *msg = _textArray[i];
        
        if (msg.messageBodyType == eMessageBodyType_Image) {
            
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:msg.fileMessage.fileData];
            MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithData:imageData]];
            [self.mwPhotos addObject:photo];
            
            if (index == i) {
                currentIndex = self.mwPhotos.count - 1;
            }
        }
    }
    //展示图片的工具UI
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:currentIndex];
    
    [self.navigationController pushViewController:browser animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _textArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonMessage *msg=[_textArray objectAtIndex:indexPath.row];
    ChatCell *cell = [self getCellWithMsg:msg];
    cell.backgroundColor = [UIColor clearColor];
    cell.index = indexPath.row;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma -mark  获取不同的cell
- (ChatCell *)getCellWithMsg:(PersonMessage *)msg{
    if (msg.messageBodyType == eMessageBodyType_Text) {
        if ([NexfiUtil isMeSend:msg]) {
            SenderTextCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SenderTextCell" owner:nil options:nil] objectAtIndex:0];
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:[[UserManager shareManager]getUser].userAvatar];
            return (ChatCell *)cell;
        }else{
            TextCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"TextCell" owner:nil options:nil] objectAtIndex:0];
            cell.to_user = self.to_user;
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:self.to_user.userAvatar];
            return (ChatCell *)cell;
        }
    }else if (msg.messageBodyType == eMessageBodyType_Image){
        if ([NexfiUtil isMeSend:msg]) {
            SenderAvatarCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SenderAvatarCell" owner:nil options:nil] objectAtIndex:0];
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:[[UserManager shareManager]getUser].userAvatar];
            return (ChatCell *)cell;
        }else{
            ReceiverAvatarCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ReceiverAvatarCell" owner:nil options:nil] objectAtIndex:0];
            cell.to_user = self.to_user;
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:self.to_user.userAvatar];
            return (ChatCell *)cell;
        }
    }else if (msg.messageBodyType == eMessageBodyType_Voice){
        if ([NexfiUtil isMeSend:msg]) {
            SenderVoiceCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SenderVoiceCell" owner:nil options:nil] objectAtIndex:0];
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:[[UserManager shareManager]getUser].userAvatar];
            return (ChatCell *)cell;
        }else{
            ReceiverVoiceCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ReceiverVoiceCell" owner:nil options:nil] objectAtIndex:0];
            cell.to_user = self.to_user;
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:self.to_user.userAvatar];
            return (ChatCell *)cell;
        }
    }else if (msg.messageBodyType == eMessageBodyType_File){
        if ([NexfiUtil isMeSend:msg]) {
            SenderFileCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SenderFileCell" owner:nil options:nil] objectAtIndex:0];
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:[[UserManager shareManager]getUser].userAvatar];
            return (ChatCell *)cell;
        }else{
            ReceiverFileCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ReceiverFileCell" owner:nil options:nil] objectAtIndex:0];
            cell.to_user = self.to_user;
            cell.msg = msg;
            cell.avatar.image = [UIImage imageNamed:self.to_user.userAvatar];
            return (ChatCell *)cell;
        }
    }
    return nil;
}
#pragma -mark 获取所有cell高度的数组
- (id)getMsgCellHeightWithMsg:(PersonMessage *)msg{
    
    int n = msg.messageBodyType ;
    if (n == eMessageBodyType_Image) {
        
        NSData *data =[[NSData alloc]initWithBase64EncodedString:msg.fileMessage.fileData];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
            if ([NexfiUtil isMeSend:msg]) {
                return @(imageHeight + 15 + 15 + 10);//imageHeight + 15 = bubbleY  15 ＝ timeH 10 ＝ 拓展
            }else{
                return @(imageHeight + 15 + 15 + 20 + 10);//imageHeight + 15 = bubbleY  15 ＝ timeH 20 ＝ nickH 10 ＝ 拓展
            }
        }else{
            return @(110);
        }
        
    }else if (n == eMessageBodyType_Voice){
        if ([NexfiUtil isMeSend:msg]) {
            return @(50 + 15 + 10);//50 = bubbleY  15 ＝ timeH 10 ＝ 拓展
        }else{
            return @(50 + 15 + 20 + 10);//50 = bubbleY 20 ＝ nickH  15 ＝ timeH 10 ＝ 拓展
        }
    }else if (n == eMessageBodyType_File){
        return @(80);
    }else{
        CGRect rect = [msg.textMessage.fileData boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
        if ([NexfiUtil isMeSend:msg]) {
            return @(rect.size.height + 40 + 15 + 10);//rect.size.height + 40 = bubbleY 15 = timeY 10 = 拓展
        }else{
            return @(rect.size.height + 40 + 20 + 15 + 10);//rect.size.height + 40 = bubbleY 15 = timeY 20 = nickY 10 = 拓展
        }
    }
}
#pragma -mark 获取接收到的数据
- (void)refreshGetData:(NSDictionary *)dic{
    NSDictionary *text = dic[@"text"];
    //    NSString *nodeId = dic[@"nodeId"];
    
    PersonMessage *msg = [PersonMessage mj_objectWithKeyValues:text];
    
    //存文件路径
    if (msg.messageBodyType == eMessageBodyType_File) {
        NSString *pathExtation = [[msg.fileMessage.fileName componentsSeparatedByString:@"."] lastObject];
        NSDictionary *fileDic = [NexfiUtil getSaveFilePathWithFileType:pathExtation];
        [[NSData dataWithBase64EncodedString:msg.fileMessage.fileData] writeToFile:fileDic[@"fullPath"] atomically:YES];

        msg.fileMessage.filePath = fileDic[@"partPath"];
    }
    
    
    //保存聊天记录
    [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:self.to_user WithMsg:msg];
    //增加未读消息数量
    [[SqlManager shareInstance]addUnreadNum:[[UserManager shareManager]getUser].userId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showTableMsg:msg];
    });
    
}
//获取用户连接
- (id<UDLink>)getUserLink{
    if ([UnderdarkUtil share].node.links.count == 0) {
        return nil;
    }
    NSMutableArray *nodeList;
    if ([UnderdarkUtil share].node.neighbourVc) {
        nodeList = [[UnderdarkUtil share].node.neighbourVc getAllNodeId];
        
    }
    
    for (int i = 0; i < [UnderdarkUtil share].node.links.count; i ++) {
        id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
        
        //单聊找到跟对方连接的link
        if ([[NSString stringWithFormat:@"%lld",myLink.nodeId] isEqualToString:self.to_user.nodeId]) {//|| [nodeList containsObject:[NSString stringWithFormat:@"%lld",myLink.nodeId]]
            return myLink;
        }
    }
    
    return nil;
}
#pragma -mark 获取发送的数据
- (id<UDSource>)frameData:(MessageBodyType)type withSendData:(id)data{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
        
        
        NSData *newData;
        PersonMessage *msg = [[PersonMessage alloc]init];
        NSString *deviceUDID = [NexfiUtil uuid];
        
        switch (type) {
            case eMessageBodyType_Text:
            {
                
                TextMessage *textMessage = [[TextMessage alloc]init];
                textMessage.fileData = data;//消息数据
                textMessage.isRead = @"1";//已读未读
                msg.textMessage = textMessage;
                
                msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.receiver = self.to_user.userId;//发送对像
                msg.messageBodyType = eMessageBodyType_Text;//文本类型
                msg.msgId = deviceUDID;//msgId
                msg.userMessage = [[UserManager shareManager]getUser];
                
                break;
            }
            case eMessageBodyType_Image:
            {
                //缓存到本地图片
                NSData *picData = [Photo image2Data:data];
                NSString *fileName = [[NFChatCacheFileUtil sharedInstance]chatCachePathWithFriendId:[[UserManager shareManager]getUser].userId andType:2];
                NSString *relativePath = [NSString stringWithFormat:@"voice/chatLog/%@/image/",[[UserManager shareManager]getUser].userId];
                NSString *currentTime = [self getDateWithFormatter:@"yyyyMMddHHmmss"];
                NSString *imgPath = [relativePath stringByAppendingString:[NSString stringWithFormat:@"image_%@.jpg",currentTime]];
                NSString *fullPath = [fileName stringByAppendingPathComponent:[NSString stringWithFormat:@"image_%@.jpg",currentTime]];
                [picData writeToFile:fullPath atomically:YES];
                FileMessage *fileMessage = [[FileMessage alloc]init];
                fileMessage.fileData = [picData base64Encoding];//消息数据
                fileMessage.filePath = imgPath;//图片路径
                fileMessage.isRead = @"1";//已读未读
                fileMessage.fileName = [NSString stringWithFormat:@"image_%@.jpg",currentTime];
                fileMessage.fileType = @"jpg";
                fileMessage.fileSize = [NSString stringWithFormat:@"%@",[NexfiUtil fileSizeWithUnitAtPath:fullPath]];
                msg.fileMessage = fileMessage;
                
                msg.messageBodyType = eMessageBodyType_Image;
                msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.receiver = self.to_user.userId;//发送对像
                msg.msgId = deviceUDID;//msgId
                msg.userMessage = [[UserManager shareManager]getUser];
                
                break;
            }
            case eMessageBodyType_File:
            {
                
                FileModel *file = data;
                
                FileMessage *fileMessage = [[FileMessage alloc]init];
                //url转成data 发送数据的时候效率更高
//                fileMessage.fileData = file.fileData?file.fileData:[[[NSData alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:file.partPath]]]base64Encoding];
                //本地加载转成data 发送数据的时候效率低
                fileMessage.fileData = file.fileData?file.fileData:[[[NSData alloc]initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:file.partPath]] base64Encoding];
                fileMessage.isRead = @"1";//已读未读
                fileMessage.fileName = file.fileName;
                fileMessage.fileType = file.fileType;
                fileMessage.filePath = file.partPath;
                fileMessage.fileSize = file.fileSize;
                
                msg.fileMessage = fileMessage;
                
                msg.messageBodyType = eMessageBodyType_File;
                msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.receiver = self.to_user.userId;//发送对像
                msg.msgId = deviceUDID;//msgId
                msg.userMessage = [[UserManager shareManager]getUser];
                
                break;
            }
            case eMessageBodyType_Voice:
            {
                
                NSDictionary *voicePro = data;
                
                NSString *DoucmentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *mp3Path = [DoucmentsPath stringByAppendingPathComponent:voicePro[@"voiceName"]];
                
                NSData *voiceData = [[NSData alloc]initWithContentsOfURL:[NSURL fileURLWithPath:mp3Path]];
                NSString *currentTime = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.timeStamp = currentTime;
                msg.messageBodyType = eMessageBodyType_Voice;//消息文本
                msg.msgId = deviceUDID;//msgId
                msg.receiver = self.to_user.userId;//发送对像
                msg.userMessage = [[UserManager shareManager]getUser];
                
                
                VoiceMessage *voiceMessage = [[VoiceMessage alloc]init];
                voiceMessage.isRead = @"0";//已读未读
                voiceMessage.fileData = [voiceData base64Encoding];//消息数据
                voiceMessage.durational = voicePro[@"voiceSec"];//语音时间
                voiceMessage.fileName = voicePro[@"voiceName"];
                voiceMessage.fileSize = [NSString stringWithFormat:@"%@",[NexfiUtil fileSizeWithUnitAtPath:mp3Path]];
                voiceMessage.fileType = @"mp3";
                
                msg.voiceMessage = voiceMessage;
                

                
                break;
            }
            default:
                break;
        }
        
        msg.messageType = eMessageType_SingleChat;
        newData = [NSJSONSerialization dataWithJSONObject:msg.mj_keyValues options:0 error:0];
        //刷新表
//        if (sendOnce == YES) {
//            sendOnce = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showTableMsg:msg];
            });
            
            //插入数据库
            [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:self.to_user WithMsg:msg];
//        }
        
        
        return newData;
        
    }];
    
    return result;
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
- (XMChatBar *)chatBar {
    if (!_chatBar) {
        _chatBar = [[XMChatBar alloc] initWithFrame:CGRectMake(0, SCREEN_SIZE.height - kMinHeight - 64, SCREEN_SIZE.width, kMinHeight)];
        [_chatBar setSuperViewHeight:SCREEN_SIZE.height - 64];
        _chatBar.delegate = self;
    }
    return _chatBar;
}
#pragma mark -NodeDelegate
- (void)singleChatSendFailWithInfo:(NSString *)failMsg{
    [HudTool showErrorHudWithText:failMsg inView:self.view duration:2];
}
- (void)AllUserChatSendFailWithInfo:(NSString *)failMsg{
    
}
#pragma mark - XMChatBarDelegate
//发送文本
- (void)chatBar:(XMChatBar *)chatBar sendMessage:(NSString *)message{
    
    sendOnce = YES;
    id<UDSource>source = [self frameData:eMessageBodyType_Text withSendData:message];
    [[UnderdarkUtil share].node singleChatWithFrame:source];
}
//发送语音
- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    
    sendOnce = YES;
    NSDictionary *voicePro = @{@"voiceName":voiceFileName,@"voiceSec":@((int)seconds)};
    id<UDSource>source = [self frameData:eMessageBodyType_Voice withSendData:voicePro];
    [[UnderdarkUtil share].node singleChatWithFrame:source];

}
//发送图片
- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    for (int i = 0; i < pictures.count; i ++) {
//        sendOnce = YES;
        UIImage *image = pictures[i];
        id<UDSource>source = [self frameData:eMessageBodyType_Image withSendData:image];
        [[UnderdarkUtil share].node singleChatWithFrame:source];
    }
}
- (void)chatBar:(XMChatBar *)chatBar sendFile:(FileModel *)file{
    id<UDSource>source = [self frameData:eMessageBodyType_File withSendData:file];
    [[UnderdarkUtil share].node singleChatWithFrame:source];
}
- (void)chatBar:(XMChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText{

    
}
//输入栏位置改变方法
- (void)chatBarFrameDidChange:(XMChatBar *)chatBar frame:(CGRect)frame{
    if (frame.origin.y == self.tableView.frame.size.height) {
        return;
    }
    [UIView animateWithDuration:.3f animations:^{
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, frame.origin.y)];
    } completion:nil];
}
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.mwPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.mwPhotos.count)
        return [self.mwPhotos objectAtIndex:index];
    return nil;
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
