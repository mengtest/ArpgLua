#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

//
uniform float u_Saturation;

void main()
{
    vec4 fragColor = texture2D(CC_Texture0, v_texCoord);
    if(fragColor.a <= 0.0){
	   discard;    
    }
    ///
    float average = (fragColor[0]+fragColor[1]+fragColor[2])*.33333; 
    fragColor[0] = (fragColor[0] - average)*(u_Saturation + -1.0) + fragColor[0];
    fragColor[1] = (fragColor[1] - average)*(u_Saturation + -1.0) + fragColor[1];
    fragColor[2] = (fragColor[2] - average)*(u_Saturation + -1.0) + fragColor[2];
    gl_FragColor = fragColor * v_fragmentColor;
}

