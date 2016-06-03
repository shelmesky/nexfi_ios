//
//  JXEmoji.m
//  sjvodios
//
//  Created by jixiong on 13-7-9.
//
//

#import "JXEmoji.h"

@implementation JXEmoji
@synthesize maxWidth,faceHeight,faceWidth,offset;

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

static NSArray        *faceArray;
static NSMutableArray *writefaceArray;
static NSMutableArray *imageArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if(faceArray==nil){
            faceArray = [[NSArray alloc]initWithObjects:@"[微笑]",@"[大笑]",@"[调皮]",@"[害怕]",@"[得意]",@"[生气]",@"[撇嘴]",@"[冷汗]",@"[大哭]",@"[吓]",@"[鄙视]",@"[难过]",@"[赞]",@"[见钱眼开]",@"[疑问]",@"[抓狂]",@"[吐]",@"[想]",@"[委屈]",@"[色]",@"[发呆]",
                         @"[偷笑]",@"[尴尬]",@"[鼓掌]",@"[坏笑]",@"[眨眼]",@"[流汗]",@"[可怜]",@"[睡]",@"[惊恐]",@"[发怒]",
                         @"[惊讶]",@"[咒骂]",
                         @"[爱心]",@"[心碎]",@"[玫瑰]",@"[礼物]",@"[彩虹]",@"[月亮]",@"[太阳]",
                         @"[金钱]",@"[灯泡]",@"[咖啡]",@"[蛋糕]",@"[音符]",@"[爱你]",@"[胜利]",@"[强]",@"[差劲]",@"[OK]",nil];
            
            imageArray = [[NSMutableArray alloc] init];
            writefaceArray = [[NSMutableArray alloc] init];
            for (int i = 0;i<[faceArray count];i++){
                NSString* s = [NSString stringWithFormat:@"%@write_face_%d.png",[self imageFilePath],i+1];
                [imageArray addObject:s];
                
                NSString* s1 = [NSString stringWithFormat:@"[write_face_%d]",i+1];
                [writefaceArray addObject:s1];
                }
        }
        
        
        data = [[NSMutableArray alloc] init];
        faceWidth  = 18;
        faceHeight = 18;
        _top       = 0;
        offset     = 0;
        maxWidth   = frame.size.width;
        self.numberOfLines = 0;
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.textAlignment = UITextAlignmentLeft;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)dealloc{
    [data release];
    [super dealloc];
}

- (NSString *)imageFilePath {
    NSString *s=[[NSBundle mainBundle] bundlePath];
    s = [s stringByAppendingString:@"/"];
    //NSLog(@"%@",s);
    return s;
}

-(void) drawRect:(CGRect)rect
{
    [self.textColor set];
    if( [data count]==1){
        if (![self.text hasPrefix:BEGIN_FLAG] && ![self.text hasSuffix:END_FLAG])
            [super drawRect:rect];
        return;
    }
    _size = self.font.lineHeight;
	CGFloat upX=0;
	CGFloat upY=0;
//    NSLog(@"%f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    for (int i=0;i<[data count];i++) {
        NSString *str=[data objectAtIndex:i];
        unsigned long n = NSNotFound;
        
        if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG]) {
            n = [faceArray indexOfObject:str];
            if(n != NSNotFound){
                NSString *imageName = [imageArray objectAtIndex:n];
                UIImage *img=[UIImage imageWithContentsOfFile:imageName];
                [img drawInRect:CGRectMake(upX, upY+_top, faceWidth, faceHeight)];
                upX=faceWidth+upX;
                //中间换行计算高度
                if (upX >= maxWidth)
                {
                    upY = upY + _size;
                    upX = 0;
                }
//                NSLog(@"%@,%f,%f",str,upX,upY);
            }
        }
        if ([str hasPrefix:@"[write_face_"]&&[str hasSuffix:END_FLAG]) {
            n = [writefaceArray indexOfObject:str];
            if(n != NSNotFound){
                NSString *imageName = [imageArray objectAtIndex:n];
                UIImage *img=[UIImage imageWithContentsOfFile:imageName];
                [img drawInRect:CGRectMake(upX, upY+_top, faceWidth, faceHeight)];
                upX=faceWidth+upX;
                //中间换行计算高度
                if (upX >= maxWidth)
                {
                    upY = upY + _size;
                    upX = 0;
                }
                //                NSLog(@"%@,%f,%f",str,upX,upY);
            }
        }
        
        
        if(n == NSNotFound){
            for (int j = 0; j < [str length]; j++) {
                NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                if([temp isEqualToString:@"\n"]){
                    upY = upY + _size;
                    upX = 0;
                }else{
                    CGSize size=[temp sizeWithFont:self.font constrainedToSize:CGSizeMake(_size, _size)];
                    [temp drawInRect:CGRectMake(upX, upY+_top, size.width, size.height) withFont:self.font];
                    //中间换行计算高度
                    upX=upX+size.width;
                    if (upX >= maxWidth)
                    {
                        upY = upY + size.height;
                        upX = 0;
                    }
                }
//                NSLog(@"%@,%f,%f",temp,upX,upY);
            }
        }
    }
    
}

