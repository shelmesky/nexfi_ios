//
//  FCMsgCell.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "FCMsgCell.h"
#import "JXEmoji.h"
#import "SCGIFImageView.h"

@implementation FCMsgCell
@synthesize index,delegate,didTouch,msg;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _drawed = NO;
        //用户头像
        _userHead =[[JXImageView alloc]initWithFrame:CGRectZero];
        _userHead.imageType = HeadPicType;
        _userHead.userInteractionEnabled = YES;
//        _headMask =[[JXImageView alloc]initWithFrame:CGRectZero];
        //聊天图片
        _chatImage=[[JXImageView alloc]initWithFrame:CGRectZero];
        _chatImage.userInteractionEnabled = YES;
        _chatImage.imageType = ChatPicType;
        //气泡背景
        _bubbleBg =[UIButton buttonWithType:UIButtonTypeCustom];
//        _bubbleBg.userInteractionEnabled = YES;
        //文本
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.backgroundColor = [UIColor clearColor];
        _messageConent.userInteractionEnabled = YES;
        _messageConent.hidden = YES;
        _messageConent.backgroundColor = [UIColor redColor];
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = NSLineBreakByWordWrapping;
        _messageConent.font = [UIFont systemFontOfSize:15];
        _messageConent.offset = -12;
//        _messageConent.textAlignment = NSTextAlignmentCenter;
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:8];
        
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
//        [self.contentView addSubview:_headMask];
        [_bubbleBg addSubview:_messageConent];
        [_bubbleBg addSubview:_chatImage];
        [self.contentView addSubview:_timeLabel];
        
        _messageConent.hidden = YES;
        [_chatImage setHidden:YES];
        [_messageConent setHidden:YES];
        
        [_chatImage setBackgroundColor:[UIColor redColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.contentView addSubview:self.messageSendStateIV];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.contentView addGestureRecognizer:tap];

    }
    return self;
}
- (void)sendVoiceMesState:(FNVoiceMessageState)voiceMessageState{
    if (voiceMessageState == FNVoiceMessageStateNormal) {
//        self.messageVoiceStatusIV.hidden = YES;
        [self.messageVoiceStatusIV stopAnimating];
    }else if (voiceMessageState == FNVoiceMessageStatePlaying){
//        self.messageVoiceStatusIV.hidden = NO;
        [self.messageVoiceStatusIV startAnimating];
    }else if (voiceMessageState == FNVoiceMessageStateCancel){
//        self.messageVoiceStatusIV.hidden = YES;
        [self.messageVoiceStatusIV stopAnimating];
    }
}
- (UIImageView *)messageVoiceStatusIV {
    if (!_messageVoiceStatusIV) {
        _messageVoiceStatusIV = [[UIImageView alloc] init];
        _messageVoiceStatusIV.userInteractionEnabled = YES;
        _messageVoiceStatusIV.image = ![self isMeSend] ? [UIImage imageNamed:@"message_voice_receiver_normal"] : [UIImage imageNamed:@"message_voice_sender_normal"];
        UIImage *image1 = [UIImage imageNamed:[self isMeSend] ? @"message_voice_sender_playing_1" : @"message_voice_receiver_playing_1"];
        UIImage *image2 = [UIImage imageNamed:[self isMeSend] ? @"message_voice_sender_playing_2" : @"message_voice_receiver_playing_2"];
        UIImage *image3 = [UIImage imageNamed:[self isMeSend] ? @"message_voice_sender_playing_3" : @"message_voice_receiver_playing_3"];
        _messageVoiceStatusIV.animationImages = @[image1,image2,image3];
        _messageVoiceStatusIV.animationDuration = 1;
//        _messageVoiceStatusIV.animationRepeatCount = NSUIntegerMax;
    }
    return _messageVoiceStatusIV;
}
- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(_bubbleBg.frame, tapPoint)) {//点击bubble
            if (msg.fileType == eMessageBodyType_Text) {//文本
                
            }else if (msg.fileType == eMessageBodyType_Image){//图片
                if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickPic:)]) {
                    [self.msgDelegate clickPic:index];
                }
            }else if(msg.fileType == eMessageBodyType_Voice){//语音
                if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(msgCellTappedContent:)]) {
                    [self.msgDelegate msgCellTappedContent:self];
                }
            }
        }else if (CGRectContainsPoint(_userHead.frame, tapPoint)) {//头像
            if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickUserHeadPic:)]) {
                [self.msgDelegate clickUserHeadPic:index];
            }
        }else{//任何区域
            if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(msgCellTappedBlank:)]) {
                [self.msgDelegate msgCellTappedBlank:self];
            }
        }
    }
}
-(BOOL)isMeSend{
    
    return [[msg sender] isEqualToString:[[UserManager shareManager]getUser].userId];
    
}
- (void)setMessageSendState:(FNMessageSendState)messageSendState{
    _messageSendState = messageSendState;
    if (![self isMeSend]) {
        self.messageSendStateIV.hidden = YES;
    }
    self.messageSendStateIV.messageSendState = messageSendState;
}
- (FNSendImageView *)messageSendStateIV{
    if (!_messageSendStateIV) {
        _messageSendStateIV = [[FNSendImageView alloc]init];
    }
    return _messageSendStateIV;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self draw];
}
-(void)setMsg:(Message *)aMessage
{
    NSString *content ;
    if ([aMessage isKindOfClass:[PersonMessage class]]) {
        PersonMessage *pMsg = (PersonMessage *)aMessage;
        content = pMsg.pContent;
        msg = pMsg;
    }else if ([aMessage isKindOfClass:[TribeMessage class]]){
        TribeMessage *tMsg = (TribeMessage *)aMessage;
        content = tMsg.tContent;
        msg = tMsg;
    }
    if(aMessage.fileType  == eMessageBodyType_Text)
        _messageConent.text = content;

}

