//
//  v002_MedianPlugIn.m
//  v002 Morphology
//
//  Created by vade on 6/1/15.
//
//

#import <OpenGL/CGLMacro.h>
#import "v002_MedianPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Median"
#define	kQCPlugIn_Description		@"Median Image - basic morphological set transformations"

#pragma mark -
#pragma mark Static Functions

@implementation v002_MedianPlugIn

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
        self.pluginShaderName = @"v002.median";
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        self.shaderUniformBlock = ^void(CGLContextObj cgl_ctx)
        {
            if(weakSelf)
            {
                __strong typeof(self) strongSelf = weakSelf;
                
                glUniform1iARB([strongSelf->pluginShader getUniformLocation:"image"], 0);
                glUniform1fARB([strongSelf->pluginShader getUniformLocation:"amount"], strongSelf.inputAmount);
            }
        };
    }
    
    return self;
}

@end
