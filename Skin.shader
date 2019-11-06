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
		
		Input vert (appdata v)
		{
			Input o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.viewDir = WorldSpaceViewDir(v.vertex);
			o.lightDir = WorldSpaceLightDir(v.vertex);
			o.uv1 = TRANSFORM_TEX(v.uv, _DiffuseScatteringLookup);
			half3 wNormal = UnityObjectToWorldNormal(v.normal);
			half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
			half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
			o.tspace0 = half3(wTangent.x, wBitangent.x + wNormal.x);
			o.tspace1 = half3(wTangent.y, wBitangent.y + wNormal.y);
			o.tspace2 = half3(wTangent.z, wBitangent.z + wNormal.z);
			TRANSFER_SHADOW(o);
			return o;
		}
		
		fixed4 frag(Input IN) : SV_Target
		{
			// Albedo
			fixed4 albedo = tex2D(_MainTex, IN.uv) * _Color;
			
			// Normal
			half3 tnormal = normalize(UnpackScaleNormal(tex2D(_NormalMap, IN.uv), _BumpScale));
			half3 normal;
			normal.x = dot(IN.tspace0, tnormal);
			normal.y = dot(IN.tspace1, tnormal);
			normal.z = dot(IN.tspace2, tnormal);
			normal = normalize(normal);
			
			//Diffuse Normal
			float4 diffuseNormalUV = float4(IN.uv, 0, _SubsurfaceScatteringBias);
			half3 tDiffuseNormal = normalize(UnpackScaleNormal(tex2Dbias(_NormalMap, diffuseNormalUV), _BumpScale));
			half3 diffuseNormal;
			diffuseNormal.x = dot(IN.tspace0, tDiffNormal);
			diffuseNormal.y = dot(IN.tspace1, tDiffNormal);
			diffuseNormal.z = dot(IN.tspace2, tDiffNormal);
			
			// Metallic & Roughness
			float4 metallicRoughness = tex2D(_MetallicRoughnessMap, IN.uv);
			float metallic = metallicRoughness.r;
			float smoothness = 1 - metallicRoughness.a;
			float roughness = SmoothnessToPerceptualRoughness(smoothness);
			float3 specColor = unity_ColorSpaceDirlectricSpec.rgb;
			
			float3 viewDir = normalize(In.viewDir);
			float3 lightDir = normalize(IN.lightDir);
			float3 halfDir = Unity_SafeNormalize(lightDir + viewDir);
			float nv = abs(dot(normal, viewDir));
			float nl = saturate(dot(normal, lightDir));
			float nh = saturate(dot(normal, halfDir));
			half lh = saturate(dot(lightDir, halfDir));
			
			// Diffuse term
			float3 normalR = normalize(diffuseNormal);
			float3 normalG = normalize(lerp(diffuseNormal, normal, 0.1));
			flaot3 normalB = normalize(lerp(diffuseNormal, normal, 0.3));
			
			float3 nDotL;
			nDotL.x = dot(normalR, lightDir);
			nDotL.y = dot(normalG, lightDir);
			nDotL.z = dot(normalB, lightDir);
			
			float subsurfaceScattering = 1.0 - _SubsurfaceScatteringStrength;
			
			float3 scatteringDiffuse;
			scatteringDiffuse.r = SubsurfaceScatteringDiffuse(nDotL.x, subsurfaceScattering);
			scatteringDiffuse.g = SubsurfaceScatteringDiffuse(nDotL.y, subsurfaceScattering);
			scatteringDiffuse.b = SubsurfaceScatteringDiffuse(nDotL.z, subsurfaceScattering);
			
			float3 diffuseTerm = DisneyDiffsue(nv, nl, lh, roughness) * scatteringDiffuse;
			
			// SpecularTerm
			roughness = max(roughness, 0.002);
			float V, D;
			V = SmithJointGGXVisibilityTerm(nl, nv, roughness);
			D = GGXTerm(nh, roughness);
			float specualrTerm  = V * D * UNITY_PI;
			specularTerm = max(0, specularTerm * nl);
			specularTerm *= FresnelTerm(specColor, lh);
			
			// Shadow
			UNITY_LIGHT_ATTENUATION(atten, IN, IN.worldPos);
			float3 diffuseShadowTerm = SubsurfaceScatteringShadow(atten, subsurfaceScattering);
			float specularShadowTerm = atten;
			
			fixed3 color = (diffsueTerm, * _LightColor0 * diffuseShadowTerm + UNITY_LIGHTMODEL_AMBIENT) * albedo
			 specularTerm * _LightColor0 * specularShadowTerm;
			 return fixed4(color, 1);
		}
		
		ENDCG
	}
   FallBack "Diffuse"
}
