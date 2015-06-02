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

//#define	kQCPlugIn_Name				@"v002 Dilate"
//#define	kQCPlugIn_Description		@"Dilate Image - basic morphological set transformations"


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

//+ (NSDictionary*) attributes
//{
//    return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
//            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
//            kQCPlugIn_Category, @"categories", nil];
//}

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
        
        // Deduce the bit depth of the input image, so we can appropriately output a lossless image
        GLint result;
        glGetTexLevelParameteriv([image textureTarget], 0, GL_TEXTURE_INTERNAL_FORMAT, &result);
        BOOL useFloat = (result == GL_RGBA32F_ARB) ? YES : NO;

        // Render
        GLuint finalOutput = [self renderToFBO:cgl_ctx image:image amount:self.inputAmount useFloat:useFloat];
        
        [image unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
        [image unlockTextureRepresentation];
        
        id provider = nil;
        
        if(finalOutput != 0)
        {
            
#if __BIG_ENDIAN__
#define v002QCPluginPixelFormat QCPlugInPixelFormatARGB8
#else
#define v002QCPluginPixelFormat QCPlugInPixelFormatBGRA8
#endif
            NSString* format = (useFloat) ? QCPlugInPixelFormatRGBAf : v002QCPluginPixelFormat;
            
            // we have to use a 4 channel output format, I8 does not support alpha at fucking all, so if we want text with alpha, we need to use this and waste space. Ugh.
            provider = [context outputImageProviderFromTextureWithPixelFormat:format pixelsWide:[image imageBounds].size.width pixelsHigh:[image imageBounds].size.height name:finalOutput flipped:NO releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[image shouldColorMatch]];
            
            self.outputImage = provider;
        }
    }
    else
        self.outputImage = nil;
    
    return YES;
}

- (GLuint) renderToFBO:(CGLContextObj)context image:(id<QCPlugInInputImageSource>)image amount:(double)amount useFloat:(BOOL)useFloat
{
    GLsizei width = [image imageBounds].size.width;
    GLsizei height = [image imageBounds].size.height;
    
    CGLContextObj cgl_ctx = context;
    [pluginFBO pushAttributes:cgl_ctx];
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex);
    
    if(useFloat)
    {
        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, width, height, 0, GL_RGBA, GL_FLOAT, NULL);
        glClampColorARB(GL_CLAMP_FRAGMENT_COLOR_ARB, GL_FALSE);
    }
    else
    {
        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    }
    
    [pluginFBO pushFBO:cgl_ctx];
    [pluginFBO attachFBO:cgl_ctx withTexture:tex width:width height:height];
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
    glEnable([image textureTarget]);
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [image textureName]);
    glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // do not need blending if we use black border for alpha and replace env mode, saves a buffer wipe
    // we can do this since our image draws over the complete surface of the FBO, no pixel goes untouched.
    glDisable(GL_BLEND);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    
    // bind our shader program
    glUseProgramObjectARB([pluginShader programObject]);

    // setup our shaders!
    if(self.shaderUniformBlock)
    {
        self.shaderUniformBlock(cgl_ctx);
    }
    else
    {
        // some error or some shit
    }
    
      // move to VA for rendering
    GLfloat tex_coords[] =
    {
        1.0,1.0,
        0.0,1.0,
        0.0,0.0,
        1.0,0.0
    };
    
    GLfloat verts[] =
    {
        width,height,
        0.0,height,
        0.0,0.0,
        width,0.0
    };
    
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, verts );
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );	// TODO: GL_QUADS or GL_TRIANGLE_FAN?
    
    // disable shader program
    glUseProgramObjectARB(NULL);
    
    if(useFloat)
    {
        glClampColorARB(GL_CLAMP_FRAGMENT_COLOR_ARB, GL_TRUE);
    }
    
    [pluginFBO detachFBO:cgl_ctx];
    [pluginFBO popFBO:cgl_ctx];
    [pluginFBO popAttributes:cgl_ctx];
    return tex;
}
@end