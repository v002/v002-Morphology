//
//  v002MorphologyGenericImageProcessor.h
//  v002 Morphology
//
//  Created by vade on 6/1/15.
//
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002MorphologyGenericImageProcessor : v002MasterPluginInterface
{
    
}
@property (nonatomic, copy) void (^shaderUniformBlock)(CGLContextObj cgl_ctx);


@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) double inputAmount;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;


@end

@interface v002MorphologyGenericImageProcessor (Execution)
- (GLuint) renderToFBO:(CGLContextObj)context image:(id<QCPlugInInputImageSource>)image amount:(double)amount useFloat:(BOOL)useFloat;
@end

