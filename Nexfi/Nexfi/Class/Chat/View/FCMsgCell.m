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
        _userHead =[[JXImageView alloc]initWithFrame:CGRectZero];
//        _headMask =[[JXImageView alloc]initWithFrame:CGRectZero];
        _chatImage=[[JXImageView alloc]initWithFrame:CGRectZero];
        _chatImage.JXImageDelegate = self;
        
        _bubbleBg =[UIButton buttonWithType:UIButtonTypeCustom];
        
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.backgroundColor = [UIColor clearColor];
        _messageConent.userInteractionEnabled = NO;
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = NSLineBreakByWordWrapping;
        _messageConent.font = [UIFont systemFontOfSize:15];
        _messageConent.offset = -12;
//        _messageConent.textAlignment = NSTextAlignmentCenter;
        
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

//        [_headMask setImage:[[UIImage imageNamed:@"UserHeaderImageBox"]stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
//        [_userHead setImage:[UIImage imageNamed:@"default_portrait_chat.png"]];
        
        _userHead.imageType = @"UserHead";
    }
    return self;
}
-(BOOL)isMeSend{
    //return [[msg sender] isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:kMY_USER_ID]];
//    LoginUserModel *loginUserModel = [LOGIN_USER loginUserModel];
//    UserModel *userModel = loginUserModel.userModel;
//
    
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
- (void)tapImage:(id)sender{
    if (self.msgDelegate && [self.msgDelegate respondsToSelector:@selector(clickPic:)]) {
        [self.msgDelegate clickPic:_bubbleBg.tag];
    }
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
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
//        _timeLabel.frame = CGRectMake(160, 0, 100, 8);
//        _timeLabel.textAlignment = NSTextAlignmentRight;
    }else{
        usersId = [msg sender];//msg.toUserId;
        [_userHead setFrame:CGRectMake(INSETS, 5, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
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
        if(isMe){
            
            bubbleX = SCREEN_SIZE.width - INSETS*2 - HEAD_SIZE - textSize.size.width - 30;
            bubbleY = 10;
            bubbleWidth = textSize.size.width + 40;
            bubbleHeight = textSize.size.height + 40;
            
            _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
            _messageConent.frame = CGRectMake(15, 12, textSize.size.width+10, textSize.size.height + 10);
//            _messageConent.textAlignment = NSTextAlignmentRight;
            
        }else
        {

            bubbleX = INSETS+HEAD_SIZE;
            bubbleY = 10;
            bubbleWidth = textSize.size.width + 40;
            bubbleHeight = textSize.size.height + 40;
            
            _bubbleBg.frame=CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight);
            _messageConent.frame = CGRectMake(15, 12, textSize.size.width+ 10, textSize.size.height + 10);
//            _messageConent.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    
    _messageConent.hidden = NO;
    if(msg.fileType ==eMessageBodyType_Image){
        
        if(isMe)
        {
            bubbleX = SCREEN_SIZE.width - INSETS*2 -HEAD_SIZE - 100;
            bubbleY = 15;
            bubbleWidth = 105;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];
               NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            _chatImage.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],content]];
            if (_chatImage.image) {
                _chatImage.frame = CGRectMake(10, 5, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);
                
                _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 20);
            }

        }
        else
        {
            bubbleX = 2*INSETS+HEAD_SIZE;
            bubbleY = 15;
            bubbleWidth = 105;
            bubbleHeight = 100;
            [_chatImage setHidden:NO];

            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:content];
            _chatImage.image = [UIImage imageWithData:imageData];
            

            
            _chatImage.frame = CGRectMake(15, 5, 80, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width);

            _bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleWidth, (float)(80*_chatImage.image.size.height)/(float)_chatImage.image.size.width + 20);

            

        }

    }
    
    
    if(msg.fileType ==eMessageBodyType_Voice){
        float w = (320-HEAD_SIZE-INSETS*2-50)/30;
        w = 50+w*3;//[msg.timeLen intValue];
        if(w<50)
            w = 50;
        if(w>200)
            w = 200;
        
        UIImageView* iv = [[UIImageView alloc] init];
        iv.image =  [UIImage imageNamed:@"VoiceNodePlaying@2x.png"];
        
        UILabel* p = [[UILabel alloc] init];
        p.text = [NSString stringWithFormat:@"%d''",[durational intValue]];
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor grayColor];
        p.font = [UIFont systemFontOfSize:11];
        
        if(isMe){
            iv.image =  [UIImage imageNamed:@"voice_to_default.png"];
            
            
            _bubbleBg.frame=CGRectMake(320-w-HEAD_SIZE-INSETS*2, 15, w, 45);
            iv.frame = CGRectMake(_bubbleBg.frame.size.width-35, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x-50, 30, 50, 15);
            p.textAlignment = NSTextAlignmentRight;
        }
        else{
            iv.image =  [UIImage imageNamed:@"voice_from_default.png"];
            
            
            _bubbleBg.frame=CGRectMake(INSETS*2+HEAD_SIZE, 15, w, 45);
            iv.frame = CGRectMake(15, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+3, 30, 50, 15);
            p.textAlignment = NSTextAlignmentLeft;
            //[self updateIsRead:true];//[msg.isRead boolValue]];
        }
        
        [self.contentView addSubview:p];
        [_bubbleBg addSubview:iv];
        

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
