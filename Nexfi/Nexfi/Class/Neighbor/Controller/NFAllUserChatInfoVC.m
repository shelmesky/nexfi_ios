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
@interface NFAllUserChatInfoVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,XMChatBarDelegate>
{
    //用来保存输入框中的信息
    NSMutableArray * _textArray;
    
    NSMutableArray *_pool;
    int _refreshCount;
    
    BOOL sendOnce;
}
@property (nonatomic,strong) UITableView *tableView;
@property (strong, nonatomic) XMChatBar *chatBar;
@property (nonatomic, strong) NFPeersView *peesView;

@end

@implementation NFAllUserChatInfoVC

-(void)viewWillAppear:(BOOL)animated{
    [self refresh:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBaseVCAttributesWith:@"群聊" left:nil right:nil WithInVC:self];
    
    _textArray=[[NSMutableArray alloc]init];
    
    _pool = [[NSMutableArray alloc]init];
    
    [UnderdarkUtil share].node.allUserChatVC = self;
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64 + 30, SCREEN_SIZE.width, SCREEN_SIZE.height-64- kMinHeight - 30
) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    [self.view addSubview:_tableView];
    
    [self.view addSubview:self.chatBar];
    [self.view addSubview:self.peesView];
    
    
    //获取历史数据
    [self showHistoryMsg];
    
    self.peesView.peesCount.text = self.peersCount?[NSString stringWithFormat:@"当前有%@人",self.peersCount]:@"当前有0人";

    
    //检测是否接收到数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getText:) name:@"allUser" object:nil];
    
    
}
- (void)showHistoryMsg{
    //别人发我，我发别人都要取出来
    NSArray *historyMsgs = [[SqlManager shareInstance]getAllChatListWithNum:0];
    
    
    for (TribeMessage *msg in historyMsgs) {
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
    //    NSLog(@"msg0=%d",msg.retainCount);
    NSString * identifier= [NSString stringWithFormat:@"friendCell_%d_%ld",_refreshCount,indexPath.row];
    FCMsgCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell=[[FCMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [_pool addObject:cell];
        
        //        NSLog(@"bb=%d",[msg.type intValue]);
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.index    = (int)indexPath.row;
        cell.delegate = self;
        cell.didTouch = @selector(onSelect:);
        cell.msg      = msg;
        
        if([cell isMeSend])
        {
            NSData *imgData = [[NSData alloc]initWithBase64EncodedString:[[UserManager shareManager]getUser].headImgStr];
            [cell setHeadImage:[UIImage imageWithData:imgData]];
            
        }
        else
        {
            NSData *imgData = [[NSData alloc]initWithBase64EncodedString:msg.senderFaceImageStr];
            [cell setHeadImage:[UIImage imageWithData:imgData]];
        }
    }
    
    return cell;
}
-(void)onSelect:(UIView*)sender{

}
- (void)updatePeersCount:(NSString *)peersCount{
    self.peesView.peesCount.text = [NSString stringWithFormat:@"当前有%@人",peersCount];
}
//每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TribeMessage *msg=[_textArray objectAtIndex:indexPath.row];
    int n = msg.fileType ;
    if (n == eMessageBodyType_Image) {
        if ([self isMeSend:msg]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],msg.tContent]];
            if (image) {
                float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
                return imageHeight + 20 + 25;
            }
            return 110;
            
        }else{
            NSData *data =[[NSData alloc]initWithBase64EncodedString:msg.tContent];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
                return imageHeight + 20 + 25;
            }
            return 110;
        }
    }else if (n == eMessageBodyType_Voice){
        return 66;
        
    }else if (n == eMessageBodyType_File){
        return 80;
    }else{
        CGRect rect = [[_textArray[indexPath.row]tContent] boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
        if (rect.size.height < 60) {
            return 60;
        }
        return rect.size.height + 20 + 50;
    }
}
-(void)refresh:(TribeMessage*)msg
{

    BOOL b=YES;
    if(msg == nil){
        if(_textArray==nil){
            //            [_array release];
            _textArray = [[NSMutableArray alloc]init];
        }
        NSMutableArray* temp = [[NSMutableArray alloc]init];
        NSMutableArray* p;
        //if([self.roomName length]>0)
        //    p = [Message fetchMessageListWithUser:self.roomName byPage:_page];
        //else
        //    p = [Message fetchMessageListWithUser:_chatPerson.userId byPage:_page];
        //b = p.count>0;
        //[temp addObjectsFromArray:p];
        //[temp addObjectsFromArray:_array];
        //[_array addObjectsFromArray:temp];
        //[temp release];
        // p = nil;
    }else
        [_textArray addObject:msg];
    
    if (b) {
        [self free:_pool];
        _refreshCount++;
        [_tableView reloadData];
        // if(msg || _page == 0)
        //    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
-(void)free:(NSMutableArray*)array{
    for(NSInteger i=[array count]-1;i>=0;i--){
        [array removeObjectAtIndex:i];
    }
}
#pragma -mark 获取接收到的数据
- (void)getText:(NSNotification *)notify{
    NSDictionary *text = notify.userInfo[@"text"];
    NSString *nodeId = notify.userInfo[@"nodeId"];
    TribeMessage *msg = [[TribeMessage alloc]initWithaDic:text];
    msg.nodeId = nodeId;
    if (msg.fileType != eMessageBodyType_Text && msg.file) {
        msg.tContent = msg.file;
    }
    msg.isRead = @"1";
    UserModel *user = [[UserModel alloc]init];
    user.userId = msg.sender;
    user.userName = msg.senderNickName;
    user.headImgStr = msg.senderFaceImageStr;
    //保存聊天记录
    [[SqlManager shareInstance]insertAllUser_ChatWith:user WithMsg:msg];
    //增加未读消息数量
    
    [self showTableMsg:msg];
    
}
#pragma -mark 调用发送数据接口
- (void)broadcastFrame:(id<UDSource>)frameData{
    if ([UnderdarkUtil share].node.links.count == 0) {
        return;
    }
    for (int i = 0; i < [UnderdarkUtil share].node.links.count; i ++) {
        self.link = [[UnderdarkUtil share].node.links objectAtIndex:i];
        
        [self.link sendData:frameData];
    }
    
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
                msg.tContent = data;
                msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.sender = [[UserManager shareManager]getUser].userId;
                msg.fileType = eMessageBodyType_Text;
                msg.msgId = deviceUDID;
                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
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
                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
                msg.senderNickName = [[UserManager shareManager]getUser].userName;
                msg.durational = @"";
                msg.file = [picData base64Encoding];
                msg.isRead = [NSString stringWithFormat:@"0"];

                
                break;
            }
            case eMessageBodyType_File:
            {
                
                //                newData = UIImageJPEGRepresentation(data, 0.5);
                //                msg.file = newData;
                //                msg.timestamp = [self getDate];
                //                msg.sender = @"1";
                //                msg.fileType = [NSString stringWithFormat:@"%ld",eMessageBodyType_Image];
                //                msg.msgId = deviceUDID;
                
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
        
        
        return newData;
        
    }];
    
    return result;
}
-(void)showTableMsg:(TribeMessage *) msg
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [_textArray addObject:msg];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_textArray count]-1 inSection:0];
    [indexPaths addObject:indexPath];
    //[_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    //[_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
-(BOOL)isMeSend:(Message *)msg{
    
    return [[msg sender] isEqualToString:[[UserManager shareManager]getUser].userId];
    
}
#pragma mark --改变键盘变成中文
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        _chatBar = [[XMChatBar alloc] initWithFrame:CGRectMake(0, SCREEN_SIZE.height - kMinHeight - (self.navigationController.navigationBar.isTranslucent ? 0 : 64), SCREEN_SIZE.width, kMinHeight)];
        [_chatBar setSuperViewHeight:SCREEN_SIZE.height - (self.navigationController.navigationBar.isTranslucent ? 0 : 64)];
        _chatBar.delegate = self;
    }
    return _chatBar;
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
    [self broadcastFrame:[self frameData:eMessageBodyType_Text withSendData:message]];
}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    
    
}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    sendOnce = YES;
    [self broadcastFrame:[self frameData:eMessageBodyType_Image withSendData:[pictures objectAtIndex:0]]];
    
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
- (UIView *)peesView{
    if (!_peesView) {
        _peesView = [[NFPeersView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, 30)];
    }
    return _peesView;
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
