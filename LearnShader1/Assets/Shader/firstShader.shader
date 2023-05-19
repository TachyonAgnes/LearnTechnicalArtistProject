Shader "TA/1stShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
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
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v) 
            {
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
    }
}
