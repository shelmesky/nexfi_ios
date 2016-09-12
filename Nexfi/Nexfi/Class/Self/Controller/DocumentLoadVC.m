//
//  DocumentLoadVC.m
//  Nexfi
//
//  Created by fyc on 16/8/24.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//

#import "DocumentLoadVC.h"
#import "SendFileVC.h"
#import <WebKit/WebKit.h>
@interface DocumentLoadVC ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,UIDocumentInteractionControllerDelegate>
@property (nonatomic, retain)UIWebView *webView;
@property (nonatomic, retain)WKWebView *wkWebView;
@property (nonatomic, retain)UIDocumentInteractionController *documentController;
@property (nonatomic, retain)UIButton *otherOpenButton;
@end

@implementation DocumentLoadVC
- (UIButton *)otherOpenButton{
    if (!_otherOpenButton) {
        _otherOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherOpenButton.frame = CGRectMake(0, SCREEN_SIZE.height - 64 - 45, SCREEN_SIZE.width, 45);
        _otherOpenButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [_otherOpenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_otherOpenButton setTitle:@"用其他应用打开" forState:UIControlStateNormal];
        _otherOpenButton.backgroundColor = [UIColor redColor];
        [_otherOpenButton addTarget:self action:@selector(ldOtherOpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherOpenButton;
}
- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64)];
        [_webView setScalesPageToFit:YES];
        _webView.delegate = self;
    
    }
    return _webView;
}
- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height - 64)];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.allowsBackForwardNavigationGestures = YES;
    }
    return _wkWebView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBaseVCAttributesWith:self.titleStr left:nil right:@"发送" WithInVC:self];
    
    [self judgeNetState];
}
- (void)judgeNetState{
    NSString *netState;
    if (netState || self.currentFileModel.fileAbsolutePath) {
        [self creatUI];
    }else{
        [HudTool showErrorHudWithText:@"网络暂不可用" inView:self.view];
    }
}
- (void)creatUI{
    if (IOS8) {
        NSURL *url = [NSURL fileURLWithPath:self.currentFileModel.fileAbsolutePath];
//        if (IOS9) {
//            [self.wkWebView loadFileURL:url allowingReadAccessToURL:url];
//        }else{
            NSURL *fileUrl = [self ldFileURLForBuggyWKWebView8:url];
            NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
            [self.wkWebView loadRequest:request];
//        }
        
        [self.view addSubview:self.wkWebView];
    }else{
        // 清除WebView的缓存
        NSURLCache *cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
        [cache setDiskCapacity:0];
        [cache setMemoryCapacity:0];
        
        NSURL *url = [NSURL fileURLWithPath:self.currentFileModel.fileAbsolutePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
        [self.view addSubview:self.webView];
    }
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.currentFileModel.fileAbsolutePath]];
    self.documentController.delegate = self;
//    [self.view addSubview:self.otherOpenButton];
    
}
- (void)ldOtherOpenBtnClick:(UIButton *)btn{
    [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}
#pragma -mark 发送
- (void)RightBarBtnClick:(id)sender{
    [LPActionSheet showActionSheetWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"发送给朋友",@"用其他应用打开"] handler:^(LPActionSheet *actionSheet, NSInteger index) {
        switch (index) {
            case 1://发送给朋友
            {
                SendFileVC *vc = [[SendFileVC alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2://用其他应用打开
            {
                [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
                break;
            }
            default:
                break;
        }
    }];
}
#pragma -mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return self.view.frame;
}
- (nullable UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return self.view;
}
#pragma UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self showLoadingView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingView];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopLoadingView];
}
#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self showLoadingView];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self stopLoadingView];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [self stopLoadingView];
}

/*
 // 接收到服务器跳转请求之后再执行
 - (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)  navigation {
 
 }
 
 // 在收到响应后，决定是否跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
 
 }
 
 // 在发送请求之前，决定是否跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
 
 }
 */
#pragma mark - WKUIDelegate
// 1.创建一个新的WebVeiw
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    return nil;
}

// 2.WebVeiw关闭（9.0中的新方法）
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
    
}

// 3.显示一个JS的Alert（与JS交互）
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
}

// 4.弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
}

// 5.显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
}

#pragma mark 《正在加载》的View
/** 打开 《正在加载》的View */
- (void)showLoadingView {
    [HudTool showLoadingHudInView:self.view];
    
    // 启动系统状态栏加载动画
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
/** 关闭 《正在加载》的View */
- (void)stopLoadingView {
    [HudTool showLoadingHudInView:self.view];
    
    // 关闭系统状态栏加载动画
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
#pragma mark 将文件copy到tmp目录 ~~~ WKWebView
/** 将文件copy到tmp目录 ~~~ WKWebView */
- (NSURL *)ldFileURLForBuggyWKWebView8:(NSURL *)fileURL {
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" ld flawlesly :)
    return dstURL;
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
