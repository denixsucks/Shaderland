
#ifndef URP_STRUCTURE_FORWARD_PASS_INCLUDED
#define URP_STRUCTURE_FORWARD_PASS_INCLUDED

#include "HelperFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float fogCoord : TEXCOORD1;
    float4 positionCS : SV_POSITION;

    float3 positionWS : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float3 tangentWS : TEXCOORD4;
    float3 bitangentWS : TEXCOORD5;
    float3 viewDirWS : TEXCOORD6;

    float3 viewDirTangent : TEXCOORD7;
    float2 matcapUV : TEXCOORD8;

    float4 shadowCoord : TEXCOORD9;
    float3 sh : TEXCOORD10;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes i)
{
    Varyings o = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_TRANSFER_INSTANCE_ID(i, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(i.positionOS.xyz);

    o.positionCS = vertexInput.positionCS;
    o.uv = TRANSFORM_TEX(i.uv, _BaseMap);
    #if defined(_FOG_FRAGMENT)
        o.fogCoord = vertexInput.positionVS.z;
    #else
        o.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
    #endif

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(i.normalOS, i.tangentOS);
    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    o.viewDirTangent = ViewDirTangentSpace(normalInput, viewDirWS);

    o.matcapUV = ComputeMatcapUV(normalInput.normalWS, viewDirWS);

    o.shadowCoord = GetShadowCoord(vertexInput);

    o.sh = SampleSH(normalInput.normalWS);
    // already normalized from normal transform to WS.
    o.positionWS = vertexInput.positionWS;
    o.normalWS = normalInput.normalWS;
    o.tangentWS = normalInput.tangentWS;
    o.bitangentWS = normalInput.bitangentWS;
    o.viewDirWS = viewDirWS;

    return o;
}

half4 frag(Varyings i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    half4 finalColor = 1;

    half2 uv = i.uv;
    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    //half4 matcap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.matcapUV);
    half3 color = _BaseColor.rgb;
    half alpha = albedo.a * _BaseColor.a;

/*
    half2 screenUV = i.positionCS.xy/_ScaledScreenParams.xy;
    screenUV *= _ScreenParams.xy;
    uint index = (uint(screenUV.x) % 4) * 4 + uint(screenUV.y) % 4;
    
    //clip(alpha - DITHER_THRESHOLDS[index]);
*/
    #if _NORMALMAP
        half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        half3 normal = TransformTangentToWorld(normal	use {'beyondmarc/hlsl.vim',
		config = function()
			require 'hlsl'.setup {

			}
		end
	TS,half3x3(i.tangentWS, i.bitangentWS, i.normalWS));
    #else
        half3 normal = i.normalWS;
    #endif
    normal = normalize(normal);

    finalColor.rgb = albedo.rgb * color;

    AlphaDiscard(alpha, _Cutoff);

    float3 lighting = 0;

    lighting += i.sh;

    Light mainLight = GetMainLight(i.shadowCoord);

    lighting += LightingLambert(mainLight.color, mainLight.direction, normal) * mainLight.color * mainLight.shadowAttenuation;

    finalColor.rgb *= lighting;

    #if defined(_FOG_FRAGMENT)
        #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
            float viewZ = -i.fogCoord;
            float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
            half fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
        #else
            half fogFactor = 0;
        #endif
    #else
        half fogFactor = i.fogCoord;
    #endif
    
    finalColor.rgb = MixFog(finalColor.rgb, fogFactor);

    //float3 reflection = reflect(-i.viewDirWS,normal);
    //float3 glass = GlossyEnvironmentReflection(-i.viewDirWS, i.positionWS, 0.0, 1.0);
    //float3 reflection = GlossyEnvironmentReflection(reflect, i.positionWS, 0.0, 1.0);
    //finalColor.rgb = glass;
    
    return finalColor;
}

#endif
