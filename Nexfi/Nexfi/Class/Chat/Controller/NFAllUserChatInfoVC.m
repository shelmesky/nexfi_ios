//
//  NFAllUserChatInfoVC.m
//  Nexfi
//
//  Created by fyc on 16/4/12.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "NFAllUserChatInfoVC.h"
#import "Photo.h"
#import "FCMsgCell.h"
#import "TribeMessage.h"
#import "UnderdarkUtil.h"
#import "NFSingleChatInfoVC.h"
#import "NexfiUtil.h"
#import "Message.h"
#import "NFChatCacheFileUtil.h"
#import "NFPeersView.h"
#import "NFTribeInfoVC.h"


@interface NFAllUserChatInfoVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,XMChatBarDelegate,FCMsgCellDelegate,MWPhotoBrowserDelegate,NodeDelegate>
{
    //用来保存输入框中的信息
    NSMutableArray * _textArray;
    
    NSMutableArray *_pool;
    int _refreshCount;
    
    BOOL sendOnce;
}
@property (nonatomic,strong) NSMutableArray *msgs;
@property (nonatomic,strong) UITableView *tableView;
@property (strong, nonatomic) XMChatBar *chatBar;
@property (nonatomic, strong)NSMutableArray *mwPhotos;
@property (nonatomic, strong)NSArray *historyMsgs;
@property (nonatomic,strong) NSMutableArray *msgCellHeightList;
//@property (nonatomic, strong) NFPeersView *peesView;

@end

