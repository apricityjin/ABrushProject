//
//  GradientStyleViewController.m
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#import "GradientStyleViewController.h"
#import "ABrush.hpp"
using namespace ABrush;
#import "GSShaderTypes.h"
#import <MetalKit/MetalKit.h>

@interface GradientStyleViewController ()
<MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;

@property (nonatomic, assign) vector_float2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, strong) id<MTLBuffer> indices;
@property (nonatomic, strong) id<MTLBuffer> gradientData; // gradient vertex
@property (nonatomic, strong) id<MTLBuffer> colorsLut;
@property (nonatomic, assign) NSUInteger vertexCount;
@property (nonatomic, assign) NSUInteger vertexBufferLength;
@property (nonatomic, assign) NSUInteger indexCount;
@property (nonatomic, assign) NSUInteger indexBufferLength;
@property (nonatomic, assign) NSUInteger gradientDataBufferLength;
@property (nonatomic, assign) NSUInteger colorsLutBufferLength;

@end

@implementation GradientStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    [self.view insertSubview:self.mtkView atIndex:0];
    self.mtkView.delegate = self;
    self.viewportSize = (vector_float2){static_cast<float>(self.mtkView.drawableSize.width), static_cast<float>(self.mtkView.drawableSize.height)};
    [self customInit];
}

- (void)customInit
{
    [self setupPipeline];
    [self setup];
}

-(void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexGSShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentGSShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL];
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setup
{
    APoint p0 = {400.0,  800.0},
    p1 = {1179.0,  800.0},
    p2 = {800.0, 1600},
    p3 = {400.0, 1600.0},
    start = (p0 + p1 + p2 + p3) / 4,
    end = p0;
    
    Path path = Path();
    path
        .moveTo(p0).lineTo(p1).lineTo(p2).lineTo(p3).close();
    //        .moveTo(p0).curveTo(p1, p2, p3).close();
    
    RenderData data = RenderData();
    Flatten *flattens = path.flatten();
    FillTessellator tessellator = FillTessellator();
    tessellator.fill(flattens, data);
    
    std::vector<Color> colors = {
        {255, 0, 0, 255},
        {0, 255, 0, 255},
        {146, 0, 255, 255},
    };
    std::vector<float> locations = {
        0.0,
        0.5,
        1.0,
    };
    Gradient g = Gradient(colors, locations);
    Builder b = Builder();
//    b.buildGradient(data, g, start, end, GradientStyleRadial);
//    b.buildGradient(data, g, start, end, GradientStyleAngular);
    b.buildGradient(data, g, start, end, 200, GradientStyleRadial);
    
    _gradientDataBufferLength = sizeof(GradientData);
    _gradientData = [_mtkView.device newBufferWithBytes:data.gradientData
                                                length:_gradientDataBufferLength
                                               options:MTLResourceStorageModeShared];
    
    _colorsLutBufferLength = sizeof(uint32_t) * data.gradientData->colorSize;
    _colorsLut = [_mtkView.device newBufferWithBytes:data.colorsLut
                                              length:_colorsLutBufferLength
                                             options:MTLResourceStorageModeShared];
    
    //
    _vertexCount = data.vertices.size();
    _vertexBufferLength = _vertexCount * sizeof(GSVertex);
    _vertices = [_mtkView.device newBufferWithBytes:data.vertices.data()
                                             length:_vertexBufferLength
                                            options:MTLResourceStorageModeShared];
    
    _indexCount = data.indices.size();
    _indexBufferLength = _indexCount * sizeof(UInt16);
    _indices = [_mtkView.device newBufferWithBytes:data.indices.data()
                                            length:_indexBufferLength
                                           options:MTLResourceStorageModeShared];
    
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
                              atIndex:GSVertexInputIndexViewportSize];
        
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                               atIndex:GSVertexInputIndexVertices];
        
        [renderEncoder setFragmentBuffer:_gradientData
                                  offset:0
                                 atIndex:GSFragmentInputIndexGradientData];
        
        [renderEncoder setFragmentBuffer:_colorsLut
                                  offset:0
                                 atIndex:GSFragmentInputIndexColorsLut];
        
        [renderEncoder setFragmentBytes:&_viewportSize
                                 length:sizeof(_viewportSize)
                                atIndex:GSFragmentInputIndexViewportSize];
        
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
