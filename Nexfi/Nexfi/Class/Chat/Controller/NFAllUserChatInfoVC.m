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
//    _tableView.backgroundColor = [UIColor blueColor];
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    [self.view addSubview:_tableView];
    
    [self.view addSubview:self.chatBar];
//    [self.view addSubview:self.peesView];
    
    
    //获取历史数据
    [self showHistoryMsg];
    
//    self.peesView.peesCount.text = self.peersCount?[NSString stringWithFormat:@"当前有%@人",self.peersCount]:@"当前有0人";
    
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
//            NSData *imgData = [[NSData alloc]initWithBase64EncodedString:[[UserManager shareManager]getUser].headImgStr];
//            [cell setHeadImage:[UIImage imageWithData:imgData]];
                     [cell setHeadImage:[UIImage imageNamed:[[UserManager shareManager]getUser].headImgPath]];
            
        }
        else
        {
//            NSData *imgData = [[NSData alloc]initWithBase64EncodedString:msg.senderFaceImageStr];
//            [cell setHeadImage:[UIImage imageWithData:imgData]];
            [cell setHeadImage:[UIImage imageNamed:msg.senderFaceImageStr]];

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
    switch (msgCell.msg.fileType) {
        case eMessageBodyType_Voice:
        {
//            NSString *voice = msgCell.msg.
            TribeMessage *msg = (TribeMessage *)msgCell.msg;
            NSArray<FCMsgCell *>*cells = [self.tableView visibleCells];
            for (FCMsgCell *cell in cells) {
                [cell sendVoiceMesState:FNVoiceMessageStateNormal];
            }
            
            
            msgCell.messageVoiceStatusIV.animationRepeatCount = [msg.durational intValue];

            if ([NexfiUtil isMeSend:msgCell.msg]) {
                //展示UI
                //播放
       
                NSString *DoucmentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                
                NSString *mp3Path = [DoucmentsPath stringByAppendingPathComponent:msg.tContent];
                [[FNAVAudioPlayer sharePlayer]playAudioWithvoiceData:mp3Path atIndex:indexPath.row isMe:YES];
                [msgCell.messageVoiceStatusIV startAnimating];

                
            }else{
                //展示UI
                //播放
                [[FNAVAudioPlayer sharePlayer] playAudioWithvoiceData:[NSData dataWithBase64EncodedString:msg.tContent] atIndex:indexPath.row isMe:NO];
                [msgCell.messageVoiceStatusIV startAnimating];
            }

            
            break;
        }
            
        default:
            break;
    }
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
    
    self.historyMsgs = [[SqlManager shareInstance]getAllChatListWithNum:0];

    
    for (int i = 0; i < self.historyMsgs.count; i ++) {
        TribeMessage *msg = self.historyMsgs[i];
        if (msg.fileType == eMessageBodyType_Image) {
            if ([NexfiUtil isMeSend:msg]) {//是我
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],msg.tContent]]];
                [self.mwPhotos addObject:photo];
            }else{
                NSData *imageData = [[NSData alloc]initWithBase64EncodedString:msg.tContent];
                MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithData:imageData]];
                [self.mwPhotos addObject:photo];
            }
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
#pragma - mark 跳转群组信息
- (void)RightBarBtnClick:(id)sender{
    NFTribeInfoVC *vc = [[NFTribeInfoVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
//- (void)updatePeersCount:(NSString *)peersCount{
//    self.peesView.peesCount.text = [NSString stringWithFormat:@"当前有%@人",peersCount];
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.msgCellHeightList[indexPath.row] floatValue];
}
#pragma -mark 获取所有cell高度的数组
- (id)getMsgCellHeightWithMsg:(TribeMessage *)msg{
    
    int n = msg.fileType ;
    if (n == eMessageBodyType_Image) {
        if ([NexfiUtil isMeSend:msg]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],msg.tContent]];
            if (image) {
                float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
                return @(imageHeight + 20 + 25);
            }else{
                return @(110);
            }
            
        }else{
            NSData *data =[[NSData alloc]initWithBase64EncodedString:msg.tContent];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
                return @(imageHeight + 20 + 25);
            }else{
                return @(110);
            }
        }
    }else if (n == eMessageBodyType_Voice){
        return @(66);
    }else if (n == eMessageBodyType_File){
        return @(80);
    }else{
        CGRect rect = [msg.tContent boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
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
    NSString *nodeId = dic[@"nodeId"];
    TribeMessage *msg = [[TribeMessage alloc]initWithaDic:text];
    msg.nodeId = nodeId;
    if (msg.fileType != eMessageBodyType_Text && msg.file) {
        msg.tContent = msg.file;
    }
    msg.isRead = @"1";
    UserModel *user = [[UserModel alloc]init];
    user.userId = msg.sender;
    user.userName = msg.senderNickName;
    //    user.headImgStr = msg.senderFaceImageStr;
    user.headImgPath = msg.senderFaceImageStr;

    
    
//    if (![msgList containsObject:msg.msgId]) {//如果数据库有了 说明其他人发过了 不需要转发 如果没有 既要存数据库 又要给除来源之外的人发
    
        //保存聊天记录
        [[SqlManager shareInstance]insertAllUser_ChatWith:user WithMsg:msg];
        //增加未读消息数量
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [[UnderdarkUtil share].node groupSendBroadcastFrame:[self frameData:msg.fileType withSendData:nil WithTribeMsg:msg] WithtribeMessage:msg];

//        });
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showTableMsg:msg];
        
        });

    


//    }

}

