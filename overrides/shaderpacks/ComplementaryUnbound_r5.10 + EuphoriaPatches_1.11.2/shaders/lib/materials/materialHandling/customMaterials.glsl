#ifdef POM
    #include "/lib/materials/materialMethods/pomEffects.glsl"
#endif

#include "/lib/materials/materialMethods/customEmission.glsl"

#ifdef BETTER_LABPBR_POROSITY_INTERNAL
    void ApplyLabPBRPorosity(inout vec4 color, inout float smoothnessG, inout float smoothnessD, inout float materialMask, float porosity) {
        // Same as gbuffers_terrain puddleMixer
        float skyExposure = max0(lmCoord.y * 32.0 - 31.0) * clamp((1.0 - 1.15 * lmCoord.x) * 10.0, 0.0, 1.0);
        float wetness = skyExposure * inRainy * wetnessDynamic;

        if (wetness <= 0.0 || porosity <= 0.0) return;

        float puddleSmoothness = sqrt(1.0 - 0.75 * porosity);
        float puddleDarkening = 0.5 * porosity + 0.17;

        smoothnessG = mix(smoothnessG, 1.0, wetness * puddleSmoothness);
        smoothnessD = mix(smoothnessD, 1.0, wetness * puddleSmoothness);
        materialMask = max(materialMask, wetness * 0.02 * OSIEBCA * 214.0); // Minimum reflectivity as water f0
        color.rgb *= 1.0 - wetness * puddleDarkening;
    }
#endif

#ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
    float GetPomPuddleLevel() {
        float puddleMixer = GetPuddleLightFactor(lmCoord) * inRainy * pow2(max0(geoNdotU - 0.5) * 2.0);
        float noPuddles = 0.0;
        #ifdef PUDDLE_VOXELIZATION
            noPuddles = GetPuddleVoxelBlock(vertexPos);
        #endif
        if (pow2(pow2(wetnessDynamic)) * puddleMixer - noPuddles <= 0.00001) return 0.0;

        // The height up to where the puddle fills the POM
        return 0.965 * sqrt(sqrt(puddleMixer * wetnessDynamic));
    }
#endif