@implementation NFAllUserChatInfoVC
- (NSMutableArray *)msgCellHeightList{
    if (!_msgCellHeightList) {
        _msgCellHeightList = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _msgCellHeightList;
}
- (NSMutableArray *)msgs{
    if (_msgs) {
        _msgs = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _msgs;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBaseVCAttributesWith:@"群聊" left:nil right:@"041.png" WithInVC:self];
    
    _textArray=[[NSMutableArray alloc]init];
    
    _pool = [[NSMutableArray alloc]init];
    
    [UnderdarkUtil share].node.allUserChatVC = self;
    [UnderdarkUtil share].node.delegate = self;
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,  0, SCREEN_SIZE.width, SCREEN_SIZE.height- kMinHeight - 64
                                                            ) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    [self.view addSubview:_tableView];
    
    [self.view addSubview:self.chatBar];
    
    //获取历史数据
    [self showHistoryMsg];
    
}
- (void)showHistoryMsg{
    //别人发我，我发别人都要取出来
    self.historyMsgs = [[SqlManager shareInstance]getAllChatListWithNum:0];
    
    for (TribeMessage *msg in self.historyMsgs) {
        [self showTableMsg:msg];
    }
}
#pragma mark --tableViewDelegate
//因为tableView是继承于scrollView的，所以可以用srollView的代理方法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //当我们拖动table的时候，调用让键盘下去的方法
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _textArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TribeMessage *msg=[_textArray objectAtIndex:indexPath.row];
    NSString * identifier= [NSString stringWithFormat:@"friendCell_%d_%ld",_refreshCount,indexPath.row];
    FCMsgCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell=[[FCMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [_pool addObject:cell];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.index    = (int)indexPath.row;
        cell.delegate = self;
        cell.didTouch = @selector(onSelect:);
        cell.msg      = msg;
        cell.msgDelegate = self;
        
        if([cell isMeSend])
        {
            [cell setHeadImage:[UIImage imageNamed:[[UserManager shareManager]getUser].userAvatar]];
            
        }
        else
        {
            [cell setHeadImage:[UIImage imageNamed:msg.userMessage.userAvatar]];
            
        }
    }
    
    return cell;
}
-(void)onSelect:(UIView*)sender{
    
}
#pragma mark -FNMsgCellDelegate
- (void)msgCellTappedBlank:(FCMsgCell *)msgCell{
    [self.chatBar endInputing];
}
#pragma -mark 点击bubble
- (void)msgCellTappedContent:(FCMsgCell *)msgCell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:msgCell];
    
    TribeMessage *msg = (TribeMessage *)msgCell.msg;
    //关闭播放动画
    NSArray<FCMsgCell *>*cells = [self.tableView visibleCells];
    for (FCMsgCell *cell in cells) {
        [cell sendVoiceMesState:FNVoiceMessageStateNormal];
    }
    //设置播放录音
    msgCell.messageVoiceStatusIV.animationRepeatCount = [msg.voiceMessage.durational intValue];
    //播放动画
    [msgCell.messageVoiceStatusIV startAnimating];
    //播放声音
    [[FNAVAudioPlayer sharePlayer] playAudioWithvoiceData:[NSData dataWithBase64EncodedString:msg.voiceMessage.fileData] atIndex:indexPath.row isMe:NO];
    //设为已读
    [msgCell updateIsRead:YES];//UI
    [[SqlManager shareInstance]clearMsgOfAllUserWithMsgId:msg.msgId];//数据库
    
}
#pragma -mark 点击图片放大
- (void)clickPic:(NSUInteger)index{
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    self.mwPhotos = [[NSMutableArray alloc]initWithCapacity:0];
    NSUInteger currentIndex = 0;
    
//    self.historyMsgs = [[SqlManager shareInstance]getAllChatListWithNum:0];
    
    
    for (int i = 0; i < _textArray.count; i ++) {
        TribeMessage *msg = _textArray[i];
        if (msg.messageBodyType == eMessageBodyType_Image) {
            
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:msg.fileMessage.fileData];
            MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithData:imageData]];
            [self.mwPhotos addObject:photo];
            
            if (index == i) {
                currentIndex = self.mwPhotos.count - 1;
            }
        }
    }
    
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
#pragma - mark 点击头像
- (void)clickUserHeadPic:(NSUInteger)index{
    
}
#pragma - mark 跳转群组信息
- (void)RightBarBtnClick:(id)sender{
    NFTribeInfoVC *vc = [[NFTribeInfoVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.msgCellHeightList[indexPath.row] floatValue];
}
#pragma -mark 获取所有cell高度的数组
- (id)getMsgCellHeightWithMsg:(TribeMessage *)msg{
    
    int n = msg.messageBodyType ;
    if (n == eMessageBodyType_Image) {
        
        NSData *data =[[NSData alloc]initWithBase64EncodedString:msg.fileMessage.fileData];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
            return @(imageHeight + 20 + 25);
        }else{
            return @(110);
        }
        
    }else if (n == eMessageBodyType_Voice){
        return @(66);
    }else if (n == eMessageBodyType_File){
        return @(80);
    }else{
        CGRect rect = [msg.textMessage.fileData boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
        if (rect.size.height < 15) {
            return @(85);
        }
        return @(rect.size.height + 20 + 50);
    }
}

#pragma -mark 获取接收到的数据
- (void)refreshGetData:(NSDictionary *)dic{
    NSDictionary *text = dic[@"text"];
    TribeMessage *msg = [TribeMessage mj_objectWithKeyValues:text];
    
    //保存聊天记录
    [[SqlManager shareInstance]insertAllUser_ChatWith:msg.userMessage WithMsg:msg];
    //增加未读消息数量
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showTableMsg:msg];
        
    });
    
    
}
#pragma -mark 获取发送的数据
- (id<UDSource>)frameData:(MessageBodyType)type withSendData:(id)data{
   
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
 
        NSData *newData;
        
            TribeMessage *msg = [[TribeMessage alloc]init];
            NSString *deviceUDID = [NexfiUtil uuid];
            switch (type) {
                case eMessageBodyType_Text:
                {
                    
                    TextMessage *textMessage = [[TextMessage alloc]init];
                    textMessage.fileData = data;
                    textMessage.isRead = @"1";
                    msg.textMessage = textMessage;
                    
                    msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.messageBodyType = eMessageBodyType_Text;
                    msg.msgId = deviceUDID;
                    
                    
                    msg.userMessage = [[UserManager shareManager]getUser];//json
                    
                    
                    
                    break;
                }
                case eMessageBodyType_Image:
                {
                    //缓存到本地图片
                    NSData *picData = [Photo image2Data:data];
                    NSString *fileName = [[NFChatCacheFileUtil sharedInstance]chatCachePathWithFriendId:[[UserManager shareManager]getUser].userId andType:2];
                    
                    NSString *relativePath = [NSString stringWithFormat:@"voice/chatLog/%@/image/",[[UserManager shareManager]getUser].userId];
                    NSString *imgPath = [relativePath stringByAppendingString:[NSString stringWithFormat:@"image_%@.jpg",[self getDateWithFormatter:@"yyyyMMddHHmmss"]]];
                    
                    
                    NSString *fullPath = [fileName stringByAppendingPathComponent:[NSString stringWithFormat:@"image_%@.jpg",[self getDateWithFormatter:@"yyyyMMddHHmmss"]]];
                    [picData writeToFile:fullPath atomically:YES];
                    
                    FileMessage *fileMessage = [[FileMessage alloc]init];
                    fileMessage.fileData = [picData base64Encoding];
                    fileMessage.filePath = imgPath;
                    fileMessage.isRead = @"1";
                    msg.fileMessage = fileMessage;
                    
                    msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.messageBodyType = eMessageBodyType_Image;
                    msg.msgId = deviceUDID;
                    
                    msg.userMessage = [[UserManager shareManager]getUser];//json
                    
                    
                    
                    break;
                }
                case eMessageBodyType_File:
                {
                    
                    
                    break;
                }
                case eMessageBodyType_Voice:
                {
                    NSDictionary *voicePro = data;
                    //存半路径 取data要加前缀
                    NSString *DoucmentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    NSString *mp3Path = [DoucmentsPath stringByAppendingPathComponent:voicePro[@"voiceName"]];
                    
                    NSData *voiceData = [[NSData alloc]initWithContentsOfURL:[NSURL fileURLWithPath:mp3Path]];
                    
                    VoiceMessage *voiceMessage = [[VoiceMessage alloc]init];
                    voiceMessage.isRead = @"0";
                    voiceMessage.fileData = [voiceData base64Encoding];
                    voiceMessage.durational = voicePro[@"voiceSec"];
                    
                    msg.voiceMessage = voiceMessage;
                    
                    msg.timeStamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.messageBodyType = eMessageBodyType_Voice;
                    msg.msgId = deviceUDID;
                    
                    msg.userMessage = [[UserManager shareManager]getUser];//json
                    
                    
                    break;
                    
                }
                default:
                    break;
            }
            
            msg.messageType = eMessageType_AllUserChat;
            
            newData = [NSJSONSerialization dataWithJSONObject:msg.mj_keyValues options:0 error:0];
            

                
            //刷新表
            if (sendOnce == YES) {
                sendOnce = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showTableMsg:msg];
                });
                
                //插入数据库

                [[SqlManager shareInstance]insertAllUser_ChatWith:[[UserManager shareManager]getUser] WithMsg:msg];
                
                
                
            }
                
        return newData;
        
        
        
        
    }];
    
    return result;
}
-(void)showTableMsg:(TribeMessage *) msg
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    //消息重复不刷新表
    for (int i = 0; i < _textArray.count; i++) {
        TribeMessage *tMsg = _textArray[i];
        if ([tMsg.msgId isEqualToString:msg.msgId]) {
            return;
        }
    }
    [_textArray addObject:msg];
    
    [self.msgCellHeightList addObject:[self getMsgCellHeightWithMsg:msg]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_textArray count]-1 inSection:0];
    [indexPaths addObject:indexPath];
    //[_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    //[_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //   [_tableView reloadData];
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
- (void)AllUserChatSendFailWithInfo:(NSString *)failMsg{
    [HudTool showErrorHudWithText:failMsg inView:self.view duration:2];
}
- (void)singleChatSendFailWithInfo:(NSString *)failMsg{
    
}
#pragma mark - XMChatBarDelegate

