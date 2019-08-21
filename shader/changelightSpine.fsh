#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

//-1  ~  +1
uniform float u_light;

void main()
{
    vec4 sample = texture2D(CC_Texture0, v_texCoord);
    if(sample.a >= 0.8){
	   sample = sample + u_light;
	   gl_FragColor = v_fragmentColor * sample;
	}else{
	   discard;
	}
}

