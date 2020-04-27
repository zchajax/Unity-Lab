Shader "Unlit/fur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_FurLength("Fur Length", float) = 0.
		_FurRadius("Fur Radius", float) = 0.
		_Force("Force", vector) = (0, 0, 0, 0)
		_uvOffset("UV offset", vector) = (0, 0, 0, 0)
		_OcclusionColor("OcclusionColor", Color) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.05
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.1
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.15
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.2
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.25
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.3
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.35
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.4
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.45
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.5
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.55
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.6
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.65
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.7
			#include "fur_include.cginc"
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define FURSTEP 0.75
			#include "fur_include.cginc"
			ENDCG
		}
	}
}