- (void)chatBar:(XMChatBar *)chatBar sendMessage:(NSString *)message{
    
    sendOnce = YES;
    id<UDSource>source = [self frameData:eMessageBodyType_Text withSendData:message];
    [[UnderdarkUtil share].node allUserChatWithFrame:source];
    
    
}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    sendOnce = YES;
    NSDictionary *voicePro = @{@"voiceName":voiceFileName,@"voiceSec":@(seconds)};
    id<UDSource>source = [self frameData:eMessageBodyType_Voice withSendData:voicePro];
    [[UnderdarkUtil share].node allUserChatWithFrame:source];

}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    for (int i = 0; i < pictures.count; i ++) {
        sendOnce = YES;
        UIImage *image = pictures[i];
        id<UDSource>source = [self frameData:eMessageBodyType_Image withSendData:image];
        [[UnderdarkUtil share].node allUserChatWithFrame:source];

    }
    
}

- (void)chatBar:(XMChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText{
    //    NSMutableDictionary *locationMessageDict = [NSMutableDictionary dictionary];
    //    locationMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeLocation);
    //    locationMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
    //    locationMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
    //    locationMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
    //    locationMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
    //    locationMessageDict[kXMNMessageConfigurationLocationKey]=locationText;
    //    [self addMessage:locationMessageDict];
    
}

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
