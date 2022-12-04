Shader "Deniz/Unlit/Crystal"
{
  Properties
  {
    _BaseMap ("Texture", 2D) = "white" {}
    _AlphaTexture ("Texture", 2D) = "white" {}
    _ShineTexture ("Shine Texture", 2D) = "white" {}
    _Multiplier ("Multiplier", Range(0.0,1.0)) = 0.1
    _ShineAmount ("Shine Amount", Float) = 0.1
  }
  SubShader
  {
    Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline"}
    LOD 100
    
    Pass
    {
      Tags
      {
        "LightMode" = "UseColorTexture"
      }
      
      HLSLPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

      struct Attributes
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct Varyings
      {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float3 screenpos : POSITION1;
        float3 screennorm : NORMAL;
        float4 grabPos : TEXCOORD1;
      };

      //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
      float4 _BaseMap_ST;
      sampler2D _AlphaTexture;
      sampler2D _ShineTexture;
      float4 _ShineTexture_ST;
      sampler2D _GrabbedTexture;
      sampler2D _BaseMap;
      float _Multiplier;   
      float _ShineAmount;
      

      Varyings vert (Attributes v)
      { 
        Varyings o; // could be "= (Varyings)0;" for other TEXCOORDX's 
        VertexPositionInputs vertex_inputs = GetVertexPositionInputs(v.vertex.xyz);
        VertexNormalInputs vertex_normal_inputs = GetVertexNormalInputs(v.vertex.xyz);
        o.screenpos = vertex_inputs.positionVS;
        o.vertex = vertex_inputs.positionCS;
        o.screennorm = vertex_normal_inputs.normalWS;
        o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
        return o;
      }

      float4 frag (Varyings i) : SV_Target
      {
        float4 col = tex2D(_BaseMap, i.uv);
        float alphatex = tex2D(_AlphaTexture, i.uv).a;
        float x = i.screenpos.x + i.screenpos.y + i.screennorm.x +i.screennorm.y + alphatex;
        float shine = tex2D(_ShineTexture, float2(x / _ShineAmount, 0));
        float2 ruv = i.screenpos.xy + i.screennorm.xy * _Multiplier;
        float4 refr = tex2D(_GrabbedTexture,ruv);
        float4 base = col + shine;
        return lerp(refr,base,base.a);
      }
      ENDHLSL
    }
  }
}
