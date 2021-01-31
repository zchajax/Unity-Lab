Shader "Custom/Caustic"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Header(Caustics)]
        [NoScaleOffset]_CausticTex("Caustic Tex", 2D) = "white" {}
        _CausticTex1_ST("Caustic 1 ST", Vector) = (1, 1, 0, 0)
        _CausticTex2_ST("Caustic 2 ST", Vector) = (1, 1, 0, 0)
        _CausticSpeed("Caustic Speed", Vector) = (0, 0, 0, 0)
        _SplitRGB("Split RGB", float) = 0.001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _CausticTex;
        float4 _CausticTex1_ST;
        float4 _CausticTex2_ST;
        float4 _CausticSpeed;
        float _SplitRGB;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        fixed3 SampleCaustic(float2 uv)
        {
            fixed r = tex2D(_CausticTex, uv + float2(_SplitRGB, _SplitRGB)).r;
            fixed g = tex2D(_CausticTex, uv + float2(_SplitRGB, -_SplitRGB)).g;
            fixed b = tex2D(_CausticTex, uv + float2(-_SplitRGB, -_SplitRGB)).b;

            return fixed3(r, g, b);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            float2 uv = IN.uv_MainTex * _CausticTex1_ST.xy + _CausticTex1_ST.zw;
            uv += _CausticSpeed.xy * _Time.y;
            fixed3 caustic1 = SampleCaustic(uv);

            uv = IN.uv_MainTex * _CausticTex2_ST.xy + _CausticTex2_ST.zw;
            uv += _CausticSpeed.zw * _Time.y;
            fixed3 caustic2 = SampleCaustic(uv); 

            o.Albedo += min(caustic1, caustic2);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
