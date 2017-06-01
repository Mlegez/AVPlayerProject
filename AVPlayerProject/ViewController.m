//
//  ViewController.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/25.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import "ViewController.h"
#import "AVPlayerView.h"

@interface ViewController ()<AVPlayerViewDelegate,AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) AVPlayerView           *playerView;

@property (nonatomic, assign) BOOL                      isFill;

@property (weak, nonatomic) IBOutlet UISlider           *slider;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.playerView = [[AVPlayerView alloc] initWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"] frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9/16) isCancache:YES];
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    [self.playerView addGestureRecognizer:tapGesture];
}

- (void)clickAction:(UITapGestureRecognizer *)tap {
    self.isFill = !self.isFill;
    
    if (self.isFill){
        [self.playerView fullScreen];
    }
    else{
        //旋转屏幕
        [self.playerView cancelFullScreenWithSuperView:self.view];
    }
}

#pragma mark ============ AVPlayerViewDelegate ========
//基本信息加载完毕
- (void)avPlayerView:(AVPlayerView *)playerView didFinishLoadingBaseInfo:(CGFloat)totalTime{
    
}

//加载失败
- (void)avPlayerViewLoadFailed:(AVPlayerView *)playerView{
    
}

//当前播放的时间
- (void)avPlayerView:(AVPlayerView *)playerView currentTime:(CGFloat)currentTime{
    
    
    self.slider.value = currentTime/playerView.totalDuration;
}

//播放结束
- (void)avPlayerViewDidPlayEnd:(AVPlayerView *)playerView{
    
}


- (IBAction)playAction:(id)sender {
    
    [self.playerView play];
}

- (IBAction)pauseAction:(id)sender {
    
    [self.playerView pause];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}


- (IBAction)sliderAction:(UISlider *)sender {
    
    NSLog(@"%f",sender.value);
    
    [self.playerView setPlayerProgress:sender.value * self.playerView.totalDuration];
    
}

- (IBAction)beginTouch:(UISlider *)sender {
    [self.playerView pause];
}

- (IBAction)endTouch:(UISlider *)sender {
    [self.playerView play];
}





@end
