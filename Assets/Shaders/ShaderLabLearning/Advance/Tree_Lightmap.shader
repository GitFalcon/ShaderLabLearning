Shader "Learning/Advance/Tree_Lightmap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_AlbedoIntensity("Albedo Intensity", Range(1.0, 1.5)) = 1.0
		_AmbientIntensity("Ambient Intensity", Range(0.0, 1.0)) = 0.0
		_BackIntensity("Back Intensity", Range(0, 2)) = 0
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
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _AlbedoIntensity;
			float _AmbientIntensity;
			float _BackIntensity;
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
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normalDir : TEXCOORD1;
				float4 posWorld : TEXCOORD2;
				#if defined(LIGHTMAP_ON)
					float2 lightmapUV : TEXCOORD3;
				#endif
			};

			fixed3 TreeWind(float4 rangeCol, float length, float speed, float4 direction, float level, float range)
			{
				fixed3 wind = (sin(((rangeCol.rgb * length) + (_Time.g * speed))) * direction.rgb * level * (rangeCol.rgb * range));
				return wind;
			}
			
			v2f vert (appdata v)
			{
				v2f o;

				#ifdef LIGHTMAP_ON
					o.lightmapUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				float4 rangeCol = tex2Dlod(_RangeTex, float4(TRANSFORM_TEX(v.uv, _RangeTex), 0.0, 0));
				fixed3 windv = TreeWind(rangeCol, _Length, _Speed, _Direction, _Level, _Range);
				v.vertex.xyz += windv;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 albedo = col * _Color * _AlbedoIntensity;

				clip(albedo.a - _Cutoff);

				i.normalDir = normalize(i.normalDir);
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				fixed3 normalDirection = i.normalDir;

				fixed3 lightMapColor = fixed3(0.0, 0.0, 0.0);
				#ifdef LIGHTMAP_ON
					lightMapColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
				#endif

				float VdotL = dot(normalDirection, viewDirection);
				fixed3 backFactor = sign(min(0.0, VdotL)) * -_BackIntensity + sign(max(0.0, VdotL));

				fixed3 ambient = (lightMapColor + _AmbientIntensity) * backFactor;

				fixed4 finalColor = fixed4(ambient, 1) * albedo;

				return finalColor;
			}
			ENDCG
		}
	}
}
