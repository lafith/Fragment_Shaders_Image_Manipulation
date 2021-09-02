Shader "Lfz/Sharpening"
{
    Properties
    {
        // 0 will give blur effect
        _T ("Sharpening Factor", Float) = 1.0
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
            float4 _MainTex_TexelSize;            
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
                // kernel step:
                float2 _Kernel_hz = float2(_MainTex_TexelSize.x,0); //horizontal step 
                float2 _Kernel_vt = float2(0,_MainTex_TexelSize.y); //vertical step
                float2 _Kernel_diag0 = float2(
                    _MainTex_TexelSize.x,
                    _MainTex_TexelSize.y
                    ); //top right 
                float2 _Kernel_diag1 = float2(
                    _MainTex_TexelSize.x,
                    -_MainTex_TexelSize.y
                    );//bottom right 

                // access colors:
                /*
                [c_00 c_01 c_02
                 c_10 c_11 c_12
                 c_20 c_21 c_22]
                */
                float4 c_00 = tex2D(_MainTex, i.uv - _Kernel_diag1);
                float4 c_01 = tex2D(_MainTex, i.uv + _Kernel_vt);
                float4 c_02 = tex2D(_MainTex, i.uv + _Kernel_diag0);
                float4 c_10 = tex2D(_MainTex, i.uv - _Kernel_hz);
                float4 c_11 = tex2D(_MainTex, i.uv);
                float4 c_12 = tex2D(_MainTex, i.uv + _Kernel_hz);
                float4 c_20 = tex2D(_MainTex, i.uv - _Kernel_diag0);
                float4 c_21 = tex2D(_MainTex, i.uv - _Kernel_vt);
                float4 c_22 = tex2D(_MainTex, i.uv + _Kernel_diag1);

                // summation:
                float4 col = float4(0,0,0,0);
                col += c_00+c_02+c_20+c_22;
                col += 2*(c_01+c_10+c_12+c_21);
                col += 4*c_11;
                col /= 16;
                col = (1-_T)*col + _T*tex2D(_MainTex, i.uv);
                //col = tex2D(_MainTex, i.uv); //original color
                return col;
            }
            ENDCG
        }
    }
}
