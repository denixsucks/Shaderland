Shader "Unlit/Bruh"
{
  Properties
  {
    _MainTex ("Texture", 2D) = "white" {}
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
  SubShader
  {
    Tags { "RenderType"="Opaque" }
    LOD 100

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile ___ USE_TEXTURE
      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f
      {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float3 worldPos : POSITION1;
      };

      #define WHITE3 fixed3(1,1,1)
      #define UP float3(0,1,0)
      #define RIGHT float3(1,0,0)
      sampler2D _MainTex;
      fixed4 _MainTex_ST;
      fixed4 _ColorLow;
      fixed4 _ColorHigh;
      fixed4 _ColorX;
      fixed4 _ColorY;
      half _yPosLow;
      half _yPosHigh;
      half _GradientStrength;
      half _EmissiveStrengh;

      v2f vert (appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
        float4 final = (0,0,0,1);
        float4 col = tex2D(_MainTex, i.uv);
        half3 gradient = lerp(_ColorLow, _ColorHigh,  smoothstep(_yPosLow, _yPosHigh, i.worldPos.y)).rgb;
        gradient = lerp(WHITE3, gradient, _GradientStrength);
        half3 finalColor = _ColorX.rgb * max(0,dot(i.uv, RIGHT)) * _ColorX.a;
        finalColor += _ColorY.rgb * max(0,dot(i.uv, UP)) * _ColorY.a;
        finalColor += gradient;
        finalColor = saturate(finalColor);
        // o.Emission = lerp(half3(0,0,0), finalColor, _EmissiveStrengh);
        #ifdef USE_TEXTURE
          final.rgb = col.rgb;
        #else
          final.rgb = finalColor * saturate(1 - _EmissiveStrengh);

        #endif
        return final;
      }
      ENDCG
    }
  }
}
