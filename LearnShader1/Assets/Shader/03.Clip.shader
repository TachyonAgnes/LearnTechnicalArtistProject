Shader "TA/Clip"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _NoiseTex("Noise Tex", 2D) = "white" {}
        _Cutout("Cutout", Range(-0.1, 1.1)) = 0.0
        _Speed("Speed", Vector) = (1,1,0,0)
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
    }
    SubShader
    {
        Pass
        {
            Cull [_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;            
                float2 uv: TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float2 pos_uv : TEXCOORD1;
            };
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float _Cutout;
            float4 _Speed;
            float4 _MainColor;

            v2f vert(appdata v) 
            {
                v2f obj;
                obj.pos = UnityObjectToClipPos(v.vertex);
                obj.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                obj.pos_uv = v.vertex.xz * _MainTex_ST.xy + _MainTex_ST.zw;
                return obj;
            }

            float4 frag(v2f i): SV_Target 
            {
                half gradient = tex2D(_MainTex, i.uv + _Time.y * _Speed.xy).r;
                half noise = tex2D(_NoiseTex, i.uv + _Time.y * _Speed.zw).r;
                clip(gradient - noise - _Cutout);
                return _MainColor;
            }
            ENDCG
        }
    }
}
