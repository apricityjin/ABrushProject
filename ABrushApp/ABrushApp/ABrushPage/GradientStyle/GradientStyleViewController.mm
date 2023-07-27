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
//@property (nonatomic, strong) NSMutableArray< id<MTLBuffer> > * verticesMAry;
//@property (nonatomic, strong) NSMutableArray< id<MTLBuffer> > * indicesMAry;
//@property (nonatomic, strong) NSMutableArray< id<MTLBuffer> > * fragmentDataMAry;
//@property (nonatomic, strong) NSMutableArray< id<MTLTexture> > * textureMAry;
//@property (nonatomic, strong) NSMutableArray< NSNumber* > * vertexCountMAry;
//@property (nonatomic, strong) NSMutableArray< NSNumber* > * vertexBufferLengthMAry;
//@property (nonatomic, strong) NSMutableArray< NSNumber* > * indexCountMAry;
//@property (nonatomic, strong) NSMutableArray< NSNumber* > * indexBufferLengthMAry;

@end

@implementation GradientStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    [self.view insertSubview:self.mtkView atIndex:0];
    self.mtkView.delegate = self;
    self.viewportSize = (vector_float2){
        static_cast<float>(self.mtkView.drawableSize.width),
        static_cast<float>(self.mtkView.drawableSize.height)
    };
    [self setupPipeline];
    self.modelMAry = [NSMutableArray array];
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
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL];
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setup
{
    void *ver, *tex;
    Builder builder;
    
    APoint p0 = {100, 400},
    p1 = {200, 400},
    p2 = {200, 600},
    p3 = {100, 600},
    
    p4 = {240, 400},
    p5 = {440, 400},
    p6 = {440, 600},
    p7 = {240, 600},

    p8 = {500, 400},
    p9 = {700, 400},
    p10 = {700, 600},
    p11 = {500, 600},
    
    p12 = {800, 400},
    p13 = {1100, 400},
    p14 = {1100, 600},
    p15 = {800, 600},
    
    p16 = {100, 700},
    p17 = {600, 700},
    p18 = {600, 900},
    p19 = {100, 900},
    
    p20 = {700, 700},
    p21 = {1100, 700},
    p22 = {1100, 900},
    p23 = {700, 900};
        
    Color red = Color(255, 0, 0),
    green = Color(0, 255, 0),
    blue = Color(0, 0, 255);
    
    Path p = Path().moveTo(p0).lineTo(p1).lineTo(p2).lineTo(p3).close();
    builder.setPath(p);
    builder.setColor(green);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];

    builder.setColor(red);
    builder.strokeCap = ABrush::StrokeTessellator::LineCap::Butt;
    builder.strokeJoin = ABrush::StrokeTessellator::LineJoin::Round;
    builder.lineWidth = 10;
    builder.stroke();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    p = Path().moveTo(p4).lineTo(p5).lineTo(p6).lineTo(p7).close();
    builder.setPath(p);
    Gradient g;
    g.addStop(0.2, red).addStop(0.5, green).addStop(1, blue);
    g.setLinear(p4, p6);
    builder.setGradient(g);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    p = Path().moveTo(p8).lineTo(p9).lineTo(p10).lineTo(p11).close();
    builder.setPath(p);
    Gradient g1;
    g1.addStop(0.2, red).addStop(0.5, green).addStop(1, blue);
    APoint ctp = (p8 + p10)/2;
    g1.setRadial(ctp, 150, 50, M_PI_4);
    builder.setGradient(g1);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];

    p = Path().moveTo(p12).lineTo(p13).lineTo(p14).lineTo(p15).close();
    builder.setPath(p);
    Gradient g2;
    g2.addStop(0.2, red).addStop(0.5, green).addStop(1, blue);
    ctp = (p12 + p14)/2;
    g2.setAngular(ctp, 150, 50, -M_PI_4);
    builder.setGradient(g2);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    p = Path().moveTo(p16).lineTo(p17).lineTo(p18).lineTo(p19).close();
    builder.setPath(p);
    Gradient g3;
    g3.addStop(0.2, red).addStop(0.5, green).addStop(1, blue);
    ctp = (p16 + p18)/2;
    g3.setDiamond(ctp, 300, 150, M_PI_4);
    builder.setGradient(g3);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
    
    Image img = Image("/Users/ediothjin/Desktop/内存对齐问题-2.png", 4);
    Texture t = Texture(img.width, img.height, img.data);
    t.affine.scale(0.3).translate(p20.x, p20.y);
    builder.setTexture(t);
    p = Path().moveTo(p20).lineTo(p21).lineTo(p22).lineTo(p23).close();
    builder.setPath(p);
    builder.setTexture(t);
    builder.fill();
    builder.build(&ver, &tex);
    [self setupVer:ver Tex:tex Type:builder.data.paint.type];
}

