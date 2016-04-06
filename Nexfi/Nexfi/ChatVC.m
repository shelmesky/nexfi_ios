//
//  ChatVC.m
//  Nexfy
//
//  Created by fyc on 16/4/1.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "ChatVC.h"
#import "YBKeyBoardInputBar.h"

#import "YBKeyboardInputBarButton.h"
#import "YBKeyboardEmojModel.h"

@interface ChatVC ()<UITextViewDelegate>

@property (strong, nonatomic) YBKeyBoardInputBar * keyboardInputBar;

@end

@implementation ChatVC
-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self.keyboardInputBar showKeyBoardInView:self.view inWindow:YES];

    [self.keyboardInputBar showKeyBoardInView:self.view inWindow:YES];
    

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMoreFunctionButton:) name:YBKeyboardDidClickFuctionButtonNotification object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
}
- (void)didClickMoreFunctionButton:(NSNotification *)notif{
    NSDictionary *userInfo = notif.userInfo;
    
    YBkeyboardMoreFunctionModel *functionModel = userInfo[@"FunctionModel"];
    
    NSLog(@"你点击了第%lu个名字叫作%@的按钮",(unsigned long)functionModel.index,functionModel.title);
}
//- (void)didClickEmoji: (NSNotification *)notif{
//    YBKeyboardEmojModel *emoji = notif.object;
//    NSLog(@"%@",emoji.chs);
//
//}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.keyboardInputBar.activating){
        [self.view endEditing:YES];
    }else{
        [self.keyboardInputBar showKeyBoardInView:self.view inWindow:YES];
    }
}
-(YBKeyBoardInputBar *)keyboardInputBar{
    if (_keyboardInputBar == nil){
//        _keyboardInputBar = [YBKeyBoardInputBar keyBoardInputBar];
        _keyboardInputBar = [[YBKeyBoardInputBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)];
        [self.view addSubview:_keyboardInputBar];
    }
    return _keyboardInputBar;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