-(void)getImageRange:(NSString*)message  array: (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str array:array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str array:array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

-(void) setText:(NSString *)text{
    NSString * txt = [text replace:@"#[write_face_" withString:@"[write_face_"];
    [super setText:txt];
    [data removeAllObjects];
    [self getImageRange:txt array:data];
    
}



-(NSString*)getText:(NSString*)message {
    
    for(int i=0;i<[faceArray count];i++)
    {
        NSString * face = [NSString stringWithFormat:@"%@",[faceArray objectAtIndex:i]];
        message = [message replace:face withString:[NSString stringWithFormat:@"#%@",[writefaceArray objectAtIndex:i]]];
    }
    return message;
}


-(NSString*)getFaceText:(NSString*)message {
    //NSString* str = [[NSString alloc] init];
    if(faceArray==nil){
        faceArray = [[NSArray alloc]initWithObjects:@"[微笑]",@"[大笑]",@"[调皮]",@"[害怕]",@"[得意]",@"[生气]",@"[撇嘴]",@"[冷汗]",@"[大哭]",@"[吓]",@"[鄙视]",@"[难过]",@"[赞]",@"[见钱眼开]",@"[疑问]",@"[抓狂]",@"[吐]",@"[想]",@"[委屈]",@"[色]",@"[发呆]",
                     @"[偷笑]",@"[尴尬]",@"[鼓掌]",@"[坏笑]",@"[眨眼]",@"[流汗]",@"[可怜]",@"[睡]",@"[惊恐]",@"[发怒]",
                     @"[惊讶]",@"[咒骂]",
                     @"[爱心]",@"[心碎]",@"[玫瑰]",@"[礼物]",@"[彩虹]",@"[月亮]",@"[太阳]",
                     @"[金钱]",@"[灯泡]",@"[咖啡]",@"[蛋糕]",@"[音符]",@"[爱你]",@"[胜利]",@"[强]",@"[差劲]",@"[OK]",nil];
        
        imageArray = [[NSMutableArray alloc] init];
        writefaceArray = [[NSMutableArray alloc] init];
        for (int i = 0;i<[faceArray count];i++){
            NSString* s = [NSString stringWithFormat:@"%@write_face_%d.png",[self imageFilePath],i+1];
            [imageArray addObject:s];
            
            NSString* s1 = [NSString stringWithFormat:@"[write_face_%d]",i+1];
            [writefaceArray addObject:s1];
        }
    }
    for(int i=0;i<[writefaceArray count];i++)
    {
        NSString * face = [NSString stringWithFormat:@"#%@",[writefaceArray objectAtIndex:i]];
        message = [message replace:face withString:[NSString stringWithFormat:@"%@",[faceArray objectAtIndex:i]]];
    }
    
    return message;
}
@end
