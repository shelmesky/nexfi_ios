//
//  FCMsgCell.m
//  Nexfi
//
//  Created by fyc on 16/4/5.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "FCMsgCell.h"
#import "JXEmoji.h"
#import "SCGIFImageView.h"
#import "JXImageView.h"

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
        
        _bubbleBg =[UIButton buttonWithType:UIButtonTypeCustom];
        
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.backgroundColor = [UIColor clearColor];
        _messageConent.userInteractionEnabled = NO;
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = NSLineBreakByWordWrapping;
        _messageConent.font = [UIFont systemFontOfSize:10];
        _messageConent.offset = -12;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:8];
        
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
//        [self.contentView addSubview:_headMask];
        [self.contentView addSubview:_messageConent];
        [self.contentView addSubview:_chatImage];
        [self.contentView addSubview:_timeLabel];
        
        _messageConent.hidden = YES;
        [_chatImage setHidden:YES];
        [_messageConent setHidden:YES];
        
        [_chatImage setBackgroundColor:[UIColor redColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
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
//    return [[msg sender] isEqualToString:[NSString stringWithFormat:@"%@",userModel.id]];
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self draw];
}
-(void)setMsg:(Message *)aMessage
{
    msg = aMessage;
    if([aMessage.fileType intValue] == eMessageBodyType_Text)
        _messageConent.text = aMessage.content;
    
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

-(void)draw{
    if(_drawed)
        return;
    _drawed = YES;
    BOOL isMe=[self isMeSend];
//    CGSize textSize = _messageConent.frame.size;

    CGRect textSize = [self.msg.content boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin|
                   NSStringDrawingUsesDeviceMetrics|
                   NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10.0],NSFontAttributeName, nil] context:0];
    NSString* s;
    
    
    if(isMe){
        s = [msg sender];//msg.fromUserId;
        [_userHead setFrame:CGRectMake(SCREEN_SIZE.width-INSETS-HEAD_SIZE, 5, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        _timeLabel.frame = CGRectMake(160, 0, 100, 8);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }else{
        s = [msg receiver];//msg.toUserId;
        [_userHead setFrame:CGRectMake(INSETS, 5, HEAD_SIZE, HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        _timeLabel.frame = CGRectMake(80, 0, 100, 8);
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    //[self setHeadImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:s]]]];
    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"MM-dd HH:mm"];
    _timeLabel.text = [msg timestamp];//[f stringFromDate:[msg timestamp]];
    
    if([msg.fileType intValue]==eMessageBodyType_Text){
        if(isMe){
            [_messageConent setHidden:NO];
            //_messageConent.textColor =[UIColor whiteColor];
            [_messageConent setFrame:CGRectMake(SCREEN_SIZE.width-INSETS*2-HEAD_SIZE-textSize.size.width-15, (self.contentView.frame.size.height-textSize.size.height)/2, textSize.size.width, textSize.size.height)];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.size.width+30, textSize.size.height+30);
        }else
        {
            [_messageConent setHidden:NO];
            [_messageConent setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (self.contentView.frame.size.height-textSize.size.height)/2, textSize.size.width, textSize.size.height)];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.size.width+30, textSize.size.height+30);
        }
    }
    
    
    if([msg.fileType intValue]==eMessageBodyType_Image){
        if(isMe)
        {
            [_chatImage setHidden:NO];
            [_chatImage setFrame:CGRectMake(SCREEN_SIZE.width-INSETS*2-HEAD_SIZE-90, INSETS*2, 80, 80)];
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-10, INSETS, 100+5, 100+5);
            
            //UIImage * img = [UIImage imageNamed:msg.content];
            //[self setChatImage:img];
            UIImage *img = [UIImage imageWithData:msg.file];
//            [self setChatImage:[[UIImage alloc] initWithContentsOfFile:msg.content]];
            [self setChatImage:img];
        }
        else
        {
            [_chatImage setHidden:NO];
            [_chatImage setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, INSETS*2,80,80)];
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-15, INSETS, 100+5, 100+5);
            
            //[self setChatImage:[UIImage imageWithData:[msg file]]];
//            NSURL* url = [NSURL URLWithString:msg.content];
            // NSData *data = [NSData dataWithContentsOfURL:url];
            //[self setChatImage:[UIImage imageWithData:data]];
            
//            [self setChatImageWithURL:url];
            UIImage *img = [UIImage imageWithData:msg.file];
            [self setChatImage:img];
            //[self setChatImage:[UIImage imageWithData:data]];
        }
        //[self setChatImage:[UIImage imageWithData:[msg file]]];
    }
    
    
    if([msg.fileType intValue]==eMessageBodyType_Voice){
        float w = (320-HEAD_SIZE-INSETS*2-50)/30;
        w = 50+w*3;//[msg.timeLen intValue];
        if(w<50)
            w = 50;
        if(w>200)
            w = 200;
        
        UIImageView* iv = [[UIImageView alloc] init];
        iv.image =  [UIImage imageNamed:@"VoiceNodePlaying@2x.png"];
        
        UILabel* p = [[UILabel alloc] init];
        p.text = [NSString stringWithFormat:@"%d''",[msg.durational intValue]];
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor grayColor];
        p.font = [UIFont systemFontOfSize:11];
        
        if(isMe){
            iv.image =  [UIImage imageNamed:@"voice_to_default.png"];
            
            
            _bubbleBg.frame=CGRectMake(320-w-HEAD_SIZE-INSETS*2, 15, w, 45);
            iv.frame = CGRectMake(_bubbleBg.frame.size.width-35, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x-50, 30, 50, 15);
            p.textAlignment = UITextAlignmentRight;
        }
        else{
            iv.image =  [UIImage imageNamed:@"voice_from_default.png"];
            
            
            _bubbleBg.frame=CGRectMake(INSETS*2+HEAD_SIZE, 15, w, 45);
            iv.frame = CGRectMake(15, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+3, 30, 50, 15);
            p.textAlignment = UITextAlignmentLeft;
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
