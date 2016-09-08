uniform float amount;

varying vec2 texcoord[9];
//varying vec2 texcoord1;
//varying vec2 texcoord2;
//varying vec2 texcoord3;
//varying vec2 texcoord4;
//varying vec2 texcoord5;
//varying vec2 texcoord6;
//varying vec2 texcoord7;

void main()
{
    // perform standard transform on vertex
    gl_Position = ftransform();
    
    // transform texcoord
    texcoord[0] = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
    
    // get sample positions
    texcoord[1] = texcoord[0] + vec2(-amount, -amount);
    texcoord[2] = texcoord[0] + vec2( 0,      -amount);
    texcoord[3] = texcoord[0] + vec2( amount, -amount);
    texcoord[4] = texcoord[0] + vec2(-amount,  0);
    texcoord[5] = texcoord[0] + vec2( amount,  0);
    texcoord[6] = texcoord[0] + vec2(-amount,  amount);
    texcoord[7] = texcoord[0] + vec2( 0,       amount);
    texcoord[8] = texcoord[0] + vec2( amount,  amount);
}
