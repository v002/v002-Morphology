//
//  v002MorphologyGenericImageProcessor.m
//  v002 Morphology
//
//  Created by vade on 6/1/15.
//
//

#import "v002MorphologyGenericImageProcessor.h"

//
//  v002FBOGLSLTemplatePlugIn.m
//  v002FBOGLSLTemplate
//
//  Created by vade on 6/30/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#pragma mark -
#pragma mark Static Functions

static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
    glDeleteTextures(1, &name);
}

@implementation v002MorphologyGenericImageProcessor

@dynamic inputImage;
@dynamic inputAmount;
@dynamic outputImage;


+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
    if([key isEqualToString:@"inputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }
    
    if([key isEqualToString:@"inputAmount"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Amount", QCPortAttributeNameKey,
                [NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
                [NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
                nil];
    }
    
    if([key isEqualToString:@"outputImage"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    }
    return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputImage", @"inputAmount", nil];
}

+ (QCPlugInExecutionMode) executionMode
{
    return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
    return kQCPlugInTimeModeNone;
}


@end

@implementation v002MorphologyGenericImageProcessor (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
    CGLContextObj cgl_ctx = [context CGLContextObj];
    
    id<QCPlugInInputImageSource>   image = self.inputImage;
    
    CGColorSpaceRef cspace = ([image shouldColorMatch]) ? [context colorSpace] : [image imageColorSpace];
    
    if(image && [image lockTextureRepresentationWithColorSpace:cspace forBounds:[image imageBounds]])
    {
        [image bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
        
        BOOL useFloat = [self boundImageIsFloatingPoint:image inContext:cgl_ctx];
        
        // Render
        GLuint finalOutput = [self singleImageRenderWithContext:cgl_ctx image:image useFloat:useFloat];
        
        [image unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
        [image unlockTextureRepresentation];
        
        id provider = nil;
        
        if(finalOutput != 0)
        {
            // we have to use a 4 channel output format, I8 does not support alpha at fucking all, so if we want text with alpha, we need to use this and waste space. Ugh.
            provider = [context outputImageProviderFromTextureWithPixelFormat:[self pixelFormatIfUsingFloat:useFloat]
                                                                   pixelsWide:[image imageBounds].size.width
                                                                   pixelsHigh:[image imageBounds].size.height
                                                                         name:finalOutput
                                                                      flipped:NO
                                                              releaseCallback:_TextureReleaseCallback
                                                               releaseContext:NULL
                                                                   colorSpace:[context colorSpace]
                                                             shouldColorMatch:[image shouldColorMatch]];
            
            self.outputImage = provider;
        }
    }
    else
        self.outputImage = nil;
    
    return YES;
}

@end