//
//  FNAVAudioPlayer.m
//  Nexfi
//
//  Created by fyc on 16/5/10.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "FNAVAudioPlayer.h"

@interface FNAVAudioPlayer ()<AVAudioPlayerDelegate,AVAudioSessionDelegate>{
    AVAudioPlayer *_audioPlayer;
}
@property (nonatomic, copy, readonly) NSString *cachePath;

@end




@implementation FNAVAudioPlayer

+ (void)initialize {
    //配置播放器配置
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
    [AVAudioSession sharedInstance].delegate = self;
    
}

+ (instancetype)sharePlayer{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if ([super init]) {
        
        //添加应用进入后台通知
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
        //        [[NSNotificationCenter defaultCenter] addObserver: self
        //                                                 selector: @selector(handleInterruption:)
        //                                                     name:        AVAudioSessionInterruptionNotification
        //                                                   object:      [AVAudioSession sharedInstance]];
        
        //        _audioDataOperationQueue = [[NSOperationQueue alloc] init];
        //        _audioDataOperationQueue.name = @"com.XMFraker.XMNAVAudipPlayer.loadAudioDataQueue";
        //
        //        _index = NSUIntegerMax;
        
    }
    return self;
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    
}
//清除语音路径
- (void)cleanAudioCache {
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:self.cachePath];
    for (NSString *file in files) {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
}
//播放后台语音
- (void)playBackgroudSound{
    
    NSString *backgroudSoundPath = [[NSBundle mainBundle]pathForResource:@"backgroundSound" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:backgroudSoundPath];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    if (!_audioPlayer || error) {
        return;
    }
    
    _audioPlayer.volume = 1.0f;
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    //    [self setAudioPlayerState:XMNVoiceMessageStatePlaying];
    [_audioPlayer play];
    
    //设置锁屏仍能继续播放
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];//表示对于用户切换静音模式或者锁屏 都不理睬，继续播放音乐。并且不播放来自其他app的音乐，当然你可以设置
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
}
//播放语音
- (void)playAudioWithvoiceData:(id )voiceData atIndex:(NSUInteger)index{
    
    if (!voiceData) {
        return;
    }
    
    //如果来自同一个URLString并且index相同,则直接取消
    if (self.index == index || _audioPlayer.isPlaying) {
        [self stopAudioPlayer];
    }
    
    self.index = index;
    
    //TODO 从URL中读取音频data
    [self playAudioWithData:voiceData];
    
}
#pragma mark - NSNotificationCenter Methods
- (void)applicationWillResignActive:(UIApplication *)application {
    
    //    [self cancelOperation];
    [self stopAudioPlayer];
    //    [self setAudioPlayerState:XMNVoiceMessageStateCancel];
    
}
//播放语音
- (void)playAudioWithPath:(NSString *)audioPath{
    NSError *audioPlaerError;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:&audioPlaerError];
    if (!_audioPlayer || !audioPath) {
        return;
    }
    if (audioPlaerError) {
        
    }
    
    _audioPlayer.volume = 1.0f;
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    //    [self setAudioPlayerState:XMNVoiceMessageStatePlaying];
    [_audioPlayer play];
}
//播放语音
- (void)playAudioWithData:(NSData *)audioData {
    
    NSError *audioPlayerError;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&audioPlayerError];
    if (!_audioPlayer || !audioData) {
        return;
    }
    
    
    //开启红外感应 !!! 有bug 暂时弃用
    //    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    _audioPlayer.volume = 1.0f;
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    //    [self setAudioPlayerState:XMNVoiceMessageStatePlaying];
    [_audioPlayer play];
    
}
//停止播放
- (void)stopAudioPlayer {
    if (_audioPlayer) {
        _audioPlayer.playing ? [_audioPlayer stop] : nil;
        _audioPlayer.delegate = nil;
        _audioPlayer = nil;
    }
}
//#pragma mark - 播放器代理方法
//-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    NSLog(@"音乐播放完成...");
//    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"isPlayFinish"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
//    [[AVAudioSession sharedInstance]setActive:NO error:nil];
//}

@end
