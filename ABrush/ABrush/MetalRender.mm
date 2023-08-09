//
//  MetalRender.cpp
//  ABrush
//
//  Created by apricity on 2023/8/9.
//

#include "MetalRender.hh"
#include <simd/simd.h>

namespace ABrush
{

void MetalRender::draw(id<MTLTexture> texture)
{
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    MTLRenderPassDescriptor * renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    if (renderPassDescriptor) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].texture = texture;
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        {
            // 这里处理数据
        }
        [renderEncoder setRenderPipelineState:pipelineState];
    }
}

void MetalRender::draw(id<CAMetalDrawable> drawable)
{
    simd_float2 viewportSize = {static_cast<float>(drawable.texture.width), static_cast<float>(drawable.texture.height)};
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    MTLRenderPassDescriptor * renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    if (renderPassDescriptor) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setRenderPipelineState:pipelineState];
        {
            [renderEncoder setVertexBytes:&viewportSize
                                   length:sizeof(viewportSize)
                                  atIndex:VertexInputIndexViewportSize];
            [renderEncoder setFragmentBytes:&viewportSize
                                     length:sizeof(viewportSize)
                                    atIndex:FragmentInputIndexViewportSize];
            for (int i = 0; i < vtsOffsets.size(); ++i) {
                [renderEncoder setVertexBuffer:vertices
                                        offset:vtsOffsets[i]
                                       atIndex:VertexInputIndexVertices];
                [renderEncoder setFragmentTexture:colorLuTs
                                          atIndex:0];
                [renderEncoder setFragmentBuffer:fragmentBuffer
                                          offset:fgtOffsets[i]
                                         atIndex:FragmentInputIndexData];
                [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                          indexCount:idxCounts[i]
                                           indexType:MTLIndexTypeUInt16
                                         indexBuffer:indices
                                   indexBufferOffset:idsOffsets[i]];
            }
        }
        [renderEncoder setRenderPipelineState:pipelineState];
        [commandBuffer presentDrawable:drawable];
    }
    [commandBuffer commit];
}

void MetalRender::initData(RenderData &data)
{
    vertices = [device newBufferWithLength:data.verticesLength
                                   options:MTLResourceStorageModeShared];
    indices = [device newBufferWithLength:data.indicesLength
                                  options:MTLResourceStorageModeShared];
    fragmentBuffer = [device newBufferWithLength:data.fragmentLength
                                         options:MTLResourceStorageModeShared];
    Vertex *vtsPointer = static_cast<Vertex *>( vertices.contents );
    uint16_t *idsPointer = static_cast<UInt16 *>( indices.contents );
    FragmentData *fgtPointer = static_cast<FragmentData *>( fragmentBuffer.contents );
    int vtsOffset = 0, idsOffset = 0, fgtOffset = 0;
    for (int i = 0; i < data.items.size(); ++i) {
        vtsOffsets.push_back(vtsOffset); idsOffsets.push_back(idsOffset); fgtOffsets.push_back(fgtOffset);
        RenderDataItem &item = data.items[i];
        memcpy(vtsPointer, item.vertices.data(), item.vertices.size() << 4);
        vtsPointer += item.vertices.size();
        vtsOffset += item.vertices.size() << 4;
        memcpy(idsPointer, item.indices.data(), item.indices.size() << 1);
        idsPointer += item.indices.size();
        idsOffset += item.indices.size() << 1;
        idxCounts.push_back(item.indices.size());
        Paint &p = item.paint;
        if (p.type == Paint::PaintType::Color) {
            fgtPointer->type = 0;
            fgtPointer->c = p.color.rgba;
        }
        else if (p.type == Paint::PaintType::Gradient) {
            fgtPointer->type = 1;
            switch (p .gradient->gradientType ) {
                case Gradient::GradientType::Linear:
                    fgtPointer->g.type = 0;
                    break;
                case Gradient::GradientType::Radial:
                    fgtPointer->g.type = 1;
                    break;
                case Gradient::GradientType::Angular:
                    fgtPointer->g.type = 2;
                    break;
                case Gradient::GradientType::Diamond:
                    fgtPointer->g.type = 3;
                    break;
                default:
                    break;
            }
            fgtPointer->g.a = p.gradient->affine;
            fgtPointer->g.a.invert();
            fgtPointer->g.colorLuTIdx = i;
            void * colorLuT = p.gradient->buildColorLuT();
            MTLRegion region = MTLRegionMake2D(0, i, 256, 1);
            [colorLuTs replaceRegion:region
                         mipmapLevel:0
                           withBytes:colorLuT
                         bytesPerRow:256 << 2];
        }
        else if (p.type == Paint::PaintType::Texture) {
            fgtPointer->type = 2;
            fgtPointer->t.width = p.texture->width;
            fgtPointer->t.height = p.texture->height;
            fgtPointer->t.a = p.texture->affine;
            fgtPointer->t.a.invert();
        }
        else {}
        fgtPointer += 1;
    }
}

MetalRender::MetalRender(id<MTLDevice> device)
: device(device)
{
    id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
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
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                           error:NULL];
    commandQueue = [device newCommandQueue];
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = 256;
    textureDescriptor.height = 256;
    textureDescriptor.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
    colorLuTs = [device newTextureWithDescriptor:textureDescriptor];
    MTLTextureDescriptor *textureDescriptor1 = [[MTLTextureDescriptor alloc] init];
    textureDescriptor1.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor1.width = 512;
    textureDescriptor1.height = 512;
    textureDescriptor1.usage = MTLTextureUsageShaderRead; // 根据实际需要设置.
    texs = [device newTextureWithDescriptor:textureDescriptor1];
}

}
