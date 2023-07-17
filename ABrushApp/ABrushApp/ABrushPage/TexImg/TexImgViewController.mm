//
//  TexImgViewController.m
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#import "TexImgViewController.h"
#import "ABrush.hpp"
#import <MetalKit/MetalKit.h>
#import "TIShaderTypes.h"

using namespace ABrush;

@interface TexImgViewController ()
<MTKViewDelegate>

@property (nonatomic, strong) MTKView * mtkView;
@property (nonatomic, assign) vector_float2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, strong) id<MTLBuffer> indices;

@property (nonatomic, assign) NSUInteger vertexCount;
@property (nonatomic, assign) NSUInteger vertexBufferLength;
@property (nonatomic, assign) NSUInteger indexCount;
@property (nonatomic, assign) NSUInteger indexBufferLength;

@end

@implementation TexImgViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    [self.view insertSubview:self.mtkView atIndex:0];
    self.mtkView.delegate = self;
    self.viewportSize = (vector_float2){static_cast<float>(self.mtkView.drawableSize.width), static_cast<float>(self.mtkView.drawableSize.height)};
    
    [self setupPipeline];
    [self setupVerticesAndIndices];
    
    std::string filePath = "/Users/ediothjin/Desktop/内存对齐问题-2.png";
    Image img = Image(filePath, 4);
    
    [self setupTexImg:img];
}

-(void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexTIShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentTIShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL];
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setupVerticesAndIndices
{
    
    TIVertex vertices[] = {
        { { 300.0,  800.0 }, { 0.0, 0.0 } },
        { { 800.0,  800.0 }, { 1.0, 0.0 } },
        { { 800.0, 1600.0 }, { 1.0, 1.0 } },
        { { 300.0, 1600.0 }, { 0.0, 1.0 } },
    };
    
    _vertexCount = 4;
    _vertexBufferLength = _vertexCount * sizeof(TIVertex);
    _vertices = [_mtkView.device newBufferWithBytes:vertices
                                             length:_vertexBufferLength
                                            options:MTLResourceStorageModeShared];
    
    UInt16 indices[] = {
        0, 1, 2,
        0, 2, 3,
    };
    
    _indexCount = 6;
    _indexBufferLength = _indexCount * sizeof(UInt16);
    _indices = [_mtkView.device newBufferWithBytes:indices
                                            length:_indexBufferLength
                                           options:MTLResourceStorageModeShared];
    
    return;
}

- (void)setupTexImg:(Image &)img
{
    
    size_t width = img.width,
    height = img.height,
    bytesPerRow = width * 4;
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    textureDescriptor.width = width;
    textureDescriptor.height = height;
    textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [self.texture replaceRegion:region
                    mipmapLevel:0
                      withBytes:img.data
                    bytesPerRow:bytesPerRow];
    return;
}

#pragma mark - mtk view delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewportSize = (vector_float2){static_cast<float>(size.width), static_cast<float>(size.height)};
}

- (void)drawInMTKView:(MTKView *)view {
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if(renderPassDescriptor != nil)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0 }];
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:TIVertexInputIndexViewportSize];
        
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                               atIndex:TIVertexInputIndexVertices];
        
        [renderEncoder setFragmentTexture:_texture
                                  atIndex:0];
        
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                  indexCount:_indexCount
                                   indexType:MTLIndexTypeUInt16
                                 indexBuffer:_indices
                           indexBufferOffset:0];
        
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

@end
