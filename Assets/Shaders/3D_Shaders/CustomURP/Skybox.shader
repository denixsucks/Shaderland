Shader "Deniz/Unlit/Skybox"
{
  Properties
  {
    _BaseMap ("Texture", 2D) = "white" {}
    _BaseColor ("Base Color", Color) = (1,1,1,1)
    _Color1 ("Color 1", Color) = (0,0,0,1)
    _Color2 ("Color 2", Color) = (0,0,0,1)
    _CustomTexture ("Custom Texture", 2D) = "black"
    _NoiseTex ("Noise Texture", 2D) = "black" {}
    _NoiseSpeed("Noise Speed", Float) = 10.0
    _LightFlicker("Light Flicker", Float) = 0.1
    [HDR]_NoiseColor("Noise Color", Color) = (1,1,1,1)
    _PowerInt("Power Int", Range(-1.0,1.0)) = 0.5
    _Idktf("Idktf", Float) = -1.0
  }
  SubShader
  {
    Tags { "RenderType"="Skybox" "RenderPipeline" = "UniversalPipeline"}
    LOD 100

    Pass
    {
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
      };

      TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
      float4 _BaseMap_ST;
      TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);
      float4 _NoiseTex_ST;
      TEXTURE2D(_CustomTexture); SAMPLER(sampler_CustomTexture);
      float4 _CustomTexture_ST;

      float4 _Color1;
      float4 _Color2;
      float4 _BaseColor;
      float _LightFlicker;
      float _NoiseSpeed;
      float4 _NoiseColor;
      float _PowerInt;
      float _Idktf;

      Varyings vert (Attributes v)
      { 
        Varyings o;
        VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
        o.vertex = vertexInputs.positionCS;
        o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
        return o;
      }

      float4 frag (Varyings i) : SV_Target
      {
        float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
        float4 noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.uv + (_Time.y * _LightFlicker));
        float4 noise2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.uv + (_Time.x * -_NoiseSpeed));


        float4 temp = noise * _NoiseColor + 2;
        noise = noise * _NoiseColor;
        noise2 = noise2 * _NoiseColor * _Idktf;
        noise = noise * temp;
        noise = pow(noise + noise2, _PowerInt);

        col = noise;
        return col;

      }
      ENDHLSL
    }
  }
}
