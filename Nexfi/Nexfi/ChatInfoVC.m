//
//  ChatInfoVC.m
//  Nexify
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "FCMsgCell.h"
#import "UnderdarkUtil.h"
#import "ChatInfoVC.h"
#import "NexfiUtil.h"
#import "Message.h"
@interface ChatInfoVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView * _tableView;
    
    UIImageView * _bottomImageView;
    
    UITextField * _inputText;
    
    //用来保存输入框中的信息
    NSMutableArray * _textArray;
    
    BOOL _isChangedKeyBoard;
    NSMutableArray *_pool;
    int _refreshCount;
}
@end

@implementation ChatInfoVC
-(void)viewWillAppear:(BOOL)animated{
    [self refresh:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"lala";
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    _textArray=[[NSMutableArray alloc]init];
    
    _pool = [[NSMutableArray alloc]init];
    
    [UnderdarkUtil share].node.controller = self;
    
    [[UnderdarkUtil share].node start];


//    UIImageView * bgImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg.jpg"]];
//    bgImageView.frame=CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 44);
//    [self.view addSubview:bgImageView];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-44) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //取消tableview上的横线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //为了让下面的图片显示出来，把背景颜色置为cleanColor
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _bottomImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_SIZE.height - 44, SCREEN_SIZE.width, 44)];
    _bottomImageView.image=[UIImage imageNamed:@"3.png"];
    _bottomImageView.userInteractionEnabled=YES;
    [self.view addSubview:_bottomImageView];
    
    
    //输入框
    _inputText=[[UITextField alloc]initWithFrame:CGRectMake(10, 7, 200, 30)];
    _inputText.borderStyle=UITextBorderStyleRoundedRect;
    //textField输入框右侧有一个X号，点击可以删除输入框里的内容
    _inputText.clearButtonMode=UITextFieldViewModeAlways;
    //把return键换为send键
    _inputText.returnKeyType=UIReturnKeySend;
    _inputText.delegate=self;
    [_bottomImageView addSubview:_inputText];
    
    //发送button
    UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.backgroundColor=[UIColor blueColor];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendClickWithMsgType:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.frame=CGRectMake(250, 7, 60, 30);
    sendBtn.clipsToBounds=YES;
    sendBtn.layer.cornerRadius=5;
    [_bottomImageView addSubview:sendBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing) name:UITextViewTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:UITextViewTextDidEndEditingNotification object:nil];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //检测是否接收到数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getText:) name:@"text" object:nil];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"text" object:nil userInfo:@{@"text":text,@"nodeId":[NSString stringWithFormat:@"%lld",link.nodeId]}];
    
}
#pragma mark --tableViewDelegate
//因为tableView是继承于scrollView的，所以可以用srollView的代理方法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //当我们拖动table的时候，调用让键盘下去的方法
    [self inputTextFieldDown];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _textArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *msg=[_textArray objectAtIndex:indexPath.row];
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
//            NSString * imgurl = [ALBUM_PREFIX stringByAppendingString:self.userModel.faceImge];
//            NSURL * url = [NSURL URLWithString:imgurl];
//            [cell setHeadImageWithURL:url];
            [cell setHeadImage:[UIImage imageNamed:@"3"]];
            
        }
        else
        {
//            if(self.chatFriend !=nil) {
//                NSString * imgurl = [ALBUM_PREFIX stringByAppendingString:self.chatFriend.user_face];
//                NSURL * url = [NSURL URLWithString:imgurl];
//                [cell setHeadImageWithURL:url];
                [cell setHeadImage:[UIImage imageNamed:@"myChat"]];

//            }
            
            //[cell setHeadImage:[UIImage imageWithData:data]];
            //[cell setHeadImage:[UIImage imageNamed:[msg senderFaceImage]]];
        }
    }
    
    return cell;
}
-(void)onSelect:(UIView*)sender{
//    [self hideKeyboard];
//    
//    int n = sender.tag;
//    Message *msg=[_array objectAtIndex:n];
//    
//    switch ([msg.fileType intValue]) {
//        case kWCMessageTypeImage:{
//            
//            
//            //NSMutableArray * msgarr = [[FMDBUtil sharedInstance] getChatImageHistory:]
//            
//            JXImageView* iv = [[JXImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//            iv.contentMode = UIViewContentModeCenter;
//            
//            if([[msg sender] isEqualToString:[NSString stringWithFormat:@"%@",self.userModel.id]])
//            {
//                //UIImage * img = [UIImage imageNamed:msg.content];
//                iv.image    = [UIImage imageWithContentsOfFile:msg.content] ;//[UIImage imageNamed:[msg file]];
//            }
//            else{
//                NSURL* url = [NSURL URLWithString:msg.content];
//                NSData *data = [NSData dataWithContentsOfURL:url];
//                iv.image    = [UIImage imageWithData:data];//[UIImage imageNamed:[msg file]];'
//            }
//            iv.delegate = self;
//            iv.didTouch = @selector(onSelectImage:);
//            iv.userInteractionEnabled = YES;
//            [g_App.window addSubview:iv];
//            iv.hidden   = NO;
//            break;
//        }
//        case kWCMessageTypeVoice:{
//            _lastIndex = n;
//            [self recordPlay:msg];
//            break;
//        }
//        default:
//            break;
//    }
//    msg = nil;
}