- (void)setupVer:(void *)ver Tex:(void *)tex Type:(ABrush::Paint::PaintType)type
{
    Model *m = [[Model alloc] init];
    [self.modelMAry addObject:m];
    
    int * ptr = static_cast<int *>(ver);
    m.vertexCount = *ptr++;
    m.indexCount = *ptr++;
    m.vertexBufferLength = *ptr++;
    m.indexBufferLength = *ptr++;
    m.vertices =
    [_mtkView.device newBufferWithBytes:ptr
                                 length:m.vertexBufferLength
                                options:MTLStorageModeShared];
    ptr += m.vertexCount * 2;
    m.indices =
    [_mtkView.device newBufferWithBytes:ptr
                                 length:m.indexBufferLength
                                options:MTLStorageModeShared];
    FragmentData fd;
    int width, height, bytesPerRow;
    GradientData * gptr;
    TextureData * tptr;
    void * address = nullptr;
    switch ( type ) {
        case ABrush::Paint::PaintType::Color: {
            fd.type = PaintTypeColor;
            fd.c = *static_cast<uint32_t *>(tex);
            width = 0;
            height = 0;
            bytesPerRow = 0;
        } break;
        case ABrush::Paint::PaintType::Gradient: {
            fd.type = PaintTypeGradient;
            gptr = static_cast<GradientData *>(tex);
            fd.g = *gptr;
            width = 256;
            height = 1;
            bytesPerRow = width << 2;
            address = gptr + 1;
        } break;
        case ABrush::Paint::PaintType::Texture: {
            fd.type = PaintTypeTexture;
            tptr = static_cast<TextureData *>(tex);
            fd.t = *tptr;
            width = fd.t.width;
            height = fd.t.height;
            bytesPerRow = width << 2;
            address = tptr + 1;
        } break;
    }
    m.fragmentData =
    [_mtkView.device newBufferWithBytes:&fd
                                 length:sizeof(fd)
                                options:MTLStorageModeShared];
    free(ver);
    if (width == 0 && height == 0) {
        free(tex);
        return;
    }
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = width;
    textureDescriptor.height = height;
    textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
    m.texture =
    [_mtkView.device newTextureWithDescriptor:textureDescriptor];
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [m.texture replaceRegion:region
                 mipmapLevel:0
                   withBytes:address
                 bytesPerRow:bytesPerRow];
    free(tex);
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
//        {
//            [renderEncoder setVertexBytes:&_viewportSize
//                                   length:sizeof(_viewportSize)
//                                  atIndex:VertexInputIndexViewportSize];
//
//            [renderEncoder setVertexBuffer:_vertices
//                                    offset:0
//                                   atIndex:VertexInputIndexVertices];
//
//            [renderEncoder setFragmentBuffer:_fragmentData
//                                      offset:0
//                                     atIndex:FragmentInputIndexData];
//
//            [renderEncoder setFragmentTexture:self.texture
//                                      atIndex:0];
//
//            [renderEncoder setFragmentBytes:&_viewportSize
//                                     length:sizeof(_viewportSize)
//                                    atIndex:FragmentInputIndexViewportSize];
//
//            [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
//                                      indexCount:_indexCount
//                                       indexType:MTLIndexTypeUInt16
//                                     indexBuffer:_indices
//                               indexBufferOffset:0];
//        }
        for (Model *model in self.modelMAry) {
            [renderEncoder setVertexBytes:&_viewportSize
                                   length:sizeof(_viewportSize)
                                  atIndex:VertexInputIndexViewportSize];
            [renderEncoder setVertexBuffer:model.vertices
                                    offset:0
                                   atIndex:VertexInputIndexVertices];
            [renderEncoder setFragmentBuffer:model.fragmentData
                                      offset:0
                                     atIndex:FragmentInputIndexData];
            [renderEncoder setFragmentTexture:model.texture
                                      atIndex:0];
            [renderEncoder setFragmentBytes:&_viewportSize
                                     length:sizeof(_viewportSize)
                                    atIndex:FragmentInputIndexViewportSize];
            [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                      indexCount:model.indexCount
                                       indexType:MTLIndexTypeUInt16
                                     indexBuffer:model.indices
                               indexBufferOffset:0];
        }
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

@end
