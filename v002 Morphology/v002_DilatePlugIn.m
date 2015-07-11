//
//  v002FBOGLSLTemplatePlugIn.m
//  v002FBOGLSLTemplate
//
//  Created by vade on 6/30/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002_DilatePlugIn.h"

#define	kQCPlugIn_Name				@"v002 Dilate"
#define	kQCPlugIn_Description		@"Dilate Image - basic morphological set transformations"

#pragma mark -
#pragma mark Static Functions

@implementation v002_DilatePlugIn

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
            kQCPlugIn_Category, @"categories", nil];
}

- (id) init
{
	if(self = [super init])
	{
		self.pluginShaderName = @"v002.dilate";
        
        self.shaderUniformBlock = ^void(CGLContextObj cgl_ctx, v002_DilatePlugIn* instance)
        {
            if(instance)
            {
                glUniform1iARB([instance->pluginShader getUniformLocation:"image"], 0);
                glUniform1fARB([instance->pluginShader getUniformLocation:"amount"], instance.inputAmount);
            }
        };
    }

	return self;
}

@end
