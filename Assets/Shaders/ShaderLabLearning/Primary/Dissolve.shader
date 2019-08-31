Shader "Learning/Primary/Dissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        
		_DissolveTex ("Dissolve Texture", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0, 1)) = 1
        _DissolveEdge ("Dissolve Edge", Range(0, 0.2)) = 0
        _EdgeColor ("Edge Color", Color) = (0.5,0.5,0.5,1)
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

	struct appdata
	{
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float4 uv : TEXCOORD0;
	};

	v2f vert(appdata v)
	{
		v2f o = (v2f)0;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _DissolveTex);
		return o;
	}

	float4 frag(v2f i) : COLOR
	{
		fixed4 col = tex2D(_MainTex, i.uv.xy);
		fixed4 dissolveCol = tex2D(_DissolveTex,i.uv.zw);
		float edge = (_DissolveEdge - (dissolveCol.r - _Dissolve));
		fixed3 edgeCol = smoothstep(0, _DissolveEdge, edge * step(0.001, _Dissolve)) * _EdgeColor.rgb;
		col.rgb += edgeCol;
		col.a *= step(_Dissolve, dissolveCol.r);
		return col;
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
