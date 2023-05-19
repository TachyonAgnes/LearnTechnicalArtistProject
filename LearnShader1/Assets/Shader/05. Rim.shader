// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Rim"
{
    Properties
    {
        _MainTex("Texture", 2D) = "grey" {}
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Emiss("Emiss", Float) = 1.0
        _RimThreshold("RimThreshold", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
    }
        SubShader
    {
        tags{"Queue" = "Transparent"}
        Pass
        {
            Cull[_CullMode]
            ZWrite On
            ColorMask 0 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
            float4 vertex : POSITION;
            float2 uv: TEXCOORD0;
        };

        struct v2f {
            float4 pos: SV_POSITION;
            float2 uv: TEXCOORD0;
        };
        sampler2D _MainTex;
        float4 _MainTex_ST;

        v2f vert(appdata v) {
            v2f obj;
            obj.pos = UnityObjectToClipPos(v.vertex);
            obj.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
            return obj;
        }

        float4 frag(v2f i): SV_Target
        {
            float4 col = tex2D(_MainTex, i.uv);
            return col;
        }
            ENDCG
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull[_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normal_world: TEXCOORD1;
                float3 view_world: TEXCOORD2;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _Emiss;
            float _RimThreshold;

            v2f vert(appdata v) {
                v2f obj;
                obj.pos = UnityObjectToClipPos(v.vertex);
                obj.normal_world = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                float pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                obj.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);
                obj.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return obj;
            }

            half4 frag(v2f i): SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world = normalize(i.view_world);
                float NdotV = pow(saturate(dot(normal_world, view_world)), _RimThreshold);
                float3 color = _MainColor.xyz * _Emiss;
                float fresnel = pow((1.0 - NdotV), _RimThreshold);
                float alpha = saturate(fresnel * _Emiss);
                return float4(color, alpha);
            }
            ENDCG
        }
    }
}
