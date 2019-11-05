Shader "Custom/Skin"
{
	Properties
	{
		[header(Subsurface Scattering)]
		_SubsurfaceScatteringStrength("Subsurface Scattering Strength", Range(0.001, 0.999)) = 0.9
		_SubsurfaceScatteringBias("Subsurface Scattering Diffuse Normal Bias", Range(0, 10)) = 3.0
		_DiffuseScatteringLookup("Diffuse Scattering Lookup", 2D) = "white" {}
		_ShadowScatteringLookup("Shadow Scattering Lookup", 2D) = "white" {}

		[Space(20)]

		_Color("Color", color) = (1, 1, 1, 1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_MetallicRoughnessMap("Metallic(R), Roughness(A)", 2D) = "white" {}
		_BumpScale("Bump Scale", Range(0, 1)) = 1.0
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}
		
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
		}
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"
		#include "UnityStandardVariables.cginc"
		#include "UnityStandardUtils".cginc
		#include "UnityStandardBRDF.cginc"
		
		#pragma target 5.0
		#pragma multi_compile_fwdbase
		
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _NormalMap;
		sampler2D _MetallicRoughnessMap;
		
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _BumpScale;
		
		// Scattering
		float _SubsurfaceScatteringStrength;
		float _SubsurfaceScatteringBias;
		sampler2D _DiffuseScatteringLookup;
		sampler2D _ShadowScatteringLookup;
		
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
			float4 tangent: TANGENT;
		};
		
		struct Input
		{
			half3 tspace0 : TEXCOORD0;
			half3 tspace1 : TEXCOORD1;
			half3 tspace2 : TEXCOORD2;
			float2 uv : TEXCOORD3;
			float2 uv1 : TEXCOORD4;
			float4 worldPos : TEXCOORD5;
			float3 viewDir : POSITION2;
			float3 lightDir : POSITION3;
			SHADOW_COORDS(7)
			float pos : SV_POSITION;
		};
		
		float3 SubsurfaceScatteringDiffuse(float nDotL, float subsurfaceScattering)
		{
			float4 uv = float4(0.5 * nDoL + 0.5, subsurfaceScattering, 0, 0);
			return tex2Dlod(_DiffuseScatteringLookup, uv).rgb;
		}
		
		float3 SubsurfaceScatteringShadow(float shadow, float subsurfaceScattering)
		{
			float4 uv = float4(shadow, subsurfaceScattering, 0, 0);
			return tex2Dlod(_ShadowScatteringLookup, uv).rgb;
		}
		
		ENDCG
	}
   FallBack "Diffuse"
}
