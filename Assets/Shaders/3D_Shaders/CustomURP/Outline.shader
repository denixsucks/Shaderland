Shader "Custom/Outline"
{
    Properties
    {
        _OutlineColor ("Outline color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0.0, 1.0)) = 0.1
        _WobbleWidth ("Wobble Width", Range(0.0, 1.0)) = 0.0
        _AnimSpeed ("Animation Speed",float) = 1.0
        _Offset ("Offset",float) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off
        ZTest Always
        
        Pass
        {
            Stencil
            {
                Ref 3
                Comp always
                Pass replace
            }
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            float4 vert(appdata_base v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }
            half4 frag() : SV_Target
            {
                return 0.0;
            }
            ENDCG

        }
        
        Pass
        {
            Stencil
            {
                Ref 3
                Comp notequal
                Pass Keep
            }
            
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag

            float4 _OutlineColor;
            float _OutlineWidth;
            float _WobbleWidth;
            float _AnimSpeed;
            float _Offset;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
            };
            v2f vert(appdata v)
            {
                appdata original = v;
                float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));
                float outlinewidth = _OutlineWidth + _WobbleWidth*(sin(_Time.y*_AnimSpeed)*0.5+0.5);
                v.vertex.xyz += normalize(v.normal.xyz) * outlinewidth;
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos.z += _Offset;
                return o;
            }
            half4 frag(v2f i, fixed facing : VFACE) : SV_Target
            {
                half4 color = _OutlineColor;
                return color;
            }
            ENDCG

        }
        
        Pass
        {
            Stencil
            {
                Ref 0
                Comp always
                Pass replace
            }
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            float4 vert(appdata_base v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }
            half4 frag() : SV_Target
            {
                return 0.0;
            }
            ENDCG

        }
    }
}