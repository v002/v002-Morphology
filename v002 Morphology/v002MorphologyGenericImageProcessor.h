//
//  v002MorphologyGenericImageProcessor.h
//  v002 Morphology
//
//  Created by vade on 6/1/15.
//
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

// Callback that setups our uniforms every rendering pass,
// ideally set in init by subclasses to associated input ports with uniforms
// and set images to assigned units, etc
// Warning - be careful of self retain cycles. Use weak / strong workaround

typedef void(^ShaderUniformBlock)(CGLContextObj cgl_ctx);

@interface v002MorphologyGenericImageProcessor : v002MasterPluginInterface
{
    ShaderUniformBlock shaderUniformBlock;
}
@property (nonatomic, copy) ShaderUniformBlock shaderUniformBlock;

@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) double inputAmount;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;


@end

@interface v002MorphologyGenericImageProcessor (Execution)
- (GLuint) renderToFBO:(CGLContextObj)context image:(id<QCPlugInInputImageSource>)image amount:(double)amount useFloat:(BOOL)useFloat;
@end