#pragma -mark 调用发送数据接口
- (void)broadcastFrame:(id<UDSource>)frameData{
    if ([UnderdarkUtil share].node.links.count == 0) {
        
        [HudTool showErrorHudWithText:@"您附近没有用户上线哦~" inView:self.view duration:2];

        return;
    }
    for (int i = 0; i < [UnderdarkUtil share].node.links.count; i ++) {
        self.link = [[UnderdarkUtil share].node.links objectAtIndex:i];
        
        [self.link sendData:frameData];
    }
    
}
#pragma -mark 群发数据


#pragma -mark 获取发送的数据
- (id<UDSource>)frameData:(MessageBodyType)type withSendData:(id)data WithTribeMsg:(TribeMessage *)tribeMsg{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
        NSData *newData;
        if (!tribeMsg) {
            
            TribeMessage *msg = [[TribeMessage alloc]init];
            NSString *deviceUDID = [NexfiUtil uuid];
            
            switch (type) {
                case eMessageBodyType_Text:
                {
                    msg.tContent = data;
                    msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.sender = [[UserManager shareManager]getUser].userId;
                    msg.fileType = eMessageBodyType_Text;
                    msg.msgId = deviceUDID;
                    //                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
                    msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgPath;
                    msg.senderNickName = [[UserManager shareManager]getUser].userName;
                    msg.durational = @"";
                    msg.isRead = [NSString stringWithFormat:@"0"];
                    
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
                    
                    msg.tContent = imgPath;
                    msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.sender = [[UserManager shareManager]getUser].userId;
                    msg.fileType = eMessageBodyType_Image;
                    msg.msgId = deviceUDID;
                    //                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
                    msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgPath;
                    msg.senderNickName = [[UserManager shareManager]getUser].userName;
                    msg.durational = @"";
                    msg.file = [picData base64Encoding];
                    msg.isRead = [NSString stringWithFormat:@"0"];
                    
                    
                    break;
                }
                case eMessageBodyType_File:
                {
                    
                    
                    break;
                }
                case eMessageBodyType_Voice:
                {
                    NSDictionary *voicePro = data;
                    NSData *voiceData = [[NSData alloc]initWithContentsOfURL:[NSURL fileURLWithPath:voicePro[@"voiceName"]]];
                    msg.tContent = voicePro[@"voiceName"];
                    msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    msg.sender = [[UserManager shareManager]getUser].userId;
                    msg.fileType = eMessageBodyType_Voice;
                    msg.msgId = deviceUDID;
                    //                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
                    msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgPath;
                    msg.senderNickName = [[UserManager shareManager]getUser].userName;
                    msg.durational = voicePro[@"voiceSec"];
                    msg.file = [voiceData base64Encoding];
                    msg.isRead = [NSString stringWithFormat:@"0"];
                    break;
                    
                }
                default:
                    break;
            }
            
            msg.messageType = eMessageType_AllUserChat;
            
            
            NSDictionary *msgDic = [NexfiUtil getObjectData:msg];
            newData = [NSJSONSerialization dataWithJSONObject:msgDic options:0 error:0];
        
            //刷新表
            if (sendOnce == YES) {
                sendOnce = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showTableMsg:msg];
                });
            }
            
            //插入数据库
            
            [[SqlManager shareInstance]insertAllUser_ChatWith:[[UserManager shareManager]getUser] WithMsg:msg];

        }else{
            NSDictionary *msgDic = [NexfiUtil getObjectData:tribeMsg];
            newData = [NSJSONSerialization dataWithJSONObject:msgDic options:0 error:0];
            
            
            NSMutableArray *msgList = [[SqlManager shareInstance]getAllChatMsgIdList];
            if (![msgList containsObject:tribeMsg.msgId]) {
                //刷新表
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showTableMsg:tribeMsg];
                    
                });
            }
        }
        
        return newData;
        
    }];
    
    return result;
}
-(void)showTableMsg:(TribeMessage *) msg
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [_textArray addObject:msg];
    [self.msgCellHeightList addObject:[self getMsgCellHeightWithMsg:msg]];
    NSLog(@"gao===%@",self.msgCellHeightList);
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
    
//    NSMutableDictionary *textMessageDict = [NSMutableDictionary dictionary];
//    textMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeText);
//    textMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
//    textMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
//    textMessageDict[kXMNMessageConfigurationTextKey] = message;
//    textMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
//    textMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
//    [self addMessage:textMessageDict];

    sendOnce = YES;
//    [self broadcastFrame:[self frameData:eMessageBodyType_Text withSendData:message]];
    [[UnderdarkUtil share].node broadcastFrame:[self frameData:eMessageBodyType_Text withSendData:message WithTribeMsg:nil] WithMessageType:eMessageType_AllUserChat];

}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    sendOnce = YES;
    NSDictionary *voicePro = @{@"voiceName":voiceFileName,@"voiceSec":@(seconds)};
    [[UnderdarkUtil share].node broadcastFrame:[self frameData:eMessageBodyType_Voice withSendData:voicePro WithTribeMsg:nil] WithMessageType:eMessageType_AllUserChat];
}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    sendOnce = YES;
//    [self broadcastFrame:[self frameData:eMessageBodyType_Image withSendData:[pictures objectAtIndex:0]]];
    [[UnderdarkUtil share].node broadcastFrame:[self frameData:eMessageBodyType_Image withSendData:[pictures objectAtIndex:0]WithTribeMsg:nil] WithMessageType:eMessageType_AllUserChat];
    
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
//- (UIView *)peesView{
//    if (!_peesView) {
//        _peesView = [[NFPeersView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, 30)];
//    }
//    return _peesView;
//}
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
