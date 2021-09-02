Shader "Lfz/Distortion"
{
    Properties
    {
        _S0 ("Distortion Centre S0", Float) = 0.0
        _T0 ("Distortion Centre T0", Float) = 0.0
        _Power ("Distortion Power", Float) = 1.0
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _S0;
            float _T0;
            float _Power;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Distortion effect
                float2 delta = i.uv - float2(_S0, _T0);
                float2 st = float2(_S0, _T0) + (sign(delta)*pow(abs(delta),_Power));
                float4 col = tex2D(_MainTex, st);
                return col;
            }
            ENDCG
        }
    }
}
