#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform mat4  u_hue;
uniform float u_Saturation;
uniform float u_bright;

void main()
{
    vec4 pixColor = texture2D(CC_Texture0, v_texCoord);
    ///临时结果
    vec4 outColor;
    if(pixColor.a > 0.1){
	    vec4 rgbColor = u_hue * pixColor;
	    float average = (rgbColor[0]+rgbColor[1]+rgbColor[2])*.33333; 
	    rgbColor[0] = (rgbColor[0] - average)*(u_Saturation + -1.0) + rgbColor[0];
	    rgbColor[1] = (rgbColor[1] - average)*(u_Saturation + -1.0) + rgbColor[1];
	    rgbColor[2] = (rgbColor[2] - average)*(u_Saturation + -1.0) + rgbColor[2];
	    rgbColor = ( rgbColor + u_bright*.00392 ) * u_bright + rgbColor;

	    outColor = vec4(rgbColor.r,rgbColor.g,rgbColor.b, pixColor.a) * v_fragmentColor;
	}
	else if(pixColor.a > 0.0){
	    outColor = pixColor;
	}else{
		discard;
	}
	
	gl_FragColor = outColor;
}

