//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/composite2.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Pipeline Constants//

//Common Variables//

vec2 view = vec2(viewWidth, viewHeight);

//Common Functions//
#ifdef SS_BLOCKLIGHT
    #include "/lib/misc/reprojection.glsl"

    float GetLinearDepth(float depth) {
        return (2.0 * near) / (far + near - depth * (far - near));
    }

    vec2 OffsetDist(float x) {
        float n = fract(x * 16.2) * 2 * pi;
        return vec2(cos(n), sin(n)) * x;
    }

    vec4 GetMultiColoredBlocklight(vec3 lightAlbedo, vec2 coord, float z, float dither) {
        vec3 cameraOffset = cameraPosition - previousCameraPosition;
        cameraOffset *= float(z * 2.0 - 1.0 > 0.56);

        vec2 prevCoord = Reprojection(vec3(coord, z), cameraOffset);
        float lz = GetLinearDepth(z);

        float distScale = clamp((far - near) * lz + near, 4.0, 128.0);
        float fovScale = gbufferProjection[1][1] / 1.37373871;

        vec2 blurstr = vec2(1.0 / (viewWidth / viewHeight), 1.0) * fovScale / distScale;
        float mask = clamp01(2.0 - 2.0 * max(abs(prevCoord.x - 0.5), abs(prevCoord.y - 0.5)));

        vec2 offset = OffsetDist(dither) * blurstr;

        vec4 historySample = texture2D(colortex10, prevCoord.xy + offset);

        // 16 blocks is about the reach of a light
        float sampleWeight = clamp01(abs(lz * far - historySample.a) / 16.0);
        sampleWeight = 1.0 - sampleWeight * sampleWeight;

        vec3 previousColoredLight = historySample.rgb * sampleWeight;
        previousColoredLight *= previousColoredLight * mask;
        lightAlbedo = clamp01(lightAlbedo);
        if (lightAlbedo.g + lightAlbedo.b < 0.05) lightAlbedo.r *= 0.45; // red color reduction to prevent redstone from overpowering everything

        // make consistent via frameTime so fps don't matter
        float frameScale = clamp(frameTime * 120.0, 0.05, 8.0);
        float lightBlendRate = 1.0 - pow(0.99, frameScale);

        vec3 newColoredLight = sqrt(max(vec3(0.0), mix(previousColoredLight, lightAlbedo * lightAlbedo / clamp(previousColoredLight.r + previousColoredLight.g + previousColoredLight.b, 0.01, 1.0), lightBlendRate)));

        // Kill faint tails so they stop lingering
        newColoredLight *= pow(smoothstep(0.003, 0.012, newColoredLight.r + newColoredLight.g + newColoredLight.b), frameScale);
        return vec4(newColoredLight, lz * far);
    }
#endif


//Includes//

//Program//
void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;

    #if defined SS_BLOCKLIGHT
        float z0 = texelFetch(depthtex0, texelCoord, 0).r;
        float z = texture2D(depthtex1, texCoord).x;
        float dither;
    #endif

    // SS_BLOCKLIGHT code
    #ifdef SS_BLOCKLIGHT
        vec3 lightAlbedo = texture2D(colortex9, texCoord).rgb;
        // length is emission, prevent weaker emission from affecting MCBL too much
        lightAlbedo *= smoothstep(0.1, 0.3, length(lightAlbedo));

        dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
        #ifdef TAA
            dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
        #endif

        float lightZ = z >= 1.0 ? z0 : z;
        vec4 coloredLight = GetMultiColoredBlocklight(lightAlbedo, texCoord, lightZ, dither);
    #endif

    #ifdef SS_BLOCKLIGHT
        /* RENDERTARGETS: 0,10 */
        gl_FragData[0] = vec4(color, 1.0);
        gl_FragData[1] = coloredLight;
    #else
        /* DRAWBUFFERS:0 */
        gl_FragData[0] = vec4(color, 1.0);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER
noperspective out vec2 texCoord;

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
