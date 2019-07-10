Shader "Learning/Nature/SimpleTree_VertexColor"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Cutoff("Alpha CutOff", Range(0,1)) = 0.5

		[Header(Tree Wind)]
		_LeafWindPower("leafWindPower ", Float) = 1.5
		_LeafWindDir("leafWindDir" , Vector) = (1,0.5,0.5,0)
		_LeafWindAtt("leafWindAtt ", Float) = 0.03
		_TrunkWindPower("trunkWindPower ", Float) = 0.5
		_TrunkWindAtt("trunkWindAtt ", Float) = 1
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

			fixed _LeafWindPower;
			fixed4 _LeafWindDir;
			fixed _LeafWindAtt;
			fixed _TrunkWindPower;
			fixed _TrunkWindAtt;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
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

			#define PI 3.14
			fixed4 TreeWind(fixed4 vertexColor, fixed3 normaldir, fixed leafWindPower, fixed4 leafWindDir, fixed leafWindAtt, fixed trunkWindPower, fixed trunkWindAtt) 
			{
				fixed a = (vertexColor.r * PI + _Time.y*leafWindPower);
				fixed b = sin(a * 3)*0.2 + sin(a);
				fixed k = cos(a * 5);
				fixed d = b - k;
				fixed4 e = vertexColor.r * d *  (normalize(leafWindDir + normaldir.xyzz)) * leafWindAtt;

				fixed f = _Time.y * trunkWindPower;
				fixed g = sin(f) *  trunkWindAtt * vertexColor.r;
				fixed h = cos(f) * 0.5 * trunkWindAtt * vertexColor.r;
				fixed3 i = fixed3(g, 0, h);
				fixed4 j = e + i.xyzz;
				return j;
			}

			v2f vert(appdata v)
			{
				v2f o;
				fixed4 windv = TreeWind(v.color, v.normal, _LeafWindPower, _LeafWindDir, _LeafWindAtt, _TrunkWindPower, _TrunkWindAtt);
				v.vertex += windv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);
				return col;
			}
			ENDCG
		}
	}
}

