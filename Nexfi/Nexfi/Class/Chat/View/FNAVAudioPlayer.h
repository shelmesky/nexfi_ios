//
//  FNAVAudioPlayer.h
//  Nexfi
//
//  Created by fyc on 16/5/10.
//  Copyright © 2016年 FuYaChen. All rights reserved.
//
@protocol FNAVAudioPlayerDelegate <NSObject>

- (void)sendVoiceState:(FNVoiceMessageState)voiceMessageState;

@end
#import <Foundation/Foundation.h>

@interface FNAVAudioPlayer : NSObject

/**
 *  index -> 主要作用是提供记录,用来控制对应的tableViewCell的状态
 */
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) id<FNAVAudioPlayerDelegate>delegate;

+ (instancetype)sharePlayer;

- (void)playAudioWithvoiceData:(id )voiceData atIndex:(NSUInteger)index;//- (void)playAudioWithData:(NSData *)audioData;
- (void)stopAudioPlayer;

//播放后台语音
- (void)playBackgroudSound;
@end