//每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *msg=[_textArray objectAtIndex:indexPath.row];
    int n = [msg.fileType intValue];
    if(n == eMessageBodyType_Image)
        return 66+70;
    else
        if( n == eMessageBodyType_Voice)
            return 66;
        else
            if( n == eMessageBodyType_File)
                return 80;
            else{

                CGRect rect = [[_textArray[indexPath.row]content] boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                 NSStringDrawingUsesDeviceMetrics|
                 NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10.0],NSFontAttributeName, nil] context:0];
                if (rect.size.height < 60) {
                    return 60;
                }
                return rect.size.height + 40;
            }

}
-(void)refresh:(Message*)msg
{
    [_inputText setInputView:nil];
    [_inputText resignFirstResponder];
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
#pragma mark --textField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //让下面的输入框上去的效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    _bottomImageView.frame=CGRectMake(0, 480-216-44, 320, 44);
    _tableView.frame=CGRectMake(0, 64, 320, 480-64-216-44);
    [UIView commitAnimations];
    
    //输入框里有值才能使气泡上去
    if (_textArray.count>=1)
    {
        //cell滑动到最后一行
        NSIndexPath * indexPath =[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

//点键盘右下角会调用的方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //键盘右下角点击的时候也会调用发送的方法
    [self sendClickWithMsgType:eMessageBodyType_Text];
//    if (_textArray.count>=1)
//    {
//        NSIndexPath * indexPath =[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0];
//        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
    return YES;
}

//让输入框下去的方法
-(void)inputTextFieldDown
{
    
    [_inputText resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    _bottomImageView.frame=CGRectMake(0, SCREEN_SIZE.height - 44, SCREEN_SIZE.width, 44);
    _tableView.frame=CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height-64-44);
    _isChangedKeyBoard=NO;
    [UIView commitAnimations];
}
#pragma -mark 获取接收到的数据
- (void)getText:(NSNotification *)notify{
    NSDictionary *text = notify.userInfo[@"text"];
    NSString *nodeId = notify.userInfo[@"nodeId"];
    NSLog(@"haha====%@",text[@"content"]);
    Message *msg = [[Message alloc]initWithaDic:text];
//    [_textArray addObject:msg];
    [self showTableMsg:msg];
    
}
#pragma -mark 调用发送数据接口
- (id<UDSource>)frameData:(MessageBodyType)type withSendData:(id)data{
    
    UDLazySource *result = [[UDLazySource alloc]initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) block:^NSData * _Nullable{
        
//                NSData *newData = [@"nihaoa" dataUsingEncoding:NSUTF8StringEncoding];
        
        
        
        NSData *newData;
        Message *msg = [[Message alloc]init];
        UIDevice *myDevice = [UIDevice currentDevice];
        NSString *deviceUDID = [myDevice.identifierForVendor UUIDString];

        switch (type) {
            case eMessageBodyType_Text:
            {
                msg.content = data;
                msg.timestamp = [self getDate];
                msg.sender = @"1";
                msg.fileType = [NSString stringWithFormat:@"%ld",eMessageBodyType_Text];
                msg.msgId = deviceUDID;
                break;
            }
            case eMessageBodyType_Image:
            {
                newData = UIImageJPEGRepresentation(data, 0.5);
                msg.file = newData;
                msg.timestamp = [self getDate];
                msg.sender = @"1";
                msg.fileType = [NSString stringWithFormat:@"%ld",eMessageBodyType_Image];
                msg.msgId = deviceUDID;
                
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
        NSDictionary *msgDic = [NexfiUtil getObjectData:msg];
        newData = [NSJSONSerialization dataWithJSONObject:msgDic options:0 error:0];
        //刷新表
        [self showTableMsg:msg];
        //插入数据库
        
         
         
        return newData;
        
    }];
    
    return result;
}
-(void)showTableMsg:(Message *) msg
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [_textArray addObject:msg];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_textArray count]-1 inSection:0];
    [indexPaths addObject:indexPath];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_tableView reloadData];
}
//点击发送按钮调用的方法
-(void)sendClickWithMsgType:(MessageBodyType)type
{
    //限制输入框中的值为空的时候不能发送
    if ([_inputText.text isEqualToString:@""])
    {
        return;
    }
    
    [[UnderdarkUtil share].node broadcastFrame:[self frameData:type withSendData:_inputText.text]];

    //刷新表
    
        //点击发送过后输入框变为空
    _inputText.text=@"";
    
    
    
}

#pragma mark --改变键盘变成中文
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)keyboardWillShow:(NSNotification *)aNotification{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardF = [aValue CGRectValue];
    _tableView.frame = CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - keyboardF.size.height - 40);

}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardF = [aValue CGRectValue];
    _tableView.frame = CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height - keyboardF.size.height - 40);
    _bottomImageView.frame = CGRectMake(0, SCREEN_SIZE.height - keyboardF.size.height - _bottomImageView.frame.size.height, SCREEN_SIZE.width, _bottomImageView.frame.size.height);
}
-(void)keyboardDidChangeFrame:(NSNotification *)noti
{
    
    NSDictionary *userInfo = noti.userInfo;
    //动画时间
//    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //键盘高度
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _tableView.frame = CGRectMake(0, 64, SCREEN_SIZE.width, SCREEN_SIZE.height - keyboardF.size.height - 40);
    _bottomImageView.frame = CGRectMake(0, SCREEN_SIZE.height - keyboardF.size.height - _bottomImageView.frame.size.height, SCREEN_SIZE.width, _bottomImageView.frame.size.height);
    
}
#pragma -mark 获取当前时间
-(NSString *)getDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", strDate);
    return strDate;
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
