varying vec2 texcoord[9];

uniform sampler2DRect image;

vec4 temp, a, b;

#define s2(a, b)                temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)            s2(a, b); s2(a, c);
#define mx3(a, b, c)            s2(b, c); s2(a, c);

#define mnmx3(a, b, c)          mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)       s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)    s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges

void main()
{
//    vec4 v[6];
//    
//    vec2 textureCoordinate = texcoord3 + texcoord4;
//    
//    v[0] = texture2DRect(image, texcoord0);
//    v[1] = texture2DRect(image, texcoord7);
//    v[2] = texture2DRect(image, texcoord5);
//    v[3] = texture2DRect(image, texcoord2);
//    v[4] = texture2DRect(image, texcoord3);
//    v[5] = texture2DRect(image, texcoord4);
//    //     v[6] = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
//    //     v[7] = texture2D(inputImageTexture, topTextureCoordinate).rgb;
//    vec4 temp;
//    
//    mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
//    
//    v[5] = texture2DRect(image, texcoord1);
//    
//    mnmx5(v[1], v[2], v[3], v[4], v[5]);
//    
//    v[5] = texture2DRect(image, texcoord6);
//    
//    mnmx4(v[2], v[3], v[4], v[5]);
//    
//    v[5] = texture2DRect(image, textureCoordinate);
//    
//    
//    mnmx3(v[3], v[4], v[5]);
//    
//    gl_FragColor = vec4(v[4]);
    
    vec4 sampler[9];
    
    for (int i = 0; i < 9; i++)
    {
        sampler[i] = texture2DRect(image, texcoord[i]);
    }
    
    mnmx6(sampler[0], sampler[1], sampler[2], sampler[3], sampler[4], sampler[5]);
    mnmx5(sampler[1], sampler[2], sampler[3], sampler[4], sampler[6]);
    mnmx4(sampler[2], sampler[3], sampler[4], sampler[7]);
    mnmx3(sampler[3], sampler[4], sampler[8]);
    
    gl_FragColor = vec4( sampler[4] );

}