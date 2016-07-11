//
//  BaseVC.m
//  Nexfi
//
//  Created by fyc on 16/4/6.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "BaseVC.h"
#import "IQKeyboardManager.h"
#import "NFAllUserChatInfoVC.h"
#import "NFSingleChatInfoVC.h"
#import "UserInfoVC.h"

#define NAVIGATION_BAR_HEIGHT self.navigationController.navigationBar.frame.size.height
#define BUTTONMarginX    10
#define BUTTONMarginUP   0
#define NAVBUTTON_WIDTH  44
#define NAVBUTTON_HEIGHT 44


@interface BaseVC ()
{
    BOOL _wasKeyboardManagerEnabled;
}
@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UILabel *tipLabel;


@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
    self.tipLabel = [[UILabel alloc]init];
    self.tipLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.65];
    self.tipLabel.font = [UIFont systemFontOfSize:16.0];
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.layer.cornerRadius = 3.f;
    [self.view addSubview:self.tipLabel];
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
//                                                         forBarMetrics:UIBarMetricsDefault];
}


- (CGFloat)contentOriginY
{
    return 64.f;
}
//IQKeyboardManager 禁用
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isKindOfClass:[NFAllUserChatInfoVC class]] || [self isKindOfClass:[NFSingleChatInfoVC class]]) {
        _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
        [[IQKeyboardManager sharedManager] setEnable:NO];
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self isKindOfClass:[NFAllUserChatInfoVC class]] || [self isKindOfClass:[NFSingleChatInfoVC class]]) {
        [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];

    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //非根视图默认添加返回按钮
    if ([self.navigationController.viewControllers count] > 0
        && self != [self.navigationController.viewControllers objectAtIndex:0])
    {
        [self setLeftButtonWithImageName:@"title-icon-向左返回" bgImageName:nil];
    }
    

    [super viewWillAppear:animated];
}

#pragma mark - 扩展
-(void)setBaseVCAttributesWith:(NSString *)titleName left:(NSString*)nameLeft right:(NSString *)nameRight WithInVC:(UIViewController*)vc
{
    
    if (titleName)
    {
        BOOL isPng = [titleName hasSuffix:@"png"];
        
        if (isPng)
        {
            
            
        }
        
        else
        {
            self.navigationItem.title = titleName;
            //            vc.navigationItem.title = titleName;
        }
    }
    
    
    if (nameLeft)
    {
        BOOL isPng =[nameLeft hasSuffix:@"png"];
        
        if (isPng)
        {
            
            
            UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:nameLeft] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClick:)];
            vc.navigationItem.leftBarButtonItem = leftBarBtn;
        }
        else
        {
            UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithTitle:nameLeft style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClick:)];
            vc.navigationItem.leftBarButtonItem = leftBarBtn;
            
            
            
        }
        
    }
    
    
    if (nameRight)
    {
        BOOL isPng =[nameRight hasSuffix:@"png"];
        
        if (isPng)
        {
            
            UIBarButtonItem *RightBarBtn = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:nameRight] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:vc action:@selector(RightBarBtnClick:)];
            //            vc.navigationController.navigationItem.rightBarButtonItem =RightBarBtn;
            vc.navigationItem.rightBarButtonItem = RightBarBtn;
        }
        else
        {
            UIBarButtonItem *RightBarBtn = [[UIBarButtonItem alloc]initWithTitle:nameRight style:UIBarButtonItemStylePlain target:vc action:@selector(RightBarBtnClick:)];
            vc.navigationItem.rightBarButtonItem = RightBarBtn;
            [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        }
        
    }
    
}

- (void)RightBarBtnClick:(id)sender{
}

- (void)leftBarBtnClick:(id)sender{
    
}


- (void)leftButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPressed:(UIButton *)sender
{
    
}

- (void)setStrNavTitle:(NSString *)title
{
    UIView* navTitleView = (self.navigationItem.titleView);
    
    if([navTitleView isKindOfClass:[UILabel class]])//先要判断是否为label
    {
        self.titleLabel = (UILabel*)navTitleView;
        self.titleLabel.text = title;
    }
    else
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text= title;
        self.navigationItem.titleView = _titleLabel;
    }
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel sizeToFit];
}

