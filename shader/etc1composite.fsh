#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 texColor1 = texture2D(CC_Texture0, v_texCoord);
	vec4 texColor2 = texture2D(CC_Texture0, vec2(v_texCoord.x,v_texCoord.y + 0.5));
 	gl_FragColor = v_fragmentColor*vec4(texColor1.xyz*texColor2.r, texColor2.r);
}