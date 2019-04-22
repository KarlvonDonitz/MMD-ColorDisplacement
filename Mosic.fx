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

float Intensity : CONTROLOBJECT < string name = "(self)"; string item = "Si";>;
float Frequency : CONTROLOBJECT < string name = "(self)"; string item = "X";>;
float Speed : CONTROLOBJECT < string name = "(self)"; string item = "Y";>;
float Value1 : CONTROLOBJECT < string name = "(self)"; string item = "Rx";>;
float Value2 : CONTROLOBJECT < string name = "(self)"; string item = "Ry";>;
float Block : CONTROLOBJECT < string name = "(self)"; string item = "Tr";>;
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

float ClearDepth  = 1.0;


texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;


texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1,1};
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

float4 PS_ColorDispalcement( float2 Tex: TEXCOORD0 ) : COLOR {   
   float Color=1;
   float2 fTexSize=ViewportSize;
   float2 fMosicSize= float2(4,4);
   float2 fintXY=float2(Tex.x*fTexSize.x,Tex.y*fTexSize.y);
   float2 fXYmosic = float2(int(fintXY.x/fMosicSize.x)*fMosicSize.x,int(fintXY.y/fMosicSize.y)*fMosicSize.y)+0.5*fMosicSize;
   float2 fDelXY=fXYmosic-fintXY;
   float2 fUVMosic=float2(fXYmosic.x/fTexSize.x,fXYmosic.y/fTexSize.y);
   if( length(fDelXY) <0.5*fMosicSize.x)
     return tex2D(ScnSamp,fUVMosic);
    else return float4(0,0,0,0);	 
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
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ColorDispalcement();
    }
}
