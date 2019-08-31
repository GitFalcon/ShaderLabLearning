Shader "Learning/Advance/Dissolve_UV"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

        _DissolveTex ("Dissolve Texture", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0, 1)) = 1
        _DissolveEdge ("Dissolve Edge", Range(0, 1)) = 0
        _EdgeColor ("Edge Color", Color) = (0.5,0.5,0.5,1)
        _RotateUV ("Rotate UV", Range(0, 6.3)) = 0
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
	float4 _EdgeColor;
	float _RotateUV;

	struct appdata
	{
		float4 vertex : POSITION;
		float2 texcoord0 : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};

	v2f vert(appdata v)
	{
		v2f o = (v2f)0;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv0 = v.texcoord0;
		o.uv1 = v.texcoord1;
		return o;
	}


	float ComputeDissolve(float2 uv, float2 uv1)
	{
		fixed4 dissolveCol = tex2D(_DissolveTex, TRANSFORM_TEX(uv, _DissolveTex));
		float s, c;
		sincos(_RotateUV, s, c);
		float2 pivot = float2(0.5, 0.5);
		float2 uvRot = pivot + mul(uv1 - pivot, float2x2(c, -s, s, c));
		return pow(dissolveCol.r * _Dissolve + _Dissolve, 3.0) * pow(uvRot.r * _Dissolve + _Dissolve, 10.0);
	}

	float4 frag(v2f i) : COLOR
	{
		float dissolve = ComputeDissolve(i.uv0,i.uv1);
		fixed3 edgeCol = (_DissolveEdge > dissolve) *_EdgeColor.rgb;
		fixed4 mainCol = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));
		fixed3 emissiveCol = mainCol.rgb;
		return fixed4(emissiveCol + edgeCol, step(0.5, dissolve));
	}

	ENDCG

	SubShader
	{
		Tags { "RenderType"="Transparent" }
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
