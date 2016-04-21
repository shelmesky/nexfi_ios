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



@interface NFSingleChatInfoVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,XMChatBarDelegate,FCMsgCellDelegate,MWPhotoBrowserDelegate,NodeDelegate>
{
    UITableView * _tableView;
    
    UIImageView * _bottomImageView;
    
    UITextField * _inputText;
    
    //用来保存输入框中的信息
    NSMutableArray * _textArray;
    
    BOOL _isChangedKeyBoard;
    NSMutableArray *_pool;
    int _refreshCount;
    
    BOOL sendOnce;

}
@property (strong, nonatomic) XMChatBar *chatBar;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *historyMsgs;
@property (nonatomic,strong) NSMutableArray *mwPhotos;

@end

@implementation NFSingleChatInfoVC

-(void)viewWillAppear:(BOOL)animated{
    [self refresh:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBaseVCAttributesWith:self.to_user.userName left:nil right:nil WithInVC:self];

    
    _textArray=[[NSMutableArray alloc]init];

    _pool = [[NSMutableArray alloc]init];
    
    [UnderdarkUtil share].node.singleVC = self;
    [UnderdarkUtil share].node.delegate = self;

    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-64 -kMinHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    [self.view addSubview:self.chatBar];

    //获取历史数据
    [self showHistoryMsg];
    //清除该用户的未读消息
    [[SqlManager shareInstance]clearUnreadNum:self.to_user.userId];

}
- (void)showHistoryMsg{
    //别人发我，我发别人都要取出来
    self.historyMsgs = [[SqlManager shareInstance]getChatHistory:self.to_user.userId withToId:self.to_user.userId withStartNum:0];

    for (PersonMessage *msg in self.historyMsgs) {
        [self showTableMsg:msg];
    }
}
#pragma mark -FNMsgCellDelegate
- (void)clickPic:(NSUInteger)index{
    /*
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    self.mwPhotos = [[NSMutableArray alloc]initWithCapacity:0];
    NSUInteger currentIndex = 0;
    for (int i = 0; i < self.historyMsgs.count; i ++) {
        PersonMessage *msg = self.historyMsgs[i];
        if (msg.fileType == eMessageBodyType_Image) {
            if ([NexfiUtil isMeSend:msg]) {//是我
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],msg.pContent]]];
                [self.mwPhotos addObject:photo];
            }else{
                NSData *imageData = [[NSData alloc]initWithBase64EncodedString:msg.pContent];
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
     */
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
    PersonMessage *msg=[_textArray objectAtIndex:indexPath.row];
    //    NSLog(@"msg0=%d",msg.retainCount);
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
//            NSData *imgData = [[NSData alloc]initWithBase64EncodedString:self.to_user.headImgStr];
//            [cell setHeadImage:[UIImage imageWithData:imgData]];
            [cell setHeadImage:[UIImage imageNamed:self.to_user.headImgPath]];
        }
    }
    
    return cell;
}
-(void)onSelect:(UIView*)sender{

}