-(void)setHeadImage:(UIImage*)headImage
{
    if(headImage)
        [_userHead setImage:headImage];
}

//-(void)setHeadImageWithURL:(NSURL*) imgUrl
//{
//    if (imgUrl)
//        [_userHead setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"default_portrait_chat.png"]];
//    
//}
-(void)setChatImage:(UIImage *)chatImage
{
    [_chatImage setImage:chatImage];
}

//-(void)setChatImageWithURL:(NSURL *)chatImageUrl
//{
//    if (chatImageUrl)
//        [_chatImage setImageWithURL:chatImageUrl placeholderImage:[UIImage imageNamed:@"default_portrait_chat.png"]];
//}

-(void)setIndex:(int)value{
    index = value;
    _userHead.tag = index;
    _bubbleBg.tag = index;
    _messageConent.tag= index;
    _headMask.tag = index;
    _chatImage.tag = index;
    _messageConent.tag = index;
}

-(void)setDelegate:(NSObject *)value{
    delegate = value;
    
    _userHead.delegate = value;
    _messageConent.delegate= value;
    _headMask.delegate = value;
    _chatImage.delegate = value;
    _messageConent.delegate = value;
    if(delegate && didTouch)
        [_bubbleBg addTarget:delegate action:didTouch forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setDidTouch:(SEL)value{
    didTouch = value;
    _userHead.didTouch = value;
    _messageConent.didTouch= value;
    _headMask.didTouch = value;
    _chatImage.didTouch = value;
    _messageConent.didTouch = value;
    if(delegate && didTouch)
        [_bubbleBg addTarget:delegate action:didTouch forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)updateIsRead:(BOOL)b{
    if(b)
        _readImage.hidden = YES;
    else{
        if(_readImage==nil)
            _readImage=[[JXImageView alloc]initWithImage:[UIImage imageNamed:@"VoiceNodeUnread"]];
        _readImage.hidden = NO;
        if([self isMeSend]){
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-15, _bubbleBg.frame.origin.y+5, 11, 11);
        }
        else{
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+1, _bubbleBg.frame.origin.y+5, 11, 11);
        }
        
        [self.contentView addSubview:_readImage];
    }
}
- (void)tapImage:(NSUInteger)sender{
//    if (sender == ChatPicType) {//点击图片放大
//        if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickPic:)]) {
//            [self.msgDelegate clickPic:_bubbleBg.tag];
//        }
//    }else{//点击头像
//        if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickUserHeadPic:)]) {
//            [self.msgDelegate clickUserHeadPic:_bubbleBg.tag];
//        }
//    }

}
-(void)draw{
    if(_drawed)
        return;
    _drawed = YES;
    BOOL isMe=[self isMeSend];
//    CGSize textSize = _messageConent.frame.size;

    NSString *content ;
    NSString *durational;
    PersonMessage *pMsg;
    TribeMessage *tMsg;
    if ([msg isKindOfClass:[PersonMessage class]]) {
        pMsg = (PersonMessage *)msg;
        content = pMsg.pContent;
        durational = pMsg.durational;
    }else if ([msg isKindOfClass:[TribeMessage class]]){
        tMsg = (TribeMessage *)msg;
        content = tMsg.tContent;
        durational = tMsg.durational;
    }
    
    CGRect textSize = [content boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                   NSStringDrawingUsesDeviceMetrics|
                   NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
    NSString* usersId;
    
    
    if(isMe){
        usersId = [msg sender];//msg.fromUserId;
        [_userHead setFrame:CGRectMake(SCREEN_SIZE.width-INSETS-HEAD_SIZE, 5, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_sender_background_normal"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_sender_background_highlight"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];//message_receiver_background_normal  message_receiver_background_highlight
        
//        _timeLabel.frame = CGRectMake(160, 0, 100, 8);
//        _timeLabel.textAlignment = NSTextAlignmentRight;
    }else{
        usersId = [msg sender];//msg.toUserId;
        [_userHead setFrame:CGRectMake(INSETS, 5, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_receiver_background_normal"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_receiver_background_highlight"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
//        _timeLabel.frame = CGRectMake(80, 0, 100, 8);
//        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    _timeLabel.bounds = CGRectMake(0, 0, 100, 8);
    _timeLabel.center = CGPointMake(SCREEN_SIZE.width/2, 4);
    _timeLabel.textAlignment = NSTextAlignmentCenter;

    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"MM-dd HH:mm"];
    _timeLabel.text = [msg timestamp];//[f stringFromDate:[msg timestamp]];
    
    float bubbleY;
    float bubbleX;
    float bubbleWidth;
    float bubbleHeight;
    
    if(msg.fileType ==eMessageBodyType_Text){
        _messageConent.hidden = NO;
        _chatImage.hidden = YES;
        if(isMe){
            
            bubbleX = SCREEN_SIZE.width - INSETS*2 - HEAD_SIZE - textSize.size.width - 40;
            bubbleY = 10;
            bubbleWidth = textSize.size.width + 40;
            bubbleHeight = textSize.size.height + 35;
            if (textSize.size.height < 15) {
                bubbleHeight = 15 + 35;
            }
            
            _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
            _messageConent.bounds = CGRectMake(0, 0, textSize.size.width+15, textSize.size.height + 15);
            _messageConent.center = CGPointMake(bubbleWidth/2, bubbleHeight/2);
//            _messageConent.textAlignment = NSTextAlignmentRight;
            
        }else
        {

            bubbleX = 2*INSETS+HEAD_SIZE;
            bubbleY = 10;
            bubbleWidth = textSize.size.width + 40;
            bubbleHeight = textSize.size.height + 35;
            if (textSize.size.height < 15) {
                bubbleHeight = 15 + 35;
            }
            
            _bubbleBg.frame=CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
            _messageConent.bounds = CGRectMake(0, 0, textSize.size.width+ 15, textSize.size.height + 15);
            _messageConent.center = CGPointMake(bubbleWidth/2, bubbleHeight/2);
//            _messageConent.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    
    if(msg.fileType ==eMessageBodyType_Image){
        _messageConent.hidden = YES;
        _chatImage.hidden = NO;
        if(isMe)
        {
            bubbleX = SCREEN_SIZE.width - INSETS*2 -HEAD_SIZE - 100;
            bubbleY = 15;
            bubbleWidth = 100;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];
               NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            _chatImage.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],content]];
            if (_chatImage.image) {
                _chatImage.frame = CGRectMake(10, 7, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);
                
                _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 14);
            }

        }
        else
        {
            bubbleX = 2*INSETS+HEAD_SIZE;
            bubbleY = 15;
            bubbleWidth = 100;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];

            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:content];
            _chatImage.image = [UIImage imageWithData:imageData];
            

            
            _chatImage.frame = CGRectMake(10, 7, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);

            _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 14);


        }

    }
    
    
    if(msg.fileType ==eMessageBodyType_Voice){
        float w = (SCREEN_SIZE.width-HEAD_SIZE-INSETS*2-50)/30;
        w = 50+w*3;//[msg.timeLen intValue];
        if(w<50)
            w = 50;
        if(w>200)
            w = 200;
        //录音喇叭 图片
//        UIImageView* iv = [[UIImageView alloc] init];
        //录音时间
        UILabel* p = [[UILabel alloc] init];
        p.text = [NSString stringWithFormat:@"%d''",[durational intValue]];
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor grayColor];
        p.font = [UIFont systemFontOfSize:11];
        //根据总时间计算bubble的宽度
        float bubbleTotalW  = SCREEN_SIZE.width - (2*INSETS + HEAD_SIZE + 20)*2;//bubble最大宽度
        float perSecWidth = (float)(bubbleTotalW - w)/60;//没秒bubble增大的宽度
        

        CGFloat BubbleEndW = ([durational intValue] - 3)*perSecWidth + w; //大于3的bubble的长度
        CGFloat BubbleOrX = SCREEN_SIZE.width-BubbleEndW-HEAD_SIZE-INSETS*2;
        if(isMe){
//            iv.image =  [UIImage imageNamed:@"message_voice_sender_normal"];
            
            _bubbleBg.frame = [durational intValue] > 3?CGRectMake(BubbleOrX, 10, BubbleEndW, 50):CGRectMake(SCREEN_SIZE.width-w-HEAD_SIZE-INSETS*2, 10, w, 50);
            self.messageVoiceStatusIV.frame = CGRectMake(_bubbleBg.frame.size.width-35, 15, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x-50, 30, 50, 15);
            p.textAlignment = NSTextAlignmentRight;
        }
        else{
//            iv.image =  [UIImage imageNamed:@"message_voice_receiver_normal"];
            
            _bubbleBg.frame=CGRectMake(2*INSETS+HEAD_SIZE, 10, BubbleEndW, 50);
            self.messageVoiceStatusIV.frame = CGRectMake(15, 15, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+3, 30, 50, 15);
            p.textAlignment = NSTextAlignmentLeft;
            
            //[self updateIsRead:true];//[msg.isRead boolValue]];
        }
        
        [self.contentView addSubview:p];
        [_bubbleBg addSubview:self.messageVoiceStatusIV];
        

#ifdef IS_TEST_VERSION
        [self updateIsRead:true];//[msg.isRead boolValue]];
#endif
    }
    
    
//    if ([msg.fileType intValue]==kWCMessageTypeGif){
//        [_bubbleBg setHidden:YES];
//        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[msg.file lastPathComponent]];
//        SCGIFImageView* iv = [[SCGIFImageView alloc] initWithGIFFile:path];
//        if(isMe)
//            iv.frame = CGRectMake(180, 0, 80, 80);//185
//        else
//            iv.frame = CGRectMake(INSETS*2+HEAD_SIZE, 0, 80, 80);
//        [self.contentView addSubview:iv];
//        [iv release];
//    }
    
    if ([self isMeSend]) {
        self.messageSendStateIV.frame = CGRectMake(_bubbleBg.frame.origin.x - 20, _bubbleBg.center.y - 10, 10, 10);
    }

    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
