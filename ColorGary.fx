//edit by KarlVonDonitz
float Extent
<
   string UIName = "Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.007 );

float4 ClearColor
<
   string UIName = "ClearColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4(0,0,0,0);

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float time :TIME;
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;

float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;


float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 SampStep = (float2(Extent,Extent)/ViewportSize*ViewportSize.y) * scaling;


float ClearDepth  = 1.0;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;


texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
  
	VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

float4 PS_ColorShift( float2 Tex: TEXCOORD0 ) : COLOR {   
  if (sin(Tex.y) < 0.1) {
     Tex.x +=0.05/scaling0;
	 } else {
	  if (sin(Tex.y) <0.2) {
	  Tex.x -=0.05/scaling0;
	  } else {
	    if (sin(Tex.y) <0.3) {
		Tex.x +=0.05/scaling0;
		} else {
		   if (sin(Tex.y) <0.4) {
		   Tex.x -=0.05/scaling0;
		   } else {
		    if (sin(Tex.y) <0.5) {
			Tex.x +=0.05/scaling0;
			} else {
			   if (sin(Tex.y) <0.6) {
			   Tex.x -=0.05/scaling0;
			   } else {
			      if (sin(Tex.y) <0.7) {
			      Tex.x +=0.05/scaling0;
				  } else {
				     if (sin(Tex.y) <0.8) {
					   Tex.x -=0.05/scaling0;
					   } else {
				         if (sin(Tex.y) <0.9) {
						 Tex.x +=0.05/scaling0;
						 } else {
						  Tex.x -=0.05/scaling0;
						 }
					  }
				  }
			   }
			}
		}
	  }
  }
  }
    return tex2D(ScnSamp,Tex);
}


technique ColorShift <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=ColorShiftPass;"
    ;
    
> {
    pass ColorShiftPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_ColorShift();
    }
}
