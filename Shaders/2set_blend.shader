Shader "Custom/2set_blend"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Albedo A (RGB)", 2D) = "white" {}
		[NoScaleOffset] _MetallicGlossMap("Metal(R) Roughness(A)", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("Normal Map", 2D) = "bump" {}

		_ColorB("Color", Color) = (1, 1, 1, 1)
		_AlbedoB("Albedo B (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMapB("Metal(R) Roughness(A)", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMapB("Normal Map", 2D) = "bump" {}
	}

	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows
		#pragma target 5.0

		#include "UnityCG.cginc"	

		UNITY_DECLARE_TEX2D(_MainTex);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);

		UNITY_DECLARE_TEX2D(_AlbedoB);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMapB);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMapB);

		float4 _Color;
		float4 _ColorB;		

        struct v2f
        {
            float4 pos : SV_POSITION;
            fixed4 color : COLOR;
        };

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_AlbedoB;
            float3 vertexColor;
        };

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertexColor = v.color;
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float4 blendMask = IN.vertexColor.x;
			half4 albedoA = _Color * UNITY_SAMPLE_TEX2D(_MainTex, IN.uv_MainTex);
			half4 albedoB = _ColorB * UNITY_SAMPLE_TEX2D(_AlbedoB, IN.uv_AlbedoB);
			o.Albedo = lerp(albedoB, albedoA, blendMask);

			half4 metalSmoothA = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap, _MainTex, IN.uv_MainTex);
			half4 metalSmoothB = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMapB, _AlbedoB, IN.uv_AlbedoB);
			o.Metallic = lerp(metalSmoothB.r, metalSmoothA.r, blendMask);
			o.Smoothness = 1 - lerp(metalSmoothB.a, metalSmoothA.a, blendMask);

			float3 normalA = UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, IN.uv_MainTex));
			float3 normalB = UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMapB, _AlbedoB, IN.uv_AlbedoB));
			o.Normal = normalize(lerp(normalB, normalA, blendMask));
			o.Alpha = 1;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
