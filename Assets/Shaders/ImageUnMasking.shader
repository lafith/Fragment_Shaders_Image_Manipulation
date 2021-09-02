Shader "Lfz/ImageUnMasking"
{
    // Note:
    // (0.5,0.5,0.5,0.0) for contrast
    //(0,0,0,0) for brightness
    Properties
    {
        _IDW ("I_dontwant", Vector) = (0.0,0.0,0.0,0.0)
        _T ("Unmask Factor", Float) = 1.0
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

            float4 _IDW;
            float _T;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 I_in = tex2D(_MainTex, i.uv);
                // Image Unmasking:
                float4 col = (1-_T)*_IDW + _T*I_in;   
                return col;
            }
            ENDCG
        }
    }
}
