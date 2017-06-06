//
//  AVCaptureSessionViewController.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/6/1.
//  Copyright © 2017年 yangze. All rights reserved.
//

#define MOVIEPATH @"video.mp4"

#import "AVCaptureSessionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import <CoreImage/CoreImage.h>

@interface AVCaptureSessionViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession                  *captureSession;

@property (nonatomic, strong) AVCaptureDeviceInput              *videoInputDevice;
@property (nonatomic, strong) AVCaptureDeviceInput              *audioInputDevice;

@property (nonatomic, strong) AVCaptureMovieFileOutput          *captureMovieFileOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer           *captureVideoPreviewLayer;
@property (weak, nonatomic)     IBOutlet                UIView *facusView;


@end

@implementation AVCaptureSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.facusView.layer.borderWidth = 1.f;
    self.facusView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.facusView.layer.masksToBounds = YES;
        
    // 创建会话对象
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        // 设置会话的 sessionPreset 属性, 这个属性影响视频的分辨率
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    // 视频输入设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 音频输入设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 初始化AVCaptureDeviceInput对象
    NSError *error;
    self.videoInputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];

    if (error) {
        NSLog(@"获取视频输入设备出错");
        return;
    }
    
    self.audioInputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    
    if (error) {
        NSLog(@"获取音频输入设备出错");
        return;
    }
    //    初始化输出数据管理对象，如果要拍照就初始化AVCaptureStillImageOutput对象；
    //   如果拍摄视频就初始化AVCaptureMovieFileOutput对象。
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    // 视频输入对象添加到会话中
    if([self.captureSession canAddInput:self.videoInputDevice]){
        [self.captureSession addInput:self.videoInputDevice];
    }
    
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
        AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        // 标识视频录入时稳定音频流的接受，我们这里设置为自动
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    if ([self.captureSession canAddOutput:self.captureMovieFileOutput]) {
        [self.captureSession addOutput:self.captureMovieFileOutput];
    }
    
    // 创建视频预览图层 AVCaptureVideoreviewLayer
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 100);
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.captureVideoPreviewLayer atIndex:0];
    
    UIView *view = [[UIView alloc] initWithFrame:self.captureVideoPreviewLayer.frame];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
}

- (void)click:(UIGestureRecognizer *)tap {
  
    CGPoint point = [tap locationInView:tap.view.superview];
    [self focusAtPoint:point];
}



- (IBAction)startRecordAction:(id)sender {
    
    [self.captureSession startRunning];
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    // 开启视频防抖模式
    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    if ([self.videoInputDevice.device.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
        [captureConnection setPreferredVideoStabilizationMode:stabilizationMode];
    }
    
    // 预览图层和视频方向保持一致,这个属性设置很重要，如果不设置，那么出来的视频图像可能是倒向左边的。
    captureConnection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
    
    // 设置视频输出的文件路径，这里设置为 temp 文件
    NSString *outputFielPath = [NSTemporaryDirectory() stringByAppendingString:MOVIEPATH];
    
    // 路径转换成 URL 要用这个方法，用 NSBundle 方法转换成 URL 的话可能会出现读取不到路径的错误
    NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
    
    // 往路径的 URL 开始写入录像 Buffer ,边录边写
    [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
}


#pragma mark ========== AVCaptureFileOutputRecordingDelegate ============
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"---- 开始录制 ----");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    NSLog(@"---- 录制结束 ----");
    // 设置视频输出的文件路径，这里设置为 temp 文件
    NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:MOVIEPATH];
    
    //1.加载storyboard,（注意：这里仅仅是加载名称为test的storyboard,并不会创建storyboard中的控制器和控件）
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.fileUrl = [NSURL fileURLWithPath:outputFielPath];
    [self.navigationController pushViewController:vc animated:YES];
    
    CGFloat size = [self getfileSize:outputFielPath];
    
    self.sizelabel.text = [NSString stringWithFormat:@"%f",size];
    
    NSLog(@"%f",size);
}

- (CGFloat)getfileSize:(NSString *)path {
    
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
    return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
}

- (IBAction)stopRecordAction:(id)sender {
    // 取消视频拍摄
    [self.captureMovieFileOutput stopRecording];
    [self.captureSession stopRunning];
}

//point为点击的位置
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.captureVideoPreviewLayer.frame.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.videoInputDevice.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.videoInputDevice.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.videoInputDevice.device setFocusPointOfInterest:focusPoint];
            [self.videoInputDevice.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.videoInputDevice.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.videoInputDevice.device setExposurePointOfInterest:focusPoint];
            [self.videoInputDevice.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.videoInputDevice.device unlockForConfiguration];
        //设置对焦动画
        _facusView.center = point;
        self.facusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.facusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.facusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.facusView.hidden = YES;
            }];
        }];
    }
    
}

- (void)detect {

    CIImage *personImage = [CIImage imageWithCGImage:[UIImage imageNamed:@""].CGImage];
    CIDetector *ctor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *arr = [ctor featuresInImage:personImage];
    
    CGSize ciimagesize = personImage.extent.size;
    CGAffineTransform reansform = CGAffineTransformMakeScale(1, -1);
    
    for (CIFaceFeature *face in arr) {
        
    }
    
//CIFilter
    
//    // 将 Core Image 坐标转换成 UIView 坐标
//    let ciImageSize = personciImage.extent.size
//    var transform = CGAffineTransform(scaleX: 1, y: -1)
//    transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
//    
//    for face in faces as! [CIFaceFeature] {
//        print("Found bounds are \(face.bounds)")
//        
//        // 实现坐标转换
//        var faceViewBounds = face.bounds.applying(transform)
//        
//        // 计算实际的位置和大小
//        let viewSize = personPic.bounds.size
//        let scale = min(viewSize.width / ciImageSize.width,
//                        viewSize.height / ciImageSize.height)
//        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
//        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
//        
//        faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
//        faceViewBounds.origin.x += offsetX
//        faceViewBounds.origin.y += offsetY
//        
//        let faceBox = UIView(frame: faceViewBounds)
//        
//        faceBox.layer.borderWidth = 3
//        faceBox.layer.borderColor = UIColor.red.cgColor
//        faceBox.backgroundColor = UIColor.clear
//        personPic.addSubview(faceBox)
//        
//        if face.hasLeftEyePosition {
//            print("Left eye bounds are \(face.leftEyePosition)")
//        }
//        
//        if face.hasRightEyePosition {
//            print("Right eye bounds are \(face.rightEyePosition)")
//        }
//    }
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
