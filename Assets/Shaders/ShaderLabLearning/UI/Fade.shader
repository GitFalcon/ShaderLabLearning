Shader "Learning/UI/Fade"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Main Color", Color) = (1, 1, 1, 1)
        [Header(Fade)]
        [KeywordEnum(All, R, G, B, A)] _Apply_Channel("Apply Color Channel", float) = 4
        [KeywordEnum(All, R, G, B, A)] _Use_Channel("Use Color Channel", float) = 4
        [NoScaleOffset]_FadeTex("Fade Texture", 2D) = "white" {}

        [Header(Fade Factor)]
        _FlatLeft("Flat Left", range(0, 1)) = 1
        _FlatTop("Flat Top", range(0, 1)) = 0
        _FlatRight("Flat Right", range(0, 1)) = 0
        _FlatBottom("Flat Bottom", range(0, 1)) = 0
        _FlatX("Flat X", range(0.01, 1)) = 1
        _FlatY("Flat Y", range(0.01, 1)) = 1
        _FadeScale("Fade Scale", range(0, 1)) = 1
        
        [Header(Stencil)]
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        [Header(Mask)]
        _ColorMask ("Color Mask", Float) = 15
    }
    CGINCLUDE
    ENDCG
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent" 
        }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _APPLY_CHANNEL_ALL _APPLY_CHANNEL_R _APPLY_CHANNEL_G _APPLY_CHANNEL_B _APPLY_CHANNEL_A
            #pragma multi_compile _USE_CHANNEL_ALL _USE_CHANNEL_R _USE_CHANNEL_G _USE_CHANNEL_B _USE_CHANNEL_A

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            uniform sampler2D _MainTex;
            uniform fixed4 _MainTex_ST;
            uniform fixed4 _Color;
            uniform sampler2D _FadeTex;
            uniform fixed _FlatLeft;
            uniform fixed _FlatTop;
            uniform fixed _FlatRight;
            uniform fixed _FlatBottom;
            uniform fixed _FlatX;
            uniform fixed _FlatY;
            uniform fixed _FadeScale;

            struct appdata
            {
            	float4 vertex : POSITION;
            	float4 color    : COLOR;
            	float2 uv : TEXCOORD0;
            };

            struct v2f
            {
            	float4 vertex : SV_POSITION;
            	fixed4 color    : COLOR;
            	float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
            	v2f o;
            	o.vertex = UnityObjectToClipPos(v.vertex);
            	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.color = v.color * _Color;
            	return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
            	fixed4 col = tex2D(_MainTex, i.uv.xy) * i.color;
            	i.uv.xy *= fixed2(_FlatX, _FlatY);
            	fixed4 fade = tex2D(_FadeTex, max(max(i.uv.x * _FlatLeft
            										, i.uv.y  * _FlatTop)
            									, max((1 - i.uv.x)*  _FlatRight
            										, (1 - i.uv.y) * _FlatBottom)));
            	fade = lerp(1, fade, _FadeScale);
            	#if _USE_CHANNEL_ALL
            		#if _APPLY_CHANNEL_ALL
            			#define FADE_CHANNEL fade
            		#elif _APPLY_CHANNEL_R
            			#define FADE_CHANNEL fade.r
            		#elif _APPLY_CHANNEL_G
            			#define FADE_CHANNEL fade.g
            		#elif _APPLY_CHANNEL_B
            			#define FADE_CHANNEL fade.b
            		#elif _APPLY_CHANNEL_A
            			#define FADE_CHANNEL fade.a
            		#endif
            	#elif _USE_CHANNEL_R
            		#define FADE_CHANNEL fade.r
            	#elif _USE_CHANNEL_G
            		#define FADE_CHANNEL fade.g
            	#elif _USE_CHANNEL_B
            		#define FADE_CHANNEL fade.b
            	#elif _USE_CHANNEL_A
            		#define FADE_CHANNEL fade.a
            	#endif
            	#if _APPLY_CHANNEL_ALL
            		#define TARGET_CHANNEL col
            	#elif _APPLY_CHANNEL_R
            		#define TARGET_CHANNEL col.r
            	#elif _APPLY_CHANNEL_G
            		#define TARGET_CHANNEL col.g
            	#elif _APPLY_CHANNEL_B
            		#define TARGET_CHANNEL col.b
            	#elif _APPLY_CHANNEL_A
            		#define TARGET_CHANNEL col.a
            	#endif
            	TARGET_CHANNEL *= FADE_CHANNEL;
            	return col;
            }

            ENDCG
        }
    }
}
