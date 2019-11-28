Shader "Custom/4sets_blend"
{
	Properties
	{
		[Header(Mask)]
		_Mask("Mask", 2D) = "black" {}

		[space(30)]
		[Header(Layer Base)]
		_BaseAlbe("Albedo(RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_BaseNormal("Normal", 2D) = "bump" {}
		[NoScaleOffset]_BaseMetRough("Metallic(R) Roughness(G)", 2D) = "white" {}

		[space(30)]
		[Header(Layer 1)]
		_AlbeR("Albedo(RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalR("Normal", 2D) = "bump" {}
		[NoScaleOffset]_MetRoughR("Metallic(R) Roughness(G)", 2D) = "white" {}
		
		[space(30)]
		[Header(Layer 2)]
		_AlbeG("Albedo(RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalG("Normal", 2D) = "bump" {}
		[NoScaleOffset]_MetRoughG("Metallic(R) Roughness(G)", 2D) = "white" {}

		[space(30)]
		[Header(Layer 2)]
		_AlbeB("Albedo(RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalB("Normal", 2D) = "bump" {}
		[NoScaleOffset]_MetRoughB("Metallic(R) Roughness(G)", 2D) = "white" {}
	}

	SubShader
	{
		CGPROGRAM
		#pragma surface Surf Standard noforwardadd vertex:Vert
		#pragma target 5.0

		#include "UnityCG.cginc"
		
		UNITY_DECLARE_TEX2D(_Mask);
		
		UNITY_DECLARE_TEX2D(_BaseAlbe);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BaseNormal);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BaseMetRough);

		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbeR);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalR);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetRoughR);

		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbeG);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalG);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetRoughG);

		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbeB);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalB);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetRoughB);

		struct Input
		{
			float2 uv_BaseAlbe;
			float2 uv_AlbeR;
			float2 uv_AlbeG;
			float2 uv_AlbeB;
			float2 uv2_Mask;
		};

		void Vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
		}

		void Surf(Input IN, inout SurfaceOutputStandard o)
		{
			float3 mask = UNITY_SAMPLE_TEX2D(_Mask, IN.uv2_Mask).rgb;

			float3 albedoB	= UNITY_SAMPLE_TEX2D(_BaseAlbe, IN.uv_BaseAlbe);
			float3 albedo1 = UNITY_SAMPLE_TEX2D_SAMPLER(_AlbeR, _BaseAlbe, IN.uv_AlbeR); 
			float3 albedo2 = UNITY_SAMPLE_TEX2D_SAMPLER(_AlbeG, _BaseAlbe, IN.uv_AlbeG); 
			float3 albedo3 = UNITY_SAMPLE_TEX2D_SAMPLER(_AlbeB, _BaseAlbe, IN.uv_AlbeB); 

			float3 normalB	= UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BaseNormal, _BaseAlbe, IN.uv_BaseAlbe));
			float3 normal1	= UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_NormalR, _BaseAlbe, IN.uv_AlbeR));
			float3 normal2	= UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_NormalG, _BaseAlbe, IN.uv_AlbeG));
			float3 normal3	= UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_NormalB, _BaseAlbe, IN.uv_AlbeB));

			float2 metallicRoughnessB  = UNITY_SAMPLE_TEX2D_SAMPLER(_BaseMetRough, _BaseAlbe, IN.uv_BaseAlbe).rg;
			float2 metallicRoughness1 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetRoughR, _BaseAlbe, IN.uv_AlbeR).rg;
			float2 metallicRoughness2 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetRoughG, _BaseAlbe, IN.uv_AlbeG).rg;
			float2 metallicRoughness3 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetRoughB, _BaseAlbe, IN.uv_AlbeB).rg;

			float3 oneMinusMask = 1 - mask;

			float MB = oneMinusMask.r * oneMinusMask.g * oneMinusMask.b;
			float M1 = mask.r * oneMinusMask.g * oneMinusMask.b;
			float M2 = mask.g * oneMinusMask.b;
			float M3 = mask.b;

			float3 albedo = MB * albedoB + 
					M1 * albedo1 + 
					M2 * albedo2 + 
					M3 * albedo3;

			float3 normal = MB * normalB + 
					M1 * normal1 +  
					M2 * normal2 +  
					M3 * normal3;

			normal = normalize(normal);

			float2 metallicRoughness = MB * metallicRoughnessB +
						   M1 * metallicRoughness1 +
						   M2 * metallicRoughness2 +
						   M3 * metallicRoughness3;

			o.Albedo = albedo;
			o.Normal = normal;
			o.Metallic = metallicRoughness.r;
			o.Smoothness = 1.0 - metallicRoughness.g;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
