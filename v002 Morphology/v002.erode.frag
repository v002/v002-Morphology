uniform sampler2DRect image;


varying vec2 texcoord0;
varying vec2 texcoord1;
varying vec2 texcoord2;
varying vec2 texcoord3;
varying vec2 texcoord4;
varying vec2 texcoord5;
varying vec2 texcoord6;
varying vec2 texcoord7;

void main()
{
	vec4 dilate = texture2DRect(image, 0.5 * (texcoord3 + texcoord4));
	
	dilate = min(dilate, texture2DRect(image, texcoord0));
	dilate = min(dilate, texture2DRect(image, texcoord1));
	dilate = min(dilate, texture2DRect(image, texcoord2));
	dilate = min(dilate, texture2DRect(image, texcoord3));
	dilate = min(dilate, texture2DRect(image, texcoord4));
	dilate = min(dilate, texture2DRect(image, texcoord5));
	dilate = min(dilate, texture2DRect(image, texcoord6));
	dilate = min(dilate, texture2DRect(image, texcoord7));

	gl_FragColor = dilate;
}