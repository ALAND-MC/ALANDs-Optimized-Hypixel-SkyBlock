#include "/lib/shaderSettings/shockwave.glsl"

#if defined EUPHORIA_PATCHES_MACE_WAVE_STATE_UNIFORM && !defined VOXY_PATCH && MC_VERSION >= 12100
    #define MACE_WAVES
#endif

// SDF from https://iquilezles.org/articles/distfunctions2d/
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float getOffsetStrength(float animation, vec2 dir, float maxRadius) {
    #if SHOCKWAVE == 1
        float wave = sdCircle(dir, animation * maxRadius);
    #elif SHOCKWAVE == 2
        float wave = sdBox(dir, vec2(animation * maxRadius));
    #endif

    wave *= 1.0 - smoothstep(0.0, 0.2, abs(wave)); // Mask the ripple

    wave *= smoothstep(0.0, 0.2, animation); // Smooth intro
    wave *= 1.0 - smoothstep(0.5, 1.0, animation); // Smooth outro
    return wave * 0.05;
}

#ifdef MACE_WAVES
// One mace smash wave. blockPos is the block the hit entity stood on, progress -1 = no current wave
void addMaceWave(vec3 surfacePos, ivec3 blockPos, float progress, float strength,
                 inout vec2 rOffset, inout vec2 gOffset, inout vec2 bOffset, inout float shading) {
    if (progress < 0.0) return;

    // Exact camera relative impact position, the camera is a block position plus a fraction
    vec3 impact = vec3(blockPos - cameraPositionBestInt) + vec3(0.5, 1.0, 0.5) - cameraPositionBestFract;
    vec3 delta = surfacePos - impact;
    float maxRadius = mix(4.0, 6.0, strength);

    vec2 dir = delta.xz;
    if (max(abs(dir.x), abs(dir.y)) > maxRadius + 0.6) return;
    // Locked in y from the impact position to not creep up walls super high
    float heightMask = 1.0 - smoothstep(1.0, 3.5, abs(delta.y));
    if (heightMask <= 0.0) return;

    float animation = pow(clamp(progress, 0.0, 1.0), 1.0 / 1.2);
    float aberrationOffset = 0.05 * sin(animation * pi);
    float rWave = getOffsetStrength(animation + aberrationOffset, dir, maxRadius) * heightMask;
    float gWave = getOffsetStrength(animation, dir, maxRadius) * heightMask;
    float bWave = getOffsetStrength(animation - aberrationOffset, dir, maxRadius) * heightMask;

    dir /= max(length(dir), 0.0001);
    rOffset += dir * rWave;
    gOffset += dir * gWave;
    bOffset += dir * bWave;
    shading += gWave * 15.0; // use gWave as it has no chromatic aberration
}
#endif

vec4 doShockwave(vec3 playerPos, vec2 texCoord){ // Based on https://editor.p5js.org/BarneyCodes/sketches/ELbA93Ugb by BarneyCodes
    vec2 rOffset = vec2(0.0);
    vec2 gOffset = vec2(0.0);
    vec2 bOffset = vec2(0.0);
    float shading = 0.0;

    // Crouching shockwave, around the player
    #if defined SHOCKWAVE_CROUCHING || MC_VERSION < 12100 || !defined EUPHORIA_PATCHES_MACE_WAVE_STATE_UNIFORM
        float crouchingProgress = pow(isShockwave, 1.0 / 1.2);
        if (crouchingProgress > 0.01 && crouchingProgress < 1.0) {
            vec2 centre = playerPos.xz + 0.4;
            vec2 dir = centre - texCoord;
            float maxRadius = 4.0;

            // Chromatic aberration
            float aberrationOffset = 0.05 * sin(crouchingProgress * pi);
            float rWave = getOffsetStrength(crouchingProgress + aberrationOffset, dir / aspectRatio, maxRadius);
            float gWave = getOffsetStrength(crouchingProgress, dir / aspectRatio, maxRadius);
            float bWave = getOffsetStrength(crouchingProgress - aberrationOffset, dir / aspectRatio, maxRadius);

            dir = normalize(dir);
            rOffset += dir * rWave;
            gOffset += dir * gWave;
            bOffset += dir * bWave;
            shading += gWave * 15.0;
        }
    #endif

    // Mace smash waves, at the impact positions. State = -1 when no wave is active
    #ifdef MACE_WAVES
        if (euphoriaPatchesMaceWaveState.x >= 0.0 || euphoriaPatchesMaceWaveState.z >= 0.0) {
            // Original callers add relativeEyePosition, undo it to get the position relative to the camera
            vec3 surfacePos = playerPos - relativeEyePosition;
            addMaceWave(surfacePos, euphoriaPatchesMaceWavePos0.xyz, euphoriaPatchesMaceWaveState.x, euphoriaPatchesMaceWaveState.y,
                        rOffset, gOffset, bOffset, shading);
            addMaceWave(surfacePos, euphoriaPatchesMaceWavePos1.xyz, euphoriaPatchesMaceWaveState.z, euphoriaPatchesMaceWaveState.w,
                        rOffset, gOffset, bOffset, shading);
        }
    #endif

    float waveFactor = max(length(rOffset), max(length(gOffset), length(bOffset))) * 100.0;

    // Nothing is rippling here, which is almost always
    if (waveFactor <= 0.0001) {
        #if ANISOTROPIC_FILTER != 0 && defined GBUFFERS_TERRAIN
            return textureAF(tex, texCoord);
        #else
            return texture2D(tex, texCoord);
        #endif
    }

    float value = 1.0;
    #if defined GBUFFERS_TERRAIN || defined GBUFFERS_WATER
        float blockRes = absMidCoordPos.x * atlasSize.x;
        vec2 signMidCoordPosM = abs((floor((signMidCoordPos + 1.0) * blockRes) + 0.5) / blockRes - 1.0);
        value = 1.0 - max(signMidCoordPosM.x, signMidCoordPosM.y); // Prevent from distorting into a different atlas texture
    #endif

    float r = texture2D(tex, texCoord + rOffset * value).r;
    float g = texture2D(tex, texCoord + gOffset * value).g;
    float b = texture2D(tex, texCoord + bOffset * value).b;
    float a = texture2D(tex, texCoord).a; // Use the non AF method during the wave

    vec4 shockwaveColor = vec4(r, g, b, a);
    shockwaveColor.rgb += shading * 1.5;
    // shockwaveColor += vec4(3,0,0,1); // Debugging
    return shockwaveColor;
}
