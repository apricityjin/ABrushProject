//
//  ABrushViewController.m
//  ABrushApp
//
//  Created by apricity on 2023/6/9.
//

#import "ABrushViewController.h"
#import <MetalKit/MetalKit.h>
#import "AShaderTypes.h"
#import "ABrush.hpp"
using namespace ABrush;

@interface ABrushViewController ()
<MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;

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

@implementation ABrushViewController


- (void)viewDidLoad
{
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
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexAShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentAShader"];
    
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
    APoint p0 = APoint(100.0, 50.0);
//    APoint p0 = APoint(0.0, 0.0);
    APoint p1 = APoint(60.0, 300.0);
    APoint p2 = APoint(200.0, 150.0);
    APoint p3 = APoint(300.0, 400.0);
    
    APoint p4 = APoint(0.0, 500.0);
    APoint p5 = APoint(-150.0, 300.0);
    APoint p6 = APoint(-150.0, -300.0);
    APoint p7 = APoint(0.0, -400.0);
    Path path = Path();
    path
        .moveTo(p0).lineTo(p1).lineTo(p2).lineTo(p3)
        .moveTo(p4).curveTo(p5, p6, p7).close();
    
    RenderData data = RenderData();
    Flatten *flattens = path.flatten();
    StrokeTessellator tessellator = StrokeTessellator();
    tessellator.line_join_style = StrokeTessellator::LineJoin::LineJoinRound;
    tessellator.line_width = 20.0;
    tessellator.line_cap_style = StrokeTessellator::LineCap::LineCapRound;
    tessellator.stroke(flattens, data);
    
    //
    _vertexCount = data.vertices.size();
    _vertexBufferLength = _vertexCount * sizeof(AVertex);
    _vertices = [_mtkView.device newBufferWithLength:_vertexBufferLength
                                                 options:MTLResourceStorageModeShared];
    void *pointer = [_vertices contents];
    memcpy(pointer, data.vertices.data(), _vertexBufferLength);
    
    _indexCount = data.indices.size();
    _indexBufferLength = _indexCount * sizeof(UInt16);
    _indices = [_mtkView.device newBufferWithLength:_indexBufferLength
                                            options:MTLResourceStorageModeShared];
    pointer = [_indices contents];
    memcpy(pointer, data.indices.data(), _indexBufferLength);
    
    return;
}

#pragma mark - delegate

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
                              atIndex:AVertexInputIndexViewportSize];
        
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                               atIndex:AVertexInputIndexVertices];
        
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
