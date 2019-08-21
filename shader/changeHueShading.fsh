#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec4  u_Color;
uniform float u_light;
uniform float u_bright;

void main()
{
    vec4 pixColor = texture2D(CC_Texture0, v_texCoord);
    ///临时结果
    vec4 outColor;
    if(pixColor.a > 0.1){
        //grey and light
        float average = (pixColor[0]+pixColor[1]+pixColor[2])*.33333;
        if(u_light > 0.0){
           average = (1.0 - average) * u_light + average;
        }else{
           average = average * u_light + average;
        }
        vec4 rgbColor = vec4(average);
        

        //change color
        if(rgbColor.r < 0.5){
           rgbColor = rgbColor * u_Color *2.0;
        }else{
           vec4 full = vec4(1.0);
           rgbColor = full - (full- rgbColor)*(full - u_Color)*2.0;
        }

        //bright
        rgbColor = ( rgbColor + u_bright*.00392 ) * u_bright + rgbColor;


        //out
        rgbColor.a = pixColor.a;
        outColor = rgbColor * v_fragmentColor;
    }else if(pixColor.a > 0.0){
        outColor = pixColor;
    }else{
        discard;
    }
    
    gl_FragColor = outColor;
}

