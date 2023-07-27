//
//  VlogPlayerViewController.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogDetailsViewController.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DMShaderTypes.h"

@interface VlogDetailsViewController ()
<MTKViewDelegate>

// view
@property (nonatomic, strong) MTKView *mtkView;

@property (assign, nonatomic) NSInteger currentVlogIndex;
@property (strong, nonatomic) NSMutableArray <VlogModel *> * dataMAry;
@property (assign, nonatomic) CGSize vlogSize;

@property (strong, nonatomic) AVPlayerItemVideoOutput * videoOutput;
@property (strong, nonatomic) AVPlayerItem * playerItem;
@property (strong, nonatomic) AVPlayer * player;

@property (strong, nonatomic) UIButton * nextButton;
@property (strong, nonatomic) UIButton * playButton;
@property (strong, nonatomic) UIButton * previousButton;
//@property (strong, nonatomic) UIButton * goforwardButton;
//@property (strong, nonatomic) UIButton * gobackwardButton;
@property (strong, nonatomic) UIButton * closeButton;
//@property (strong, nonatomic) UISlider * timelineSlider;

@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, assign) NSUInteger numIndexes;

@property (nonatomic, assign) size_t pixelBufferWidth;
@property (nonatomic, assign) size_t pixelBufferHeight;

@end

@implementation VlogDetailsViewController

- (instancetype)initWithVlogModels:(NSMutableArray *)dataMAry currentVlogIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _dataMAry = dataMAry;
        _currentVlogIndex = index;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.dataMAry[self.currentVlogIndex].title;
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice(); // 获取默认的device
    self.view = self.mtkView;
    self.mtkView.delegate = self;
    self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    [self setupViews];
    [self setupPipeline];
    [self setupVertex];
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
        (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
    }];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.dataMAry[self.currentVlogIndex].URL];
    [self.playerItem addOutput:self.videoOutput];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.player play];
    self.playButton.selected = YES;
}

- (void)setupViews {
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.nextButton];
//    [self.view addSubview:self.timelineSlider];
//    [self.view addSubview:self.gobackwardButton];
//    [self.view addSubview:self.goforwardButton];
    
    CGFloat padding = 20.;
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - padding * 2;
    CGFloat buttonWidth = (maxWidth - 2 * padding) / 3;
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];

//    [self.timelineSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.view).mas_offset(padding);
//        make.right.mas_equalTo(self.view).mas_offset(-padding);
//        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
//    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(padding);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
        make.width.height.mas_equalTo(buttonWidth);
    }];
//    [self.gobackwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.previousButton.mas_right).mas_offset(padding);
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
//        make.width.height.mas_equalTo(buttonWidth);
//    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.previousButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
        make.width.height.mas_equalTo(buttonWidth);
    }];
//    [self.goforwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(padding);
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
//        make.width.height.mas_equalTo(buttonWidth);
//    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(padding);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerDidFinishPlaying:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
//    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
}

#pragma mark - observer

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem * playerItem = notification.object;
    self.playButton.selected = NO;
    [playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"timeControlStatus"]) {
        AVPlayerTimeControlStatus status = self.player.timeControlStatus;
        self.playButton.selected = (status == AVPlayerTimeControlStatusPlaying);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - event action

- (void)nextButtonDidClicked:(UIButton *)button {
    self.currentVlogIndex += 1;
}

- (void)previousButtonDidClicked:(UIButton *)button {
    self.currentVlogIndex -= 1;
}

- (void)closeButtonDidClicked:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)goforwardButtonDidClicked:(UIButton *)button {
    CMTime currentTime = self.player.currentTime;
    CMTime forwardTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(5, 600));
    [self.player seekToTime:forwardTime];
}

- (void)gobackwardButtonDidClicked:(UIButton *)button {
    CMTime currentTime = self.player.currentTime;
    CMTime backwardTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(-5, 600));
    [self.player seekToTime:backwardTime];
}

- (void)playButtonDidClicked:(UIButton *)button {
    if (self.player.rate == 0) {
        [self.player play];
        button.selected = YES;
    } else {
        [self.player pause];
        button.selected = NO;
    }
}

- (void)timelineSliderValueChanged:(UISlider *)slider {
    CMTime duration = self.player.currentItem.duration;
    CGFloat durationInSeconds = CMTimeGetSeconds(duration);
    CGFloat newTimeInSeconds = durationInSeconds * slider.value;
    CMTime newTime = CMTimeMakeWithSeconds(newTimeInSeconds, 1);
    [self.player seekToTime:newTime];
}

- (void)timelineSliderTouchDown:(UISlider *)slider {
    [self.player pause];
}

- (void)timelineSliderTouchUpInside:(UISlider *)slider {
    [self.player play];
}

#pragma mark - setup mtk

- (CVPixelBufferRef)readBuffer {
    CMTime itemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([self.videoOutput hasNewPixelBufferForItemTime:itemTime])
    {
        return [self.videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:NULL];
    }
    return NULL;
}

- (void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary]; // .metal
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexDMShader"]; // 顶点shader，vertexShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentDMShader"]; // 片元shader，samplingShader是函数名
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState =
    [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                        error:NULL]; // 创建图形渲染管道，耗性能操作不宜频繁调用
    self.commandQueue = [self.mtkView.device newCommandQueue]; // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
}

