#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    vec4 fragColor = texture2D(CC_Texture0, v_texCoord);
    if(fragColor.a > 0.2){
		float posY = v_texCoord.y;
		if(posY <= 0.4){
           fragColor.a = 1.0 - (0.4 - posY) / 0.4;
		}
		else if(posY >= 0.6){
           fragColor.a = 1.0 - (posY - 0.6) / 0.4;
		}
        fragColor.rgb *= fragColor.a;
		gl_FragColor = v_fragmentColor * fragColor;
    }else{
        discard;
    }  
}

