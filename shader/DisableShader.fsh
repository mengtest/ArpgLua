#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    vec4 normalColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    if(normalColor.a <= 0.0){
       discard;
    }
    ///
	float gray = dot(normalColor.rgb, vec3(0.7 * 0.5, 0.8 * 0.5, 0.3 * 0.5));
    gl_FragColor = vec4(gray, gray, gray, normalColor.a);
}
