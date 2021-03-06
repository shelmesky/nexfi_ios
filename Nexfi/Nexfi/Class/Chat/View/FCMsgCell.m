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
        _bubbleBg.userInteractionEnabled = YES;
        
        //文本
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.userInteractionEnabled = YES;
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = NSLineBreakByWordWrapping;
        _messageConent.font = [UIFont systemFontOfSize:15];
        _messageConent.offset = -12;

        //语音文本 点击背景播放语音用的
        _voiceContent =[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _voiceContent.userInteractionEnabled = YES;
        _voiceContent.numberOfLines = 0;
        _voiceContent.lineBreakMode = NSLineBreakByWordWrapping;
        _voiceContent.font = [UIFont systemFontOfSize:15];
        _voiceContent.offset = -12;
        
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:8];
        
        //录音时间
        _durationLa = [[UILabel alloc] init];
        _durationLa.textColor = [UIColor grayColor];
        _durationLa.font = [UIFont systemFontOfSize:11];
        
        //姓名
        _nickName = [[UILabel alloc]initWithFrame:CGRectZero];
        _nickName.textColor = [UIColor blackColor];
        _nickName.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:_nickName];
        [self.contentView addSubview:_durationLa];
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
        
        [_bubbleBg addSubview:_messageConent];
        [_bubbleBg addSubview:_voiceContent];
        [_bubbleBg addSubview:_chatImage];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:self.messageSendStateIV];

        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        
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
            if (msg.messageBodyType == eMessageBodyType_Text) {//文本
                
            }else if (msg.messageBodyType == eMessageBodyType_Image){//图片
                if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickPic:)]) {
                    [self.msgDelegate clickPic:index];
                }
            }else if(msg.messageBodyType == eMessageBodyType_Voice){//语音
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
-(void)updateIsRead:(BOOL)b{
    if(b)
        _readImage.hidden = YES;
    else{
        if(_readImage==nil)
            _readImage=[[JXImageView alloc]initWithImage:[UIImage imageNamed:@"VoiceNodeUnread"]];
        _readImage.hidden = NO;
        if([self isMeSend]){
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-10, _bubbleBg.frame.origin.y+10, 6, 6);
        }
        else{
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+1, _bubbleBg.frame.origin.y+10, 6, 6);
        }
        
        [self.contentView addSubview:_readImage];
    }
}
-(BOOL)isMeSend{
    
    return [msg.userMessage.userId isEqualToString:[[UserManager shareManager]getUser].userId];
    
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
- (void)setMsg:(Message *)aMessage{
    msg = aMessage;
    
    NSString *content ;
    NSString *durational;
    NSString *nick;
    PersonMessage *pMsg;
    TribeMessage *tMsg;
    NSString *isRead;
    if ([msg isKindOfClass:[PersonMessage class]]) {
        pMsg = (PersonMessage *)msg;
        if (pMsg.messageBodyType == eMessageBodyType_Text) {
            content = pMsg.textMessage.fileData;
            isRead = pMsg.textMessage.isRead;
        }else if (pMsg.messageBodyType == eMessageBodyType_Image){
            content = pMsg.fileMessage.fileData;
            isRead = pMsg.fileMessage.isRead;
        }else if (pMsg.messageBodyType == eMessageBodyType_Voice){
            content = pMsg.voiceMessage.fileData;
            isRead = pMsg.voiceMessage.isRead;
            durational = pMsg.voiceMessage.durational;
        }
        
        nick = pMsg.userMessage.userNick;
        
    }else if ([msg isKindOfClass:[TribeMessage class]]){
        tMsg = (TribeMessage *)msg;
        if (tMsg.messageBodyType == eMessageBodyType_Text) {
            content = tMsg.textMessage.fileData;
            isRead = tMsg.textMessage.isRead;
        }else if (tMsg.messageBodyType == eMessageBodyType_Image){
            content = tMsg.fileMessage.fileData;
            isRead = tMsg.fileMessage.isRead;
        }else if (tMsg.messageBodyType == eMessageBodyType_Voice){
            content = tMsg.voiceMessage.fileData;
            isRead = tMsg.voiceMessage.isRead;
            durational = tMsg.voiceMessage.durational;
        }
        
        nick = tMsg.userMessage.userNick;
        
    }
    
    if (self.to_User) {
        nick = self.to_User.userNick;
    }
    if(aMessage.messageBodyType  == eMessageBodyType_Text)
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
    
    NSString *content ;
    NSString *durational;
    NSString *nick;
    PersonMessage *pMsg;
    TribeMessage *tMsg;
    NSString *isRead;
    if ([msg isKindOfClass:[PersonMessage class]]) {
        pMsg = (PersonMessage *)msg;
        if (pMsg.messageBodyType == eMessageBodyType_Text) {
            content = pMsg.textMessage.fileData;
            isRead = pMsg.textMessage.isRead;
        }else if (pMsg.messageBodyType == eMessageBodyType_Image){
            content = pMsg.fileMessage.fileData;
            isRead = pMsg.fileMessage.isRead;
        }else if (pMsg.messageBodyType == eMessageBodyType_Voice){
            content = pMsg.voiceMessage.fileData;
            isRead = pMsg.voiceMessage.isRead;
            durational = pMsg.voiceMessage.durational;
        }
        
        nick = pMsg.userMessage.userNick;
        
    }else if ([msg isKindOfClass:[TribeMessage class]]){
        tMsg = (TribeMessage *)msg;
        if (tMsg.messageBodyType == eMessageBodyType_Text) {
            content = tMsg.textMessage.fileData;
            isRead = tMsg.textMessage.isRead;
        }else if (tMsg.messageBodyType == eMessageBodyType_Image){
            content = tMsg.fileMessage.fileData;
            isRead = tMsg.fileMessage.isRead;
        }else if (tMsg.messageBodyType == eMessageBodyType_Voice){
            content = tMsg.voiceMessage.fileData;
            isRead = tMsg.voiceMessage.isRead;
            durational = tMsg.voiceMessage.durational;
        }
        
        nick = tMsg.userMessage.userNick;
        
    }
    
    if (self.to_User) {
        nick = self.to_User.userNick;
    }

    
    
    
    BOOL isMe=[NexfiUtil isMeSend:msg];
    
    
    
    CGRect textSize = [content boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0],NSFontAttributeName, nil] context:0];
    
    CGRect nickSize = [nick boundingRectWithSize:CGSizeMake(999, 20) options:NSStringDrawingUsesLineFragmentOrigin|
                       NSStringDrawingUsesDeviceMetrics|
                       NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0],NSFontAttributeName, nil] context:0];
    
    
    if(isMe){
        [_userHead setFrame:CGRectMake(SCREEN_SIZE.width-INSETS-HEAD_SIZE, 15, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_sender_background_normal"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_sender_background_highlight"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        _nickName.hidden = YES;
        
    }else{
        [_userHead setFrame:CGRectMake(INSETS, 15, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_receiver_background_normal"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"message_receiver_background_highlight"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        
        _nickName.frame = CGRectMake(_userHead.x + _userHead.width + 5, 15, nickSize.size.width + 10, 20);
        _nickName.text = nick;
        _nickName.font = [UIFont systemFontOfSize:12.0];
        _nickName.textAlignment = NSTextAlignmentLeft;
        _nickName.hidden = NO;
        
    }
    
    _timeLabel.bounds = CGRectMake(0, 0, 100, 8);
    _timeLabel.center = CGPointMake(SCREEN_SIZE.width/2, 4);
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"MM-dd HH:mm"];
    _timeLabel.text = [msg timeStamp];
    
    float bubbleY;
    float bubbleX;
    float bubbleWidth;
    float bubbleHeight;
    
    if(msg.messageBodyType ==eMessageBodyType_Text){
        _messageConent.hidden = NO;
        _chatImage.hidden = YES;
        _durationLa.hidden = YES;
        _voiceContent.hidden = YES;
        if(isMe){
            
            bubbleX = SCREEN_SIZE.width - INSETS*2 - HEAD_SIZE - textSize.size.width - 40;
            bubbleY = 15;
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
            bubbleY = 35;
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
        
        _messageConent.text = content;
        
    }
    
    
    if(msg.messageBodyType ==eMessageBodyType_Image){
        _messageConent.hidden = YES;
        _chatImage.hidden = NO;
        _durationLa.hidden = YES;
        _voiceContent.hidden = YES;
        if(isMe)
        {
            bubbleX = SCREEN_SIZE.width - INSETS*2 -HEAD_SIZE - 100;
            bubbleY = 15;
            bubbleWidth = 100;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];
            
            
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:content];
            _chatImage.image = [UIImage imageWithData:imageData];
            if (_chatImage.image) {
                _chatImage.frame = CGRectMake(10, 7, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);
                
                _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 14);
            }
            
        }
        else
        {
            bubbleX = 2*INSETS+HEAD_SIZE;
            bubbleY = 35;
            bubbleWidth = 100;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];
            
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:content];
            _chatImage.image = [UIImage imageWithData:imageData];
            
            
            
            _chatImage.frame = CGRectMake(10, 7, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);
            
            _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 14);
            
            
        }
        
    }
    
    if(msg.messageBodyType ==eMessageBodyType_Voice){
        _messageConent.hidden = YES;
        _chatImage.hidden = YES;
        _durationLa.hidden = NO;
        _voiceContent.hidden = NO;
        
        float w = 70;
        
        //录音喇叭 图片
        //        UIImageView* iv = [[UIImageView alloc] init];
        //录音时间
        _durationLa.text = [NSString stringWithFormat:@"%d''",[durational intValue]];
        
        //根据总时间计算bubble的宽度
        float bubbleTotalW  = SCREEN_SIZE.width - (2*INSETS + HEAD_SIZE + 20)*2;//bubble最大宽度
        float perSecWidth = (float)(bubbleTotalW - w)/60;//没秒bubble增大的宽度
        
        
        CGFloat BubbleEndW = ([durational intValue] - 3)*perSecWidth + w; //大于3的bubble的长度
        CGFloat BubbleOrX = SCREEN_SIZE.width-BubbleEndW-HEAD_SIZE-INSETS*2;
        if(isMe){
            
            _bubbleBg.frame = [durational intValue] > 3?CGRectMake(BubbleOrX, 15, BubbleEndW, 50):CGRectMake(SCREEN_SIZE.width-w-HEAD_SIZE-INSETS*2, 10, w, 50);
            _voiceContent.frame = CGRectMake(0, 0, _bubbleBg.frame.size.width, _bubbleBg.frame.size.height);
            self.messageVoiceStatusIV.frame = CGRectMake(_bubbleBg.frame.size.width-35, 15, 19, 19);
            _durationLa.bounds = CGRectMake(0, 0, 50, 15);
            _durationLa.center = CGPointMake(_bubbleBg.frame.origin.x-50 + 25, _bubbleBg.center.y);
            _durationLa.textAlignment = NSTextAlignmentRight;
        }
        else{
            
            _bubbleBg.frame=CGRectMake(2*INSETS+HEAD_SIZE, 35, BubbleEndW, 50);
            _voiceContent.frame = CGRectMake(0, 0, _bubbleBg.frame.size.width, _bubbleBg.frame.size.height);
            self.messageVoiceStatusIV.frame = CGRectMake(15, 15, 19, 19);
            _durationLa.bounds = CGRectMake(0, 0, 50, 15);
            _durationLa.center = CGPointMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+3 + 25, _bubbleBg.center.y);
            _durationLa.textAlignment = NSTextAlignmentLeft;
            
            //语音已读 未读
            //            [isRead isEqualToString:@"1"]?[self updateIsRead:YES]:[self updateIsRead:NO];
        }
        
        [_voiceContent addSubview:self.messageVoiceStatusIV];
        
        
        
    }
     
    
    
//    if ([self isMeSend]) {
//        self.messageSendStateIV.frame = CGRectMake(_bubbleBg.frame.origin.x - 20, _bubbleBg.center.y - 10, 10, 10);
//    }

    
    
    
    
    
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
