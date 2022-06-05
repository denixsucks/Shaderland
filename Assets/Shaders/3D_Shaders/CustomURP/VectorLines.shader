         
Shader "Unlit/VectorLines"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        [HDR] _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _Threshold ("Threshold", Range(0.,1.)) = 1.
        _Thickness ("Thickness",Range(0.0,1.0)) = 0.5
        _Smoothness ("Smoothness", Range(0.0,1.0)) = 0.0
        
        
        _Outline_Color ("Outline Color", Color) = (1,1,1,1)
        _Outline_Thickness ("Outline Thickness", Range(0.0,1.0)) = 0.1
        _Outline_Smoothness ("Outline Smoothness",Range(0.0,1.0)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
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
                //float3 normal : NORMAL;
                //float3 positionWS : TEXCOORD1;
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _EmissionColor;
            float _Threshold;
            float _Thickness;
            float _Smoothness;


            float4 _Outline_Color;
            float _Outline_Thickness;
            float _Outline_Smoothness;


         
            
            Varyings vert (Attributes v)
            { 
                Varyings o; // could be "= (Varyings)0;" for other Coordinate's 
                const VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexInputs.positionCS;
                //o.positionWS =  vertexInputs.positionWS;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float a = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).r *_EmissionColor * _Threshold;
                const float outline = smoothstep(_Outline_Thickness - _Outline_Smoothness, _Outline_Thickness +_Outline_Smoothness,a);
                a = smoothstep(1.0 - _Thickness - _Smoothness, 1.0 - _Thickness + _Smoothness,a);

                // -- DIFFERENT IMPLEMENTATION
                //float dist = i.positionWS;
                //float distanceChange = fwidth(dist) * 0.5;
                //float antialiasedCutoff = smoothstep(1.0 - distanceChange, 1.0 - distanceChange, dist);

                float4 col = lerp(_Outline_Color + _CosTime ,_BaseColor,outline);
                col.a = a;
                
                return col;
           }
            ENDHLSL
        }
    }
}
