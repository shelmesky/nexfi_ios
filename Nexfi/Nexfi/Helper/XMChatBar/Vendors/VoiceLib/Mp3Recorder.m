//
//  Mp3Recorder.m
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "Mp3Recorder.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"

@interface Mp3Recorder()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *wavPath;
@property (nonatomic, strong) NSString *currentTimeStr;
@end

@implementation Mp3Recorder

#pragma mark - Init Methods

- (id)initWithDelegate:(id<Mp3RecorderDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)setRecorder
{
    _recorder = nil;
    NSError *recorderSetupError = nil;
    self.wavPath = [self wavpath];
    NSURL *url = [NSURL fileURLWithPath:self.wavPath];
    /* MP3
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
     */
    //wav －amr
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                            settings:recordSetting
                                               error:&recorderSetupError];
    if (recorderSetupError) {
        NSLog(@"%@",recorderSetupError);
    }
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
 
    [_recorder record];
}

- (void)setSesstion
{
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(_session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [_session setActive:YES error:nil];
}

- (void)startRecord
{
    [self setSesstion];
    [self setRecorder];
    [_recorder record];
}


- (void)stopRecord
{
    double cTime = _recorder.currentTime;
    [_recorder stop];
    
    if (cTime > 1) {
        [self audio_PCMtoMP3];
    }else {
        
        [_recorder deleteRecording];
        
        if ([_delegate respondsToSelector:@selector(failRecord)]) {
            [_delegate failRecord];
        }
    }
}

- (void)cancelRecord
{
    [_recorder stop];
    [_recorder deleteRecording];
}

- (void)deleteMp3Cache
{
    [self deleteFileWithPath:[self mp3Path]];
}

- (void)deleteWavCache
{
    [self deleteFileWithPath:self.wavPath];
}

- (void)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:path error:nil])
    {
        NSLog(@"删除以前的mp3文件");
    }
}

#pragma mark - Convert Utils
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = self.wavPath;

    
    int success = [VoiceConverter wavToAmr:cafFilePath amrSavePath:[self amrPath]];
    NSLog(@"success===%d",success);
    NSString *amrPath = [@"audio/amr" stringByAppendingPathComponent:[NSString stringWithFormat:@"rec_%@.amr",self.currentTimeStr]];
    if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithMP3FileName:)]) {
            [_delegate endConvertWithMP3FileName:amrPath];
    }
    //
    [self deleteWavCache];

    
    //MP3
    /*
     
     NSString *mp3FilePath = [[self mp3Path] stringByAppendingPathComponent:[self randomMP3FileName]];
     
     NSString *mp3PartFilePath = [@"com.XMFraker.XMNChat.audioCache" stringByAppendingPathComponent:[self randomMP3FileName]];
     
    NSLog(@"MP3转换开始");
    if (_delegate && [_delegate respondsToSelector:@selector(beginConvert)]) {
        [_delegate beginConvert];
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        mp3FilePath = nil;
    }
    @finally {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        NSLog(@"MP3转换结束");
        if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithMP3FileName:)]) {
            [_delegate endConvertWithMP3FileName:mp3PartFilePath];
        }
        [self deleteCafCache];
    }
     */
    
    
}

#pragma mark - Path Utils
- (NSString *)amrPath{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audio/amr"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *amrPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"rec_%@.amr",self.currentTimeStr]];
    return amrPath;
}
- (NSString *)wavpath
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audio/wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *wavpath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"rec_%@.wav",[dateFormater stringFromDate:now]]];
    self.currentTimeStr = [dateFormater stringFromDate:now];
    return wavpath;
    
}

- (NSString *)mp3Path {
    NSString *mp3Path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"com.XMFraker.XMNChat.audioCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return mp3Path;
}

- (NSString *)randomMP3FileName {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"record_%.0f.mp3",timeInterval];
    return fileName;
}

@end
