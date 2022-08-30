Shader "Deniz/Unlit/Fresnel"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        
        _FresnelPower ("Fresnel Power", Range(0.0,20.0)) = 0.1
        _FresnelInteger ("Fresnel Integer", int) = 0
        
        }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
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
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float _FresnelPower;
            int _FresnelInteger;
            
            float FresnelEffect(float3 normal, float3 viewDir, float fresnelPow)
            {
                return pow((1-saturate(dot(normal,viewDir))), fresnelPow);
            }
            Varyings vert (Attributes v)
            { 
                Varyings o; // could be "= (Varyings)0;" for other TEXCOORDX's 
                VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexInputs.positionCS;
                o.normal_world = normalize((mul(UNITY_MATRIX_M, float4(v.normal,0))).xyz);
                o.vertex_world = mul(UNITY_MATRIX_M, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }
			
            float4 frag (Varyings i) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                float fresnel= FresnelEffect(i.normal_world, viewDir,_FresnelPower);
                col += fresnel * _FresnelInteger;
                return col;

           }
            ENDHLSL
        }
    }
}
