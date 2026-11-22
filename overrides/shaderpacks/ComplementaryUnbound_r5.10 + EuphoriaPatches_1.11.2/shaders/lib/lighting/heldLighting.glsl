float getHeldLightFlicker() {
    vec2 flickerNoiseHand = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;
    float flickerMix = mix(1.0, min1(max(flickerNoiseHand.r, flickerNoiseHand.g) * 1.7), pow2(HAND_BLOCKLIGHT_FLICKERING * 0.1));

    return flickerMix;
}

void getHeldLight(out float heldLight, out float heldLight2) {
    heldLight = heldBlockLightValue;
    heldLight2 = heldBlockLightValue2;

    #ifndef IS_IRIS
        if (heldLight > 15.1) heldLight = 0.0;
        if (heldLight2 > 15.1) heldLight2 = 0.0;
    #endif

    #if COLORED_LIGHTING_INTERNAL == 0
        if (heldItemId == 44013) heldLight = 15; if (heldItemId2 == 44013) heldLight2 = 15; // Lava Bucket
    #endif
}

vec3 GetHeldLighting(vec3 playerPos, vec3 color, inout float emission, vec3 worldGeoNormal, vec3 normalM, vec3 viewPos) {
    float heldLight = 0; float heldLight2 = 0;
    getHeldLight(heldLight, heldLight2);

    #if COLORED_LIGHTING_INTERNAL == 0
        vec3 heldLightCol = blocklightCol; vec3 heldLightCol2 = blocklightCol;
    #else
        vec4 specialHeldLightCol = GetSpecialBlocklightColor(heldItemId - 44000);
        vec4 specialHeldLightCol2 = GetSpecialBlocklightColor(heldItemId2 - 44000);

        vec3 heldLightCol = specialHeldLightCol.rgb;
        vec3 heldLightCol2 = specialHeldLightCol2.rgb;

        // Make work with SITUATIONAL_ORES
        float heldOreFactor = 1.0, heldOreFactor2 = 1.0;
        #ifdef SITUATIONAL_ORES
            float heldSkyLightCheck = pow2(1.0 - min1(eyeBrightnessM * 2.9 * sunVisibility));
            int heldOreId = heldItemId - 44000, heldOreId2 = heldItemId2 - 44000;
            if (heldOreId == 32 || uint(heldOreId - 43) <= 9u || uint(heldOreId - 192) <= 2u) heldOreFactor = heldSkyLightCheck;
            if (heldOreId2 == 32 || uint(heldOreId2 - 43) <= 9u || uint(heldOreId2 - 192) <= 2u) heldOreFactor2 = heldSkyLightCheck;
        #endif

        if (specialHeldLightCol.a > 0.0) heldLight = min(15.0, heldLight + 15.0 * sqrt3(max(specialHeldLightCol.a, 0.1)) * heldOreFactor);
        if (specialHeldLightCol2.a > 0.0) heldLight2 = min(15.0, heldLight2 + 15.0 * sqrt3(max(specialHeldLightCol2.a, 0.1)) * heldOreFactor2);

        #if COLORED_LIGHT_SATURATION != 100
            heldLightCol = mix(blocklightCol, heldLightCol, COLORED_LIGHT_SATURATION * 0.01);
            heldLightCol2 = mix(blocklightCol, heldLightCol2, COLORED_LIGHT_SATURATION * 0.01);
        #endif

        // Color Balance / consistencyCB72412HF
        heldLightCol = 0.13 * DoLuminanceCorrection(heldLightCol + blocklightCol * 0.05);
        heldLightCol2 = 0.13 * DoLuminanceCorrection(heldLightCol2 + blocklightCol * 0.05);
    #endif

    vec3 playerPosLightM = playerPos + relativeEyePosition;
    playerPosLightM.y += 0.7;
    float lViewPosL = length(playerPosLightM) * 1.33;

    bool noHeldLight = heldLight == 0 && heldLight2 == 0;

    heldLight = GetTweakedSmoothLightmap(max0(heldLight - lViewPosL) * 0.065);
    heldLight2 = GetTweakedSmoothLightmap(max0(heldLight2 - lViewPosL) * 0.065);

    #ifdef SPACEAGLE17
        if (noHeldLight && !bool(firstPersonCamera) && entityId != 50017 && !bool(is_invisible) && currentPlayerArmor < 0.4 && bool(isOnGround)) {
            // Keeps its own pre-merge falloff, the new one is tuned for real held lights
            float powVal = 1.0 + 1.0 * (cos(frameTimeCounter * 1.5) * 0.5 + 0.5);
            float anim = 2.8 * max(pow(0.8, powVal), 0.12);
            playerPosLightM.y += 0.8;
            float lViewPosGlow = sqrt2((length(playerPosLightM) + 6.0) * 0.35) * 1.2;

            heldLight = pow2(pow2(anim * 0.47 / lViewPosGlow));
            heldLight2 = heldLight;
            heldLightCol = DoLuminanceCorrection(vec3(0.2392, 0.8235, 0.8667));
            heldLightCol2 = heldLightCol;
        }
    #endif

    #ifdef DIRECTIONAL_LIGHTMAP_NORMALS
        vec3 cameraHeldLightPos = (gbufferModelView * vec4(-relativeEyePosition, 1.0)).xyz;
        cameraHeldLightPos.x += 0.66 * (float(heldLight > 0) - float(heldLight2 > 0)); // Held light position offset

        float dirHandLightmap = clamp01(dot(normalize(cameraHeldLightPos - viewPos), normalM));
        float dirHandLightmapMaxInfluence = DIRECTIONAL_LIGHTMAP_NORMALS_HANDHELD_STRENGTH * 0.25;

        dirHandLightmap = 2.0 * dirHandLightmap * dirHandLightmapMaxInfluence - dirHandLightmapMaxInfluence;
        dirHandLightmap = 1.0 + dirHandLightmap;

        dirHandLightmap = pow2(pow2(dirHandLightmap));
        heldLight *= dirHandLightmap;
        heldLight2 *= dirHandLightmap;
    #endif

    vec3 heldLighting = pow2(heldLight * heldLightCol) + pow2(heldLight2 * heldLightCol2);

    #if HELD_LIGHTING_MODE == 1 // Subtle
        heldLighting *= 0.065;
    #endif

    #ifdef GBUFFERS_ENTITIES
        if (entityId == 50016 || entityId == 50017) { // Player or Current Player
            heldLighting *= 0.65;
        }
    #endif

    #if COLORED_LIGHTING_INTERNAL > 0
        AddSpecialLightDetail(heldLighting, color.rgb, emission);
    #endif

    #if HAND_BLOCKLIGHT_FLICKERING > 0
        heldLighting *= getHeldLightFlicker();
    #endif

    return heldLighting;
}
