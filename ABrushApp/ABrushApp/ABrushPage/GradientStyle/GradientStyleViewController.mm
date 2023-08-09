//
//  GradientStyleViewController.m
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#import "GradientStyleViewController.h"
#import "ABrush.hpp"
using namespace ABrush;
#import "ShaderTypes.h"
#import <MetalKit/MetalKit.h>

@interface Model : NSObject
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, strong) id<MTLBuffer> indices;
@property (nonatomic, strong) id<MTLBuffer> fragmentData;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, assign) NSUInteger vertexCount;
@property (nonatomic, assign) NSUInteger vertexBufferLength;
@property (nonatomic, assign) NSUInteger indexCount;
@property (nonatomic, assign) NSUInteger indexBufferLength;
@end

@implementation Model

@end

@interface GradientStyleViewController ()
<MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;

@property (nonatomic, assign) vector_float2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, strong) id<MTLBuffer> indices;
@property (nonatomic, strong) id<MTLBuffer> fragmentData;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, assign) NSUInteger vertexCount;
@property (nonatomic, assign) NSUInteger vertexBufferLength;
@property (nonatomic, assign) NSUInteger indexCount;
@property (nonatomic, assign) NSUInteger indexBufferLength;
@property (nonatomic, strong) NSMutableArray<Model *> *modelMAry;

@end

@implementation GradientStyleViewController
{
    MetalRender * _render;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    
    _render = new MetalRender(self.mtkView.device);
    
    [self.view insertSubview:self.mtkView atIndex:0];
    self.mtkView.delegate = self;
//    self.viewportSize = (vector_float2){
//        static_cast<float>(self.mtkView.drawableSize.width),
//        static_cast<float>(self.mtkView.drawableSize.height)
//    };
//    [self setupPipeline];
//    self.modelMAry = [NSMutableArray array];
    [self setup];
}

-(void)setupPipeline
{
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].blendingEnabled = YES;
    pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL];
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setup
{
//    void *ver, *tex;
    Builder builder;
    
    APoint
    p0  = {    0,  800 }, p1 = {  393,  800 }, p2 = { 393, 1200 }, p3 = { 0, 1200 },
    p4  = { 1179,  800 }, p5 = { 1179, 1200 },
    p6  = {  100,  900 }, p7 = {  200,  900 }, p8 = { 150,  900 }, p9 = { 100, 920 },
    p10 = { 200, 1000 }, p11 = {  450, 1000 }, p12 = { 400, 1000}, p13 = { 200, 1020},
    p14 = { 450, 1100 }, p15 = { 700, 1100 }, p16 = { 700, 1120 }, p17 = { 450, 1120 },
    p18 = { 700, 900 }, p19 = { 1100, 900 }, p20 = { 1100, 920 }, p21 = { 700, 920 },
    
    p22 = {1100, 900}, p23 = {700, 900};
        
    Color color0 = Color(0, 255, 255, 0), color1 = Color(0, 255, 255, 51), color2 = Color(0, 255, 255, 255), color3 = Color(147, 148, 154), white = Color(255, 255, 255), r0 = Color(255, 33, 91), r1 = Color(255, 112, 75);
    Gradient g;
    g.addStop(0, color0).addStop(1, color1);
    g.setLinear(p0, p1);
    Path p = Path().moveTo(p0).lineTo(p1).lineTo(p2).lineTo(p3);
    builder.setPath(p);
    builder.setGradient(g);
    builder.fill();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    /*
    
    builder.strokeCap = ABrush::StrokeTessellator::LineCap::Butt;
    builder.strokeJoin = ABrush::StrokeTessellator::LineJoin::Miter;
    builder.lineWidth = 5;
    builder.setColor(color2);
    p.moveTo(p4).lineTo(p1).lineTo(p2).lineTo(p5);
    builder.setPath(p);
    builder.stroke();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    builder.strokeCap = ABrush::StrokeTessellator::LineCap::Round;
    builder.strokeJoin = ABrush::StrokeTessellator::LineJoin::Round;
    builder.lineWidth = 40;
    builder.setColor(color3);
    p = Path()
        .moveTo(p6).lineTo(p7)
        .moveTo(p10).lineTo(p11)
        .moveTo(p14).lineTo(p15)
        .moveTo(p18).lineTo(p19);
    builder.setPath(p);
    builder.stroke();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    
    p = Path()
        .moveTo(p6).lineTo(p8)
        .moveTo(p10).lineTo(p12);
    builder.setPath(p);
    builder.setColor(white);
    builder.stroke();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    
    builder.lineWidth = 30;
    g = Gradient().addStop(0, r0).addStop(1, r1);
    g.setLinear(p6, p8);
    builder.setGradient(g);
    p = Path().moveTo(p6).lineTo(p8);
    builder.setPath(p);
    builder.stroke();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    p = Path().moveTo(p10).lineTo(p12);
    g = Gradient().addStop(0, r0).addStop(1, r1);
    g.setLinear(p10, p12);
    builder.setGradient(g);
    builder.setPath(p);
    builder.stroke();
//    builder.build(&ver, &tex);
//    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    */
    _render->initData(builder.data);
}