- (void)setupVertex
{
    const static DMVertext vertices[] =
    {
        { { -1.0,  1.0, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  1.0, -1.0, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1.0, -1.0, 0.0, 1.0 },  { 0.f, 1.f } },
        { {  1.0,  1.0, 0.0, 1.0 },  { 1.f, 0.f } },
    
    };
    const static uint16_t indexes[] =
    {
        0, 1, 2,
        0, 3, 1,
    };
    self.vertexBuffer =
    [self.mtkView.device newBufferWithBytes:vertices
                                     length:sizeof(vertices)
                                    options:MTLResourceStorageModeShared];
    self.numVertices = sizeof(vertices) / sizeof(DMVertext);
    
    self.indexBuffer =
    [self.mtkView.device newBufferWithBytes:indexes
                                     length:sizeof(indexes)
                                    options:MTLResourceStorageModeShared];
    self.numIndexes = sizeof(indexes) / sizeof(uint16_t);
}

- (void)setupTextureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    if (self.pixelBufferWidth == 0 || self.pixelBufferHeight == 0)
    {
        self.pixelBufferWidth = width;
        self.pixelBufferHeight = height;
    }
    if (_texture == nil || self.pixelBufferWidth != width || self.pixelBufferHeight != height)
    {
        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        textureDescriptor.width = width;
        textureDescriptor.height = height;
        textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
        self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
        self.pixelBufferWidth = width;
        self.pixelBufferHeight = height;
    }
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [self.texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:baseAddress
                    bytesPerRow:bytesPerRow];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CFRelease(pixelBuffer);
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    self.viewportSize = (vector_uint2){size.width, size.height};
}

- (void)drawInMTKView:(MTKView *)view
{
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    CVPixelBufferRef sampleBuffer = [self readBuffer];
    if (renderPassDescriptor && sampleBuffer)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0f); // 设置默认颜色
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.pipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        [renderEncoder setVertexBuffer:self.vertexBuffer
                                offset:0
                               atIndex:0]; // 设置顶点缓存

        [self setupTextureWithPixelBuffer:sampleBuffer];
        [renderEncoder setFragmentTexture:self.texture
                                  atIndex:0]; // 设置纹理
        
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                  indexCount:self.numIndexes
                                   indexType:MTLIndexTypeUInt16
                                 indexBuffer:self.indexBuffer
                           indexBufferOffset:0];
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    [commandBuffer commit];
}

#pragma mark - setter

- (void)setCurrentVlogIndex:(NSInteger)currentVlogIndex {
    _currentVlogIndex = currentVlogIndex;
    NSUInteger count = self.dataMAry.count;
    if (_currentVlogIndex < 0) {
        _currentVlogIndex = count - 1;
    } else if (_currentVlogIndex >= count) {
        _currentVlogIndex = 0;
    }
    VlogModel * model = self.dataMAry[self.currentVlogIndex];
    self.playerItem = [AVPlayerItem playerItemWithURL:model.URL];
    [self.playerItem addOutput:self.videoOutput];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
    self.title = model.title;
}

#pragma mark - getter

- (UIButton *)nextButton {
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setImage:[UIImage systemImageNamed:@"forward.frame.fill"] forState:UIControlStateNormal];
    }
    return _nextButton;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIButton alloc] init];
        [_playButton addTarget:self action:@selector(playButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateSelected];
    }
    return _playButton;
}

- (UIButton *)previousButton {
    if (_previousButton == nil) {
        _previousButton = [[UIButton alloc] init];
        [_previousButton addTarget:self action:@selector(previousButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_previousButton setImage:[UIImage systemImageNamed:@"backward.frame.fill"] forState:UIControlStateNormal];
    }
    return _previousButton;
}

//- (UIButton *)goforwardButton {
//    if (_goforwardButton == nil) {
//        _goforwardButton = [[UIButton alloc] init];
//        [_goforwardButton addTarget:self
//                         action:@selector(goforwardButtonDidClicked:)
//               forControlEvents:(UIControlEventTouchUpInside)];
//        [_goforwardButton setImage:[UIImage systemImageNamed:@"goforward.5"]
//                      forState:(UIControlStateNormal)];
//    }
//    return _goforwardButton;
//}
//
//- (UIButton *)gobackwardButton {
//    if (_gobackwardButton == nil) {
//        _gobackwardButton = [[UIButton alloc] init];
//        [_gobackwardButton addTarget:self
//                              action:@selector(gobackwardButtonDidClicked:)
//               forControlEvents:(UIControlEventTouchUpInside)];
//        [_gobackwardButton setImage:[UIImage systemImageNamed:@"gobackward.5"]
//                      forState:(UIControlStateNormal)];
//    }
//    return _gobackwardButton;
//}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton addTarget:self
                         action:@selector(closeButtonDidClicked:)
               forControlEvents:(UIControlEventTouchUpInside)];
        [_closeButton setImage:[UIImage systemImageNamed:@"xmark"]
                      forState:(UIControlStateNormal)];
    }
    return _closeButton;
}

//- (UISlider *)timelineSlider {
//    if (_timelineSlider == nil) {
//        _timelineSlider = [[UISlider alloc] init];
//        [_timelineSlider addTarget:self action:@selector(timelineSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [_timelineSlider addTarget:self action:@selector(timelineSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
//        [_timelineSlider addTarget:self action:@selector(timelineSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _timelineSlider;
//}

@end
