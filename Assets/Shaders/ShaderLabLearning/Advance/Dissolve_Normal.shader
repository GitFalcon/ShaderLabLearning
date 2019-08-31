Shader "Learning/Advance/Dissolve_Normal"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		_Dissolve("Dissolve", Range(0, 1)) = 1
		_DissolveEdge("Dissolve Edge", Range(0, 0.2)) = 0
		_DissolveFade("Dissolve Fade", Range(0, 1)) = 0.858
		_EdgeColor("Edge Color", Color) = (0.5,0.5,0.5,1)
		_DissolveDirection("Dissolve Direction", Vector) = (1,0,0,0)
	}

	CGINCLUDE

	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _DissolveTex;
	float4 _DissolveTex_ST;
	float _Dissolve;
	float _DissolveEdge;
	float _DissolveFade;
	float4 _EdgeColor;
	float4 _DissolveDirection;

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal: NORMAL;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 normalDir: TEXCOORD2;
	};

	v2f vert(appdata v)
	{
		v2f o = (v2f)0;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.normalDir = v.normal;
		return o;
	}

	float4 frag(v2f i) : COLOR
	{
		float3 normalDirection = normalize(i.normalDir);

		fixed4 col = tex2D(_MainTex, i.uv);
		fixed4 finalCol = col;
		float dissolveVal = dot(normalDirection, normalize(_DissolveDirection.xyz)) * 0.5 + 0.5;
		float3 edgeCol = step(dissolveVal, _DissolveEdge + _Dissolve) * _EdgeColor.rgb;
		float dissolveFade = smoothstep(_Dissolve, _DissolveEdge + _Dissolve, dissolveVal);
		finalCol.rgb += edgeCol;
		finalCol.a *= step(_Dissolve, dissolveVal) * lerp(1, dissolveFade, _DissolveFade);
		finalCol = lerp(col, finalCol, step(0.001, _Dissolve));
		return finalCol;
	}

	ENDCG

	SubShader
	{
		Tags { "RenderType" = "Transparent" }
		BLEND SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull Front

			CGPROGRAM
			ENDCG
		}

		Pass
		{
			Cull Back

			CGPROGRAM
			ENDCG
		}
	}
}