void GetCustomMaterials(inout vec4 color, inout vec3 normalM, inout vec2 lmCoordM, inout float NdotU, inout vec3 shadowMult, inout float smoothnessG, inout float smoothnessD, inout float highlightMult, inout float emission, inout float materialMask, inout float materialAO, vec3 viewPos, float lViewPos) {
    vec2 texCoordM = texCoord;

    #ifdef POM
        float parallaxFade, parallaxTexDepth;
        vec2 parallaxLocalCoord;
        vec3 parallaxTraceCoordDepth;
        vec4 normalMap;
        bool skipPom = false;

        #ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
            vec2 pomPuddlePos = GetPuddlePos(vertexPos.xz + cameraPosition.xz);
            float pomPuddleLevel = GetPomPuddleLevel(), pomPuddle = 0.0;
        #else
            float pomPuddleLevel = 0.0;
        #endif

        #ifdef GBUFFERS_ENTITIES
            if (entityId == 50128 || entityId == 50132) skipPom = true; // Item Frame, Glow Item Frame
        #endif
        #ifdef GBUFFERS_BLOCK
            if (blockEntityId == 5004) skipPom = true; // Signs
        #endif
        #ifdef GBUFFERS_HAND
            if (heldItemId == 40004 || heldItemId2 == 40004) skipPom = true; // Filled Map
        #endif

        if (!skipPom) {
            texCoordM = vTexCoord.xy * vTexCoordAM.zw + vTexCoordAM.xy;

            parallaxFade = pow2(lViewPos / POM_DISTANCE);
            parallaxTraceCoordDepth = vec3(texCoordM, 1.0);
            parallaxLocalCoord = vTexCoord.st;

            normalMap = ReadNormal(vTexCoord.st);
            parallaxFade += pow(normalMap.a, 64.0);

            if (parallaxFade < 1.0) {
                float dither = Bayer64(gl_FragCoord.xy);
                #ifdef TAA
                    dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
                #endif

                parallaxLocalCoord = GetParallaxCoord(parallaxFade, dither, pomPuddleLevel, texCoordM, parallaxTexDepth, parallaxTraceCoordDepth);

                normalMap = textureGrad(normals, texCoordM, dcdx, dcdy);
                color = textureGrad(tex, texCoordM, dcdx, dcdy);
                #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_BLOCK
                    color.rgb *= glColor.rgb;
                #else
                    color *= glColor;
                #endif

                shadowMult *= GetParallaxShadow(parallaxFade, dither, max(normalMap.a, pomPuddleLevel), parallaxLocalCoord, lightVec, tbnMatrix);
            }

            #ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
                pomPuddle = clamp01((pomPuddleLevel - normalMap.a) * 100.0);
            #endif
        }
    #endif

    // Normal Map
    #if NORMAL_MAP_STRENGTH != 0
        #ifdef POM
            else normalMap = texture2D(normals, texCoordM);
        #else
            vec4 normalMap = texture2D(normals, texCoordM);
        #endif

        materialAO = normalMap.b;
        normalM = normalMap.xyz;
        normalM += vec3(0.5, 0.5, 0.0);
        normalM = pow(normalM, vec3(NORMAL_MAP_STRENGTH * 0.007)); // 70% strength by default
        normalM -= vec3(0.5, 0.5, 0.0);
        normalM = normalM * 2.0 - 1.0;

        #if RP_MODE == 3 // labPBR
            if (normalM.x + normalM.y > -1.999) {
                if (length(normalM.xy) > 1.0) normalM.xy = normalize(normalM.xy);
                normalM.z = sqrt(1.0 - dot(normalM.xy, normalM.xy));
                normalM.xyz = normalize(clamp(normalM.xyz, vec3(-1.0), vec3(1.0)));
            } else normalM = vec3(0.0, 0.0, 1.0);
        #endif

        #if defined POM && POM_QUALITY >= 128 && POM_LIGHTING_MODE == 2
            if (!skipPom) {
                float slopeThreshold = max(1.0 / POM_QUALITY, 1.0/255.0);
                if (parallaxTexDepth - parallaxTraceCoordDepth.z > slopeThreshold) {
                    vec3 slopeNormal = GetParallaxSlopeNormal(parallaxLocalCoord, parallaxTraceCoordDepth.z, viewVector);
                    normalM = mix(normalM, slopeNormal, 0.5 * pow2(max0(1.0 - parallaxFade * 2.0)));
                }
            }
        #endif

        normalM = clamp(normalize(normalM * tbnMatrix), vec3(-1.0), vec3(1.0));

        NdotU = dot(normalM, upVec);
        NdotUmax0 = max0(NdotU);
    #endif

    #ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
        if (pomPuddle > 0.0) {
            normalM = normalize(mix(normalM, GetPuddleNormal(pomPuddlePos), pomPuddle));
            NdotU = dot(normalM, upVec);
            NdotUmax0 = max0(NdotU);
        }
    #endif

    #if DIRECTIONAL_BLOCKLIGHT > 0
        mat3 lightmapTBN = mat3(normalize(dFdx(viewPos)), normalize(dFdy(viewPos)), vec3(0.0));
        lightmapTBN[2] = cross(lightmapTBN[0], lightmapTBN[1]);

        float lmCoordXDir = lmCoordM.x;
        vec2 deriv = vec2(dFdx(lmCoordXDir), dFdy(lmCoordXDir)) * 256.0;
        vec3 dir = normalize(vec3(deriv.x * lightmapTBN[0] +
                                0.0005  * lightmapTBN[2] +
                                deriv.y * lightmapTBN[1]));

        float pwr = clamp(dot(normalM, dir), -1.0, 1.0);
        float absPwr = abs(pwr);
        if (absPwr > 0.0) pwr = pow(absPwr, 9.0 / DIRECTIONAL_BLOCKLIGHT) * sign(pwr) * lmCoordXDir;
        if (length(deriv) > 0.001) lmCoordXDir = pow(max(lmCoordXDir, 0.00001), 1.0 - pwr);

        lmCoordM.x = mix(lmCoordM.x, lmCoordXDir, 0.01 * max0(100.0 - pow2(lViewPos)));
    #endif

    // Specular Map
    vec4 specularMap = texture2D(specular, texCoordM);

    #ifdef BETTER_LABPBR_REFLECTIONS_INTERNAL
        float smoothnessM = specularMap.r; // ImprPBRPow2 - Don't square it here, we want the raw smoothness value
    #else
        float smoothnessM = pow2(specularMap.r);
    #endif
    smoothnessG = smoothnessM;
    smoothnessD = smoothnessM;
    highlightMult = 1.0 + 2.5 * specularMap.r;

    #if RP_MODE == 3 // labPBR
        highlightMult *= 0.5 + 0.5 * specularMap.g;
    #endif

    emission = GetCustomEmission(specularMap, texCoordM);

    #ifndef GBUFFERS_WATER
        #if defined GBUFFERS_ENTITIES || defined GBUFFERS_HAND
            if (
                materialMask > OSIEBCA * 240.1
                && specularMap.g < 0.01
            ) return;
        #endif

        #if RP_MODE == 2 // seuspbr
            materialMask = specularMap.g * OSIEBCA * 240.0;
        #elif RP_MODE == 3 // labPBR
            if (specularMap.g < OSIEBCA * 229.1) {
                materialMask = specularMap.g * OSIEBCA * 214.0;
            } else {
                materialMask = specularMap.g - OSIEBCA * 15.0;
            }
        #endif

        #ifdef BETTER_LABPBR_POROSITY_INTERNAL
            // Blue channel: 0-64 = porosity
            float porosity = specularMap.b <= 64.0 * OSIEBCA ? specularMap.b * (255.0 / 64.0) : 0.0;
            #ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
                float pomWetBand = 1.0 - pomPuddleLevel;
                float pomWet = pomPuddleLevel > 0.0 ? clamp01((pomPuddleLevel + pomWetBand - normalMap.a) / pomWetBand) : 0.0;
                porosity = mix(porosity, max(porosity, 0.4), pomWet); // Hardcoded fallback for those packs that don't have porosity, but do have POM
            #endif
            ApplyLabPBRPorosity(color, smoothnessG, smoothnessD, materialMask, porosity);
        #endif

        #ifdef BETTER_LABPBR_POM_PUDDLES_ACTIVE
            ApplyPuddleSpecular(smoothnessG, smoothnessD, highlightMult, pomPuddle, 0);
            materialMask = mix(materialMask, 0.02 * OSIEBCA * 214.0, pomPuddle); // Water f0
        #endif
    #endif

    #ifdef BETTER_LABPBR_SSS_ACTIVE
        // Blue channel: 65-255 = subsurface scattering
        labPBRSubsurface = clamp01((specularMap.b - 65.0 * OSIEBCA) / (190.0 * OSIEBCA));
        #ifdef GBUFFERS_WATER
            if (mat == 32000) labPBRSubsurface = 0.0; // water
        #endif
    #endif
}
