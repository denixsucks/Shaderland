Shader "Deniz/Unlit/URPShaderExample1"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Diffuse ("Diffuse Value", Range(0,1)) = 1.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0)
        _Threshold ("Threshold", Range(0.,1.)) = 1.
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 col : COLOR0;
                
                float2 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
                
            };



            float4 _LightColor0;
            float _Diffuse;
            float4 _EmissionColor;
            float _Threshold;
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);




            float4 _BaseMap_ST;
            float4 _BaseColor;

            Varyings vert (Attributes v)
            { 
                Varyings o; // could be "= (Varyings)0;" for other TEXCOORDX's 
                VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                float3 lightDir = normalize(GetMainLight().direction);
                float NdotL = max(.0,dot(worldNormal, lightDir));
                float4 diff = _BaseColor * NdotL * _LightColor0 * _Diffuse;
                o.col = diff;   
                o.vertex = vertexInputs.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float4 emi = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _EmissionColor * _Threshold; ;
                i.col.rgb += emi.rgb;
                //col *= _BaseColor;
                return i.col;

           }
            ENDHLSL
        }
    }
}