//- (void)setupVer:(void *)ver Tex:(void *)tex Type:(ABrush::Paint::PaintType)type
//{
//    Model *m = [[Model alloc] init];
//    [self.modelMAry addObject:m];
//
//    int * ptr = static_cast<int *>(ver);
//    m.vertexCount = *ptr++;
//    m.indexCount = *ptr++;
//    m.vertexBufferLength = *ptr++;
//    m.indexBufferLength = *ptr++;
//    m.vertices =
//    [_mtkView.device newBufferWithBytes:ptr
//                                 length:m.vertexBufferLength
//                                options:MTLStorageModeShared];
//    ptr += m.vertexCount * 4;
//    m.indices =
//    [_mtkView.device newBufferWithBytes:ptr
//                                 length:m.indexBufferLength
//                                options:MTLStorageModeShared];
//    FragmentData fd;
//    int width, height, bytesPerRow;
//    GradientData * gptr;
//    TextureData * tptr;
//    void * address = nullptr;
//    switch ( type ) {
//        case ABrush::Paint::PaintType::Color: {
//            fd.type = PaintTypeColor;
//            fd.c = *static_cast<uint32_t *>(tex);
//            width = 0;
//            height = 0;
//            bytesPerRow = 0;
//        } break;
//        case ABrush::Paint::PaintType::Gradient: {
//            fd.type = PaintTypeGradient;
//            gptr = static_cast<GradientData *>(tex);
//            fd.g = *gptr;
//            width = 256;
//            height = 1;
//            bytesPerRow = width << 2;
//            address = gptr + 1;
//        } break;
//        case ABrush::Paint::PaintType::Texture: {
//            fd.type = PaintTypeTexture;
//            tptr = static_cast<TextureData *>(tex);
//            fd.t = *tptr;
//            width = fd.t.width;
//            height = fd.t.height;
//            bytesPerRow = width << 2;
//            address = tptr + 1;
//        } break;
//    }
//    m.fragmentData =
//    [_mtkView.device newBufferWithBytes:&fd
//                                 length:sizeof(fd)
//                                options:MTLStorageModeShared];
//    free(ver);
//    if (width == 0 && height == 0) {
//        free(tex);
//        return;
//    }
//    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
//    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
//    textureDescriptor.width = width;
//    textureDescriptor.height = height;
//    textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
//    m.texture =
//    [_mtkView.device newTextureWithDescriptor:textureDescriptor];
//    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
//    [m.texture replaceRegion:region
//                 mipmapLevel:0
//                   withBytes:address
//                 bytesPerRow:bytesPerRow];
//    free(tex);
//}

#pragma mark - mtk view delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    self.viewportSize = (vector_float2){static_cast<float>(size.width), static_cast<float>(size.height)};
}

- (void)drawInMTKView:(MTKView *)view {
    
    _render->draw(view.currentDrawable);
//    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
//    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
//    if(renderPassDescriptor != nil)
//    {
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0);
//        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
//        renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable.texture;
//        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
//        [renderEncoder setRenderPipelineState:self.pipelineState];
//
//        for (Model *model in self.modelMAry) {
//            [renderEncoder setVertexBytes:&_viewportSize
//                                   length:sizeof(_viewportSize)
//                                  atIndex:VertexInputIndexViewportSize];
//            [renderEncoder setVertexBuffer:model.vertices
//                                    offset:0
//                                   atIndex:VertexInputIndexVertices];
//            [renderEncoder setFragmentBuffer:model.fragmentData
//                                      offset:0
//                                     atIndex:FragmentInputIndexData];
//            [renderEncoder setFragmentTexture:model.texture
//                                      atIndex:0];
//            [renderEncoder setFragmentBytes:&_viewportSize
//                                     length:sizeof(_viewportSize)
//                                    atIndex:FragmentInputIndexViewportSize];
//            [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
//                                      indexCount:model.indexCount
//                                       indexType:MTLIndexTypeUInt16
//                                     indexBuffer:model.indices
//                               indexBufferOffset:0];
//        }
//        [renderEncoder endEncoding];
//        [commandBuffer presentDrawable:view.currentDrawable];
//    }
//
//    [commandBuffer commit];
}

@end
