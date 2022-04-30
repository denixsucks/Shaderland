#ifndef HELPER_INCLUDE
#define HELPER_INCLUDE

float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c, t * x * y - s * z, t * x * z + s * y,
        t * x * y + s * z, t * y * y + c, t * y * z - s * x,
        t * x * z - s * y, t * y * z + s * x, t * z * z + c
    );
}

float3 ViewDirTangentSpace(float3 normal, float3 tangent, float3 bitangent, float3 viewDir)
{
    return float3(
        dot(viewDir.xyz, tangent.xyz),
        dot(viewDir.xyz, bitangent.xyz),
        dot(viewDir.xyz, normal.xyz));
}
float3 ViewDirTangentSpace(VertexNormalInputs vni,float3 viewDir)
{
    return ViewDirTangentSpace(vni.normalWS, vni.tangentWS, vni.bitangentWS, viewDir);
}
float2 ComputeMatcapUV(float3 normalWS, float3 viewDirectionWS)
{
    float3 rotation = mul((float3x3)UNITY_MATRIX_V, float3(0, -1, 0));
    float angle = atan2(rotation.x, rotation.y);
    float3x3 rotCorrection = AngleAxis3x3(angle, float3(0, 0, 1));
    float3 viewDir = normalize(mul((float3x3)UNITY_MATRIX_V, viewDirectionWS));
    float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V, -normalWS));
    
    normalVS = mul(rotCorrection, normalVS);
    viewDir = mul(rotCorrection, viewDir);

    float a = 1.0 / (1.0 + viewDir.z);
    float b = -viewDir.x * viewDir.y * a;
    float3 b1 = float3(1.0 - viewDir.x * viewDir.x * a, b, -viewDir.x);
    float3 b2 = float3(b, 1.0 - viewDir.y * viewDir.y * a, -viewDir.y);
    float2 matcap_uv = float2(dot(b1, normalVS), dot(b2, normalVS));
    return matcap_uv * 0.5 + 0.5;
}

float invLerp(float from, float to, float value)
{
    return (value - from) / (to - from);
}

float3 invLerp(float3 from, float3 to, float3 value)
{
    return (value - from) / (to - from);
}

float4 invLerp(float4 from, float4 to, float4 value)
{
    return (value - from) / (to - from);
}

float remap(float origFrom, float origTo, float targetFrom, float targetTo, float value)
{
    float rel = invLerp(origFrom, origTo, value);
    return lerp(targetFrom, targetTo, rel);
}

float4 remap(float4 origFrom, float4 origTo, float4 targetFrom, float4 targetTo, float4 value)
{
    float4 rel = invLerp(origFrom, origTo, value);
    return lerp(targetFrom, targetTo, rel);
}

float DITHER_THRESHOLDS[16] = {
    1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
    13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
    4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
    16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
};

#endif