//每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonMessage *msg=[_textArray objectAtIndex:indexPath.row];
    int n = msg.fileType ;
    if (n == eMessageBodyType_Image) {
        if ([NexfiUtil isMeSend:msg]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],msg.pContent]];
            if (image) {
                float imageHeight = (float)(image.size.height * 80)/(float)image.size.width;
                return imageHeight + 20 + 25;
            }
            return 110;
            
        }else{
            NSData *data =[[NSData alloc]initWithBase64EncodedString:msg.pContent];
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
        CGRect rect = [[_textArray[indexPath.row]pContent] boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
        return rect.size.height + 20 + 50;
    }
}
-(void)refresh:(PersonMessage*)msg
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
- (void)refreshGetData:(NSDictionary *)dic{
    NSDictionary *text = dic[@"text"];
    NSString *nodeId = dic[@"nodeId"];
    
    PersonMessage *msg = [[PersonMessage alloc]initWithaDic:text];
    msg.nodeId = nodeId;
    if (msg.fileType != eMessageBodyType_Text && msg.file) {
        msg.pContent = msg.file;
    }
    //保存聊天记录
    [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:self.to_user WithMsg:msg];
    //增加未读消息数量
    [[SqlManager shareInstance]addUnreadNum:[[UserManager shareManager]getUser].userId];
    
    [self showTableMsg:msg];
}
- (id<UDLink>)getUserLink{
    if ([UnderdarkUtil share].node.links.count == 0) {
        return nil;
    }
    for (int i = 0; i < [UnderdarkUtil share].node.links.count; i ++) {
        id<UDLink>myLink = [[UnderdarkUtil share].node.links objectAtIndex:i];
        
        //单聊找到跟对方连接的link
        if ([[NSString stringWithFormat:@"%lld",myLink.nodeId] isEqualToString:self.to_user.nodeId]) {
            return myLink;
        }
    }
    
    return nil;
}
#pragma -mark 获取发送的数据
- (id<UDSource>)frameData:(MessageBodyType)type withSendData:(id)data{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
//                NSData *newData = [@"nihaoa" dataUsingEncoding:NSUTF8StringEncoding];
        
        
        
        NSData *newData;
        PersonMessage *msg = [[PersonMessage alloc]init];
        NSString *deviceUDID = [NexfiUtil uuid];

        switch (type) {
            case eMessageBodyType_Text:
            {
                msg.pContent = data;
                msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.sender = [[UserManager shareManager]getUser].userId;
                msg.receiver = self.to_user.userId;
                msg.fileType = eMessageBodyType_Text;
                msg.msgId = deviceUDID;
//                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgStr;
                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgPath;
                msg.senderNickName = [[UserManager shareManager]getUser].userName;
                msg.durational = @"";
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
                
                msg.pContent = imgPath;
                msg.fileType = eMessageBodyType_Image;
                msg.timestamp = [self getDateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                msg.sender = [[UserManager shareManager]getUser].userId;
                msg.receiver = self.to_user.userId;
                msg.msgId = deviceUDID;
                msg.senderFaceImageStr = [[UserManager shareManager]getUser].headImgPath;
                msg.senderNickName = [[UserManager shareManager]getUser].userName;
                msg.durational = @"";
                msg.file = [picData base64Encoding];
                
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
        
        msg.messageType = eMessageType_SingleChat;

        NSDictionary *msgDic = [NexfiUtil getObjectData:msg];
        newData = [NSJSONSerialization dataWithJSONObject:msgDic options:0 error:0];
        //刷新表
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showTableMsg:msg];

        });
        //插入数据库
        
        [[SqlManager shareInstance]add_chatUser:[[UserManager shareManager]getUser] WithTo_user:self.to_user WithMsg:msg];
         
         
        return newData;
        
    }];
    
    return result;
}
-(void)showTableMsg:(PersonMessage *) msg
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [_textArray addObject:msg];
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
        _chatBar = [[XMChatBar alloc] initWithFrame:CGRectMake(0, SCREEN_SIZE.height - kMinHeight - (self.navigationController.navigationBar.isTranslucent ? 0 : 64), SCREEN_SIZE.width, kMinHeight)];
        [_chatBar setSuperViewHeight:SCREEN_SIZE.height - (self.navigationController.navigationBar.isTranslucent ? 0 : 64)];
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

- (void)chatBar:(XMChatBar *)chatBar sendMessage:(NSString *)message{

    sendOnce = YES;
//    [self broadcastFrame:[self frameData:eMessageBodyType_Text withSendData:message]];
    [[UnderdarkUtil share].node broadcastFrame:[self frameData:eMessageBodyType_Text withSendData:message] WithMessageType:eMessageType_SingleChat];
}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    
    
}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    sendOnce = YES;
//    [self broadcastFrame:[self frameData:eMessageBodyType_Image withSendData:[pictures objectAtIndex:0]]];
        [[UnderdarkUtil share].node broadcastFrame:[self frameData:eMessageBodyType_Image withSendData:[pictures objectAtIndex:0]] WithMessageType:eMessageType_SingleChat];
    
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