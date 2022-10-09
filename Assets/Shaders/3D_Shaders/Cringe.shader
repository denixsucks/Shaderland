Shader "Custom/GradientAndDirColor" {
  Properties{
    _MainTex("MainTexture",2D) = "white"{}
    [Toggle(USE_TEXTURE)] _UseTexture("Use Texture", Float) = 0
    _ColorLow("Color Low", COLOR) = (1,1,1,1)
    _ColorHigh("Color High", COLOR) = (1,1,1,1)
    _yPosLow("Y Pos Low", Float) = 0
    _yPosHigh("Y Pos High", Float) = 10
    _GradientStrength("Graident Strength", Float) = 1
    _EmissiveStrengh("Emissive Strengh ", Float) = 1
    _ColorX("Color X", COLOR) = (1,1,1,1)
    _ColorY("Color Y", COLOR) = (1,1,1,1)
  }
  SubShader{
    Tags {
      "Queue" = "Geometry"
      "RenderType" = "Opaque"
    }

    CGPROGRAM
    #pragma shader_feature USE_TEXTURE
    #pragma surface surf Lambert
    #define WHITE3 fixed3(1,1,1)
    #define UP float3(0,1,0)
    #define RIGHT float3(1,0,0)
    sampler2D _MainTex;
    fixed4 _ColorLow;
    fixed4 _ColorHigh;
    fixed4 _ColorX;
    fixed4 _ColorY;
    half _yPosLow;
    half _yPosHigh;
    half _GradientStrength;
    half _EmissiveStrengh;
    struct Input {
      float2 uv_MainTex;
      float3 worldPos;
      float3 normal;
    };

    void surf(Input IN, inout SurfaceOutput o) {

      float4 col = tex2D(_MainTex, IN.uv_MainTex);
      half3 gradient = lerp(_ColorLow, _ColorHigh,  smoothstep(_yPosLow, _yPosHigh, IN.worldPos.y)).rgb;
      gradient = lerp(WHITE3, gradient, _GradientStrength);
      half3 finalColor = _ColorX.rgb * max(0,dot(o.Normal, RIGHT)) * _ColorX.a;
      finalColor += _ColorY.rgb * max(0,dot(o.Normal, UP)) * _ColorY.a;
      finalColor += gradient;
      finalColor = saturate(finalColor);
      o.Emission = lerp(half3(0,0,0), finalColor, _EmissiveStrengh);
      #ifdef USE_TEXTURE
        o.Albedo = col.rgb;
      #else
        o.Albedo = finalColor * saturate(1 - _EmissiveStrengh);
      #endif
      o.Alpha = 1;
    }
    ENDCG
  }
  fallback "Vertex Lit"
}