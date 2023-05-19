Shader "TA/Blending"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Emiss("Emiss", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
    }
        SubShader
    {
        Pass
        {
            Tags{"Queue" = "Transparent"}
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
            };

            struct v2f {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _Emiss;

            v2f vert(appdata v) {
                v2f obj;
                obj.pos = UnityObjectToClipPos(v.vertex);
                obj.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return obj;
            }

            half4 frag(v2f i): SV_Target
            {
                half3 col = _MainColor.xyz * _Emiss;
                half alpha = saturate(tex2D(_MainTex, i.uv).r * _MainColor.a * _Emiss);
                
                return float4(col, alpha);
            }
            ENDCG
        }
    }
}
