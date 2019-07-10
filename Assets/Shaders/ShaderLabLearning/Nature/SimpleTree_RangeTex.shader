Shader "Learning/Nature/SimpleTree_RangeTex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cutoff("Alpha CutOff", Range(0,1)) = 0.5

		[Header(Tree Wind)]
		_RangeTex("RangeTex", 2D) = "white" {}
		_Length("Length", Float) = 1
		_Speed("Speed", Float) = 1
		_Direction("Direction", Color) = (0.1172414,1,0,1)
		_Level("Level", Float) = 0.05
		_Range("Range", Float) = 1
	}
	SubShader
	{
		Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutoff;

			sampler2D _RangeTex; 
			float4 _RangeTex_ST;
			float _Length;
			float _Speed;
			float4 _Direction;
			float _Level;
			float _Range;

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

			fixed3 TreeWind(float4 rangeCol, float length, float speed, float4 direction, float level, float range)
			{
				fixed3 wind = (sin(((rangeCol.rgb * length) + (_Time.g * speed))) * direction.rgb * level * (rangeCol.rgb * range));
				return wind;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 rangeCol = tex2Dlod(_RangeTex, float4(TRANSFORM_TEX(v.uv, _RangeTex), 0.0, 0));
				fixed3 windv = TreeWind(rangeCol, _Length, _Speed, _Direction, _Level, _Range);
				v.vertex.xyz += windv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);
				return col;
			}
			ENDCG
		}
	}
}
