//###### Frag Shader
Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

cbuffer gm_PSMaterialConstantBuffer
{
    bool   gm_PS_FogEnabled;
    float4 gm_FogColour;
    bool   gm_AlphaTestEnabled;
    float4 gm_AlphaRefValue;
};

struct Fragment
{
    float4 vPosition : SV_POSITION;
    float4 vColor    : COLOR0;
    float2 vCoord    : TEXCOORD0;
};

#define MAX_UVS 10
uniform float4 UVS[MAX_UVS];
uniform int NUM_UVS;

float4 main(Fragment INPUT) : SV_Target0 {
    float2 textureDimensions;
    gm_BaseTextureObject.GetDimensions(textureDimensions.x, textureDimensions.y);

    float2 pixel = INPUT.vCoord * textureDimensions;

    float radius = 200.0f;
    float3 purple = float3(0.6f, 0.2f, 0.8f);

    float3 colorAccum = float3(0.0, 0.0, 0.0);
    for (int i = 0; i < NUM_UVS; i++){
        float2 offset = pixel - UVS[i].xy;
        float dist = length(offset);

        float localMask = saturate((radius - dist) / radius);

        localMask = smoothstep(0.0, 1.0, localMask);
        localMask = pow(localMask, 3.0);
        pixel += offset * localMask * (-UVS[i].z / 15);
        colorAccum += purple * localMask * UVS[i].z / 60.0f;
    }

    float2 warpedUV = pixel / textureDimensions;
    float4 baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, warpedUV);

    baseColor.rgb += colorAccum;

    return baseColor;
}