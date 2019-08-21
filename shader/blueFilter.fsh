#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	//gray scale
	float gray = texColor.r * 0.2 + texColor.g * 0.6 + texColor.b * 0.2;
    texColor = vec4(gray, gray, gray, texColor.a);
	//sepia
    float r = texColor.r * 0.0;
    float g = texColor.g * 0.75; 
    float b = texColor.b * 1.0;
    gl_FragColor = v_fragmentColor * mix(texColor, vec4(r, g, b, texColor.a), 0.5);
}

