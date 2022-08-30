Shader "Deniz/Unlit/Toon"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
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
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _BaseColor;

            Varyings vert (Attributes v)
            { 
                Varyings o; // could be "= (Varyings)0;" for other TEXCOORDX's 
                VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexInputs.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                col *= _BaseColor;
                return col;

           }
            ENDHLSL
        }
    }
}
