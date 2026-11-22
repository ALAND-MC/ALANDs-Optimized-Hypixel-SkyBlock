#ifndef INCLUDE_LIGHT_AND_AMBIENT_COLORS
    #define INCLUDE_LIGHT_AND_AMBIENT_COLORS

    #include "/lib/shaderSettings/endBeams.glsl"
    #include "/lib/shaderSettings/lightAndAmbientColors.glsl"
    #include "/lib/shaderSettings/overworldBeams.glsl"

    #if defined OVERWORLD
        #ifdef DIMENSION_SPACE_AIRLESS
            vec3 noonClearLightColor     = vec3(1.15);
            vec3 noonClearAmbientColor   = vec3(0.07, 0.075, 0.09);
            vec3 sunsetClearLightColor   = noonClearLightColor;
            vec3 sunsetClearAmbientColor = noonClearAmbientColor;
            vec3 nightClearLightColor    = vec3(0.14, 0.14, 0.16) * 0.5 * (0.4 + vsBrightness * 0.4);
            vec3 nightClearAmbientColor  = vec3(0.11, 0.12, 0.15) * 0.35 * (1.55 + vsBrightness * 0.77); // Only a bit brighter than daytime shadows
        #elif defined DIMENSION_CAVE_VOID
            // No sun here, so the same dim light day and night, tinted by the fog color
            vec3 caveVoidTint = mix(vec3(1.0), fogColor / max(max(fogColor.r, max(fogColor.g, fogColor.b)), 0.001), 0.5);
            vec3 noonClearLightColor     = 0.15 * caveVoidTint;
            vec3 noonClearAmbientColor   = 0.2 * caveVoidTint * (0.8 + vsBrightness * 0.4);
            vec3 sunsetClearLightColor   = noonClearLightColor;
            vec3 sunsetClearAmbientColor = noonClearAmbientColor;
            vec3 nightClearLightColor    = noonClearLightColor;
            vec3 nightClearAmbientColor  = noonClearAmbientColor;
        #else
            #ifndef COMPOSITE1
                vec3 noonClearLightColor = vec3(0.65, 0.55, 0.375) * 2.05; //ground and cloud color
            #else
                vec3 noonClearLightColor = vec3(0.4, 0.75, 1.3); //light shaft color
            #endif
            #ifdef DIMENSION_SPACE_ATMOSPHERE
                vec3 noonClearAmbientColor = pow(skyColor, vec3(0.65)) * 0.75; // Softer than Earth's sky light
            #else
                vec3 noonClearAmbientColor = pow(skyColor, vec3(0.75)) * 0.85;
            #endif

            #ifndef COMPOSITE1
                vec3 sunsetClearLightColor = pow(vec3(0.64, 0.45, 0.3), vec3(1.5 + invNoonFactor)) * 5.0; //ground and cloud color
            #else
                vec3 sunsetClearLightColor = pow(vec3(0.62, 0.39, 0.24), vec3(1.5 + invNoonFactor)) * 6.8; //light shaft color
            #endif
            #ifdef MODDED_MARS_SUNSET
                vec3 sunsetClearAmbientColor   = mix(noonClearAmbientColor, vec3(GetLuminance(noonClearAmbientColor)), MARS_SUNSET_DESATURATION) * vec3(0.9, 0.97, 1.1) * 0.95; // Greyish instead of warm
            #else
                vec3 sunsetClearAmbientColor   = noonClearAmbientColor * vec3(1.21, 0.92, 0.76) * 0.95;
            #endif

            #if !defined COMPOSITE1 && !defined DEFERRED1
                #ifdef DIMENSION_SPACE_ATMOSPHERE
                    vec3 nightClearLightColor = 0.9 * vec3(0.155, 0.15, 0.145) * (0.4 + vsBrightness * 0.4); // Neutral instead of Earth blue
                #else
                    vec3 nightClearLightColor = 0.9 * vec3(0.15, 0.14, 0.20) * (0.4 + vsBrightness * 0.4); //ground color
                #endif
            #elif defined DEFERRED1
                vec3 nightClearLightColor = 0.9 * vec3(0.11, 0.14, 0.20); //cloud color
            #else
                vec3 nightClearLightColor = vec3(0.08, 0.12, 0.23); //light shaft color
            #endif
            #ifdef DIMENSION_SPACE_ATMOSPHERE
                vec3 nightClearAmbientColor = 0.9 * vec3(0.115, 0.11, 0.105) * (1.55 + vsBrightness * 0.77);
            #else
                vec3 nightClearAmbientColor = 0.9 * vec3(0.09, 0.12, 0.17) * (1.55 + vsBrightness * 0.77);
            #endif
        #endif

        #ifdef SPECIAL_BIOME_WEATHER
            vec3 drlcSnowM = inSnowy * vec3(-0.06, 0.0, 0.04);
            vec3 drlcDryM = inDry * vec3(0.01, -0.035, -0.06);
        #else
            vec3 drlcSnowM = vec3(0.0), drlcDryM = vec3(0.0);
        #endif
        #if RAIN_STYLE == 2
            vec3 drlcRainMP = vec3(-0.03, 0.0, 0.02);
            #ifdef SPECIAL_BIOME_WEATHER
                vec3 drlcRainM = inRainy * drlcRainMP;
            #else
                vec3 drlcRainM = drlcRainMP;
            #endif
        #else
            vec3 drlcRainM = vec3(0.0);
        #endif
        vec3 dayRainLightColor   = vec3(0.21, 0.16, 0.13) * 0.85 + noonFactor * vec3(0.0, 0.02, 0.06)
                                 + drlcRainM + drlcSnowM + drlcDryM;
        vec3 dayRainAmbientColor = vec3(0.2, 0.2, 0.25) * (1.8 + 0.5 * vsBrightness);

        vec3 nightRainLightColor   = vec3(0.03, 0.035, 0.05) * (0.5 + 0.5 * vsBrightness);
        vec3 nightRainAmbientColor = vec3(0.16, 0.20, 0.3) * (0.75 + 0.6 * vsBrightness);
        #ifndef COMPOSITE1
            float noonFactorDM = noonFactor; //ground and cloud factor
        #else
            float noonFactorDM = noonFactor * noonFactor; //light shaft factor
        #endif
        #ifdef DIMENSION_SPACE_ATMOSPHERE
            const float planetSunlightMult = 0.4;
            const float planetSunTintStrength = 1.0; // How strongly the warmth of the planet's sky and fog tints the sun
            vec3 planetAtmoColor = max(skyColor, fogColor);
            float planetWarmth = clamp((planetAtmoColor.r - planetAtmoColor.b) / max(planetAtmoColor.r + planetAtmoColor.b, 0.001), -1.0, 1.0) * planetSunTintStrength; // -1 cool to 1 warm
            vec3 planetSunTintRaw = vec3(1.0, 1.0 - 0.35 * planetWarmth, 1.0 - 0.7 * planetWarmth);
            vec3 planetSunTintDay = planetSunTintRaw / GetLuminance(planetSunTintRaw);
            #ifdef MODDED_MARS_SUNSET
                vec3 planetSunTint = mix(planetSunTintDay, MARS_SUNSET_SUN_COLOR / GetLuminance(MARS_SUNSET_SUN_COLOR), invNoonFactor2); // Blue sunlight at sunset
            #else
                vec3 planetSunTint = planetSunTintDay;
            #endif
            vec3 dayLightColor = GetLuminance(mix(sunsetClearLightColor, noonClearLightColor, noonFactorDM)) * planetSunTint * planetSunlightMult;
        #else
            vec3 dayLightColor = mix(sunsetClearLightColor, noonClearLightColor, noonFactorDM);
        #endif

        vec3 dayAmbientColor = mix(sunsetClearAmbientColor, noonClearAmbientColor, noonFactorDM);

        #ifdef DIMENSION_SPACE_AIRLESS
            float clearDayMix = clamp(sunVisibility * 4.0 - 1.5, 0.0, 1.0);
        #else
            float clearDayMix = sunVisibility2;
        #endif
        vec3 clearLightColor   = mix(nightClearLightColor, dayLightColor, clearDayMix);
        vec3 clearAmbientColor = mix(nightClearAmbientColor, dayAmbientColor, clearDayMix);

        float rainShadowVisReduce = 0.0
            #ifdef SUN_MOON_DURING_RAIN
                #ifdef SPECIAL_BIOME_WEATHER
                    + 0.2 * inSnowy + 0.2 * inDry
                #elif RAIN_STYLE == 2
                    + 0.2
                #endif
            #else
                + 0.4
            #endif
        ;

        vec3 rainLightColor   = mix(nightRainLightColor, dayRainLightColor * (1.0 - rainShadowVisReduce), sunVisibility2) * 2.5;
        vec3 rainAmbientColor = mix(nightRainAmbientColor, dayRainAmbientColor * (1.0 + rainShadowVisReduce), sunVisibility2);

        vec3 lightColor   = mix(clearLightColor, rainLightColor, rainFactor);
        #if SILHOUETTE == 0
            vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor);
        #elif SILHOUETTE == 1
            vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor) * mix(SILHOUETTE_BRIGHTNESS, 1.0, sunVisibility);
        #else
            vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor) * SILHOUETTE_BRIGHTNESS;
        #endif

        #ifdef OVERWORLD_BEAMS
            vec3 ambientColorBeam = sqrt(mix(clearAmbientColor, rainAmbientColor, rainFactor));
            vec3 ColorBeam = mix(vec3(OW_BEAM_R_NEW, OW_BEAM_G_NEW, OW_BEAM_B_NEW), ambientColorBeam, BEAMS_AMBIENT_INFLUENCE);
        #else
            vec3 ColorBeam = vec3(0.0);
        #endif
    #elif defined NETHER
        vec3 lightColor   = vec3(0.0);
        vec3 ambientColor = (netherColor + 0.5 * lavaLightColor) * (0.9 + 0.45 * vsBrightness);
    #elif defined END
        float endFogLumina = dot(fogColor, vec3(0.299, 0.587, 0.114));
        vec3 endLightTempC = vec3(0.68, 0.51, 1.07); // Ensure the clamp below does not cap the max number here off... 1 year with too little blue smh
        vec3 endLightColor = clamp(mix(endLightTempC, fogColor * 0.6 + 0.3 * normalize(fogColor + 0.0001) + (0.25 - 0.25 * endFogLumina), (1.0 - inVanillaEnd) * float(END_SKY_FOG_INFLUENCE)), 0.0, 1.5);
        vec3 endOrangeCol  = vec3(E_DRAGON_BEAM_R_NEW, E_DRAGON_BEAM_G_NEW, E_DRAGON_BEAM_B_NEW) * E_DRAGON_BEAM_I;
        float endLightBalancer = 0.2 * vsBrightness;
        vec3 lightColor    = endLightColor * (0.35 - endLightBalancer);
        vec3 ambientTempC  = endLightColor * (0.2 + endLightBalancer);
        vec3 ambientColor  = mix(ambientTempC, vec3(END_AMBIENT_R_NEW, END_AMBIENT_G_NEW, END_AMBIENT_B_NEW), END_AMBIENT_INFLUENCE) * END_AMBIENT_I;
        vec3 endColorBeam  = mix(vec3(E_BEAM_R_NEW, E_BEAM_G_NEW, E_BEAM_B_NEW), ambientTempC, E_BEAMS_AMBIENT_INFLUENCE);
        vec3 baseBeamPurple = normalize(endColorBeam * endColorBeam * endColorBeam) * E_BEAM_I;
    #endif

#endif //INCLUDE_LIGHT_AND_AMBIENT_COLORS
