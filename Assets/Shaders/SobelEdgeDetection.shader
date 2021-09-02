Shader "Lfz/SobelEdgeDetection"
{
    Properties
    {
        // 0 will give blur effect
       // _T ("Sharpening Factor", Float) = 1.0
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
            //float _T;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 lum = float4(0.2125, 0.7154, 0.0721,1.0);
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
                
                float c_00 = dot(tex2D(_MainTex, i.uv - _Kernel_diag1), lum);
                float c_01 = dot(tex2D(_MainTex, i.uv + _Kernel_vt), lum);
                float c_02 = dot(tex2D(_MainTex, i.uv + _Kernel_diag0), lum);
                float c_10 = dot(tex2D(_MainTex, i.uv - _Kernel_hz), lum);
                float c_11 = dot(tex2D(_MainTex, i.uv), lum);
                float c_12 = dot(tex2D(_MainTex, i.uv + _Kernel_hz), lum);
                float c_20 = dot(tex2D(_MainTex, i.uv - _Kernel_diag0), lum);
                float c_21 = dot(tex2D(_MainTex, i.uv - _Kernel_vt), lum);
                float c_22 = dot(tex2D(_MainTex, i.uv + _Kernel_diag1), lum);

                // filter:
                float c_h = 2* (c_21-c_01)+ (c_20+c_22-c_00-c_02);
                float c_v = (c_02+c_22-c_00-c_20) + 2*(c_12-c_10);
                float c = sqrt(pow(c_h,2)+pow(c_v,2));
                float4 col = float4(c,c,c,1);
                //col = tex2D(_MainTex, i.uv); //original color
                return col;
            }
            ENDCG
        }
    }
}
