Shader "Deniz/Unlit/DndDice"
{
  Properties
  {
    _NumsTex ("Nums Texture", 2D) = "black" {}

    _BaseMap ("Texture", 2D) = "white" {}
    _NoiseTex ("Noise Texture", 2D) = "black" {}
    _NoiseTex2 ("Secondary Noise Texture", 2D) = "black" {}
    _ParticleTexture ("Particle Texture", 2D) = "black" {}

    _MainColor ("Main Color", Color) = (0,0,0,0)
    _PowerValue ("Power Value", Vector) = (1,1,0,0)
    _AnimSpeed1 ("Animation Speed 1", Float) = 0.5
    _AnimSpeed2 ("Animation Speed 2", Float) = -0.5
    [HDR]_InsideColor ("Inside Color", Color) = (0,0,0,1)
    [HDR]_InsideColor2 ("Inside Color2", Color) = (0,0,0,1) 
    _ParticleColor ("Particle Color", Color) = (1,1,1,1)

    _ParticleValue ("Particle Power Value", Float) = 0.5
    _ParticleValue2 ("Particle Value", Float) = 0.5

    _FresnelPower ("Fresnel Power", Range(0.0,20.0)) = 0.1
    _FresnelInteger ("Fresnel Integer", int) = 0
    _FresnelColor ("Fresnel Color", Color) = (0,0,0,0)
  }
  SubShader
  {
    Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}


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
        float3 normal : NORMAL;
      };

      struct Varyings
      {
        float2 uv : TEXCOORD0;
        float2 uvSecond : TEXCOORD5;
        float2 noise1uv : TEXCOORD1;
        float2 noise2uv : TEXCOORD2;
        float4 vertex : SV_POSITION;
        float3 normal_world : TEXCOORD3;
        float3 vertex_world : TEXCOORD4;
      };


      // TEXTURES
      TEXTURE2D(_NumsTex); SAMPLER(sampler_NumsTex);
      float4 _NumsTex_ST;
      TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
      float4 _BaseMap_ST;
      TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);
      float4 _NoiseTex_ST;
      TEXTURE2D(_NoiseTex2); SAMPLER(sampler_NoiseTex2);
      float4 _NoiseTex2_ST;
      TEXTURE2D(_ParticleTex); SAMPLER(sampler_ParticleTex);
      float4 _ParticleTex_ST;
      

      float2 _PowerValue;
      float _AnimSpeed1;
      float _AnimSpeed2;
      float4 _MainColor;
      float4 _InsideColor;
      float4 _InsideColor2;
      float4 _ParticleColor;
      float _ParticleValue; 
      float _ParticleValue2;  
      float _FresnelPower;
      int _FresnelInteger;
      float4 _FresnelColor;

      
      float FresnelEffect(float3 normal, float3 viewDir, float fresnelPow)
      {
        return pow((1-saturate(dot(normal,viewDir))), fresnelPow);
      }
      
      
      Varyings vert (Attributes v)
      { 
        Varyings o; // could be "= (Varyings)0;" for other TEXCOORDX's 
        VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
        o.vertex = vertexInputs.positionCS;
        o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
        o.uvSecond = TRANSFORM_TEX(v.uv, _NumsTex);
        o.noise1uv = TRANSFORM_TEX(v.uv, _NoiseTex);
        o.noise2uv = TRANSFORM_TEX(v.uv, _NoiseTex2);
        o.normal_world = normalize((mul(UNITY_MATRIX_M, float4(v.normal,0))).xyz);
        o.vertex_world = mul(UNITY_MATRIX_M, v.vertex);
        return o;
      }

      float4 frag (Varyings i) : SV_Target
      {
        float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
        float4 nums = SAMPLE_TEXTURE2D(_NumsTex, sampler_NumsTex, i.uvSecond);
        float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.noise1uv + (_Time.x * _AnimSpeed1)).r;
        float noise2 = SAMPLE_TEXTURE2D(_NoiseTex2, sampler_NoiseTex2, i.noise2uv + (_Time.x * _AnimSpeed2)).r;
        float noise3 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.noise1uv + 0.75 + (_Time.x * _AnimSpeed1)).r;
        float noise4 = SAMPLE_TEXTURE2D(_NoiseTex2, sampler_NoiseTex2, i.noise2uv + 0.25 + (_Time.x * _AnimSpeed2)).r;
        float particleTexture = SAMPLE_TEXTURE2D(_ParticleTex, sampler_ParticleTex, i.uv + (_Time.x * _AnimSpeed1)).r;
        float particle = pow(particleTexture / noise2, _ParticleValue);

        noise = pow(noise, _PowerValue.x);
        noise3 = pow(noise, _PowerValue.y);

        float4 diceInside = _InsideColor * noise * noise2;
        float4 diceInside2 = _InsideColor2 * noise3 * noise4;

        float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
        float fresnel = FresnelEffect(i.normal_world, viewDir,_FresnelPower);

        float4 particles = smoothstep((particle * _ParticleColor) * _ParticleValue2, fresnel, 2);
      
        float4 dice = _MainColor + diceInside + diceInside2;
        dice += lerp(dice, particles, 0.75);
        dice += fresnel * _FresnelInteger * _FresnelColor;
        dice += nums * 0.75;
        return dice;
      }
      ENDHLSL
    }
  }
}