- (void)setRightButtonWithTitle:(NSString*)title WithTitleName:(NSString *)titleName
{
    self.navigationItem.title = titleName;

    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin|
     NSStringDrawingUsesDeviceMetrics|
     NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:20.0],NSFontAttributeName, nil] context:0];

    if (rect.size.width<60) {
        rect.size.width = 60;
    }
    else
    {
        rect.size.width+=6;
    }
    UIButton *tmpRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpRightButton.frame = CGRectMake(self.view.frame.size.width-NAVBUTTON_WIDTH-BUTTONMarginX, BUTTONMarginUP, rect.size.width, 30);
    
    tmpRightButton.showsTouchWhenHighlighted = NO;
    tmpRightButton.exclusiveTouch = YES;//add by ljj 修改push界面问题
    
    [tmpRightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [tmpRightButton setTitleColor:RGBACOLOR(255.0, 255.0, 255.0, 1) forState:UIControlStateNormal];
    [tmpRightButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [tmpRightButton setTitle:title forState:UIControlStateNormal];
    
    [tmpRightButton setTitleColor:RGBACOLOR(200, 200, 200,1) forState:UIControlStateDisabled];
    
    [tmpRightButton setTitleColor:RGBACOLOR(200, 200, 200,1) forState:UIControlStateHighlighted];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpRightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    if (IOS7)//左边button的偏移量，从左移动13个像素
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;
        [self.navigationItem setRightBarButtonItems:@[negativeSeperator, rightButtonItem]];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
}
//[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
//forBarMetrics:UIBarMetricsDefault];
//设置导航左边的button的图片名和背景图片名
- (void)setLeftButtonWithImageName:(NSString*)imageName bgImageName:(NSString*)bgImageName
{
    UIButton *tmpLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    tmpLeftButton.frame = CGRectMake(-5, 0, 30, 32);//CGRectMake(0, BUTTONMarginUP, NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT);
    tmpLeftButton.showsTouchWhenHighlighted = NO;
    tmpLeftButton.exclusiveTouch = YES; //add by ljj 修改push界面问题
    
    if (bgImageName)//设置button的背景
    {
        [tmpLeftButton setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    }
    
    [tmpLeftButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [tmpLeftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpLeftButton];
    
    if (IOS7)//左边button的偏移量，从左移动13个像素
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;
        [self.navigationItem setLeftBarButtonItems:@[negativeSeperator, leftButtonItem]];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    }
}


- (void)setRightButtonWithStateImage:(NSString *)iconName stateHighlightedImage:(NSString *)highlightIconName stateDisabledImage:(NSString *)disableIconName titleName:(NSString *)title
{
    UIButton *tmpRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpRightButton.exclusiveTouch = YES;//add by ljj 修改push界面问题
    
    tmpRightButton.frame = CGRectMake(self.view.frame.size.width-NAVBUTTON_WIDTH-BUTTONMarginX, BUTTONMarginUP, NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT);
    if (title) {
        [tmpRightButton setTitle:title forState:UIControlStateNormal];
        [tmpRightButton setTitle:title forState:UIControlStateDisabled];
    }
    tmpRightButton.showsTouchWhenHighlighted = NO;
    [tmpRightButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [tmpRightButton setImage:[UIImage imageNamed:highlightIconName] forState:UIControlStateHighlighted];
    [tmpRightButton setImage:[UIImage imageNamed:disableIconName] forState:UIControlStateDisabled];
    
    [tmpRightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpRightButton];
    
    if (IOS7)//左边button的偏移量，从左移动13个像素
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;
        [self.navigationItem setRightBarButtonItems:@[negativeSeperator, rightButtonItem]];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:rightButtonItem];
    }
}

/**
 *  在右边的项目中添加新的icon
 *
 *  @param button
 *  @param state
 */
- (void)appendRightBarItemWithCustomButton:(UIButton *)button toOldLeft:(BOOL)state
{
    NSMutableArray *oldRightBarItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    
    UIBarButtonItem *rightNewItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    if (state) {
        
        [oldRightBarItems addObject:rightNewItem];
        
        self.navigationItem.rightBarButtonItems = oldRightBarItems;
        
        return;
    }
    
    [oldRightBarItems insertObject:rightNewItem atIndex:0];
    
    self.navigationItem.rightBarButtonItems = oldRightBarItems;
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
