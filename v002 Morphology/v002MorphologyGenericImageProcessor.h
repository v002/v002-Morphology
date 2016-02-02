//
//  v002MorphologyGenericImageProcessor.h
//  v002 Morphology
//
//  Created by vade on 6/1/15.
//
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002MorphologyGenericImageProcessor : v002_PLUGIN_CLASS_NAME_REPLACE_ME
{
}
@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) double inputAmount;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;


@end

