#ifndef INCLUDE_CAVE_FACTOR
#define INCLUDE_CAVE_FACTOR
    #define CAVE_FOG_R_NEW 0.13 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
    #define CAVE_FOG_G_NEW 0.13 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
    #define CAVE_FOG_B_NEW 0.15 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
    #define CAVE_FOG_I 1.00 //[0.20 0.25 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.0]

    float GetCaveFactor() {
        float caveFactor = clamp(1.0 - cameraPosition.y / oceanAltitude, 0.0, 1.0 - eyeBrightnessM);
        #ifdef SULFUR_CAVE_FOG
            caveFactor = mix(caveFactor, 1.0, inSulfurCaves);
        #endif
        #ifdef ICE_CAVE_FOG
            caveFactor = mix(caveFactor, 1.0, inIceCaves);
        #endif
        return caveFactor;
    }

    #if defined MODDED_FOG_SUPPORT && defined OVERWORLD && !defined VOXY_PATCH
        // Calculates mod/datapack fog strength (0 to 1). Ramps up smoothly when
        // gl_Fog.end or start is pulled inside 50% render distance (or negative start).
        // Returns 0 for all common vanilla fog cases.
        float GetModdedFogStrength() {
            if (isEyeInWater != 0 || heavyFog || maxBlindnessDarkness > 0.00001) return 0.0;
            float clearEnd = min(far, 512.0);
            #if MC_VERSION >= 12106 || defined DISTANT_HORIZONS || defined VOXY
                // 1.21.6 split fog into RD fog and environmental fog
                // Vanilla rain moves start and end inward by m times these offsets, so both give the same m. A mod breaks that agreement.
                const float vanillaFogBaseEnd = 1024.0; // Overworld environmental fog end without rain
                const float vanillaRainFogStartOffset = 160.0;
                const float vanillaRainFogEndOffset = 256.0;
                float rainFogM = clamp(min(-gl_Fog.start / vanillaRainFogStartOffset, (vanillaFogBaseEnd - gl_Fog.end) / vanillaRainFogEndOffset), 0.0, 1.0);
                float vanillaFogStart = -vanillaRainFogStartOffset * rainFogM;
                float vanillaFogEnd = vanillaFogBaseEnd - vanillaRainFogEndOffset * rainFogM;
                // Fog reached at the render distance edge, beyond what vanilla's fog gives there
                float fogAtFar = clamp((far - gl_Fog.start) / max(gl_Fog.end - gl_Fog.start, 1.0), 0.0, 1.0);
                float vanillaFogAtFar = clamp((far - vanillaFogStart) / (vanillaFogEnd - vanillaFogStart), 0.0, 0.99);
                float endStrength = gl_Fog.end < 1.0 ? 0.0 : clamp((fogAtFar - vanillaFogAtFar) / (1.0 - vanillaFogAtFar), 0.0, 1.0);
                float moddedFogStartRamp = 24.0; // Absolute blocks
                float startStrength = clamp((vanillaFogStart - gl_Fog.start) / moddedFogStartRamp, 0.0, 1.0);
            #else
                // Ternary needed to work with LOD mods or mods that disable vanilla fog
                float endStrength = gl_Fog.end < 1.0 ? 0.0 : clamp((clearEnd - gl_Fog.end) / (0.5 * clearEnd), 0.0, 1.0);
                float startStrength = clamp((0.5 * clearEnd - gl_Fog.start) / (0.5 * clearEnd), 0.0, 1.0);
            #endif
            return max(endStrength, startStrength);
        }

        // How much a modded biome's own fog replaces our cave fog. Modded biomes without fog keep the cave fog.
        float GetModdedBiomeFogTakeover() {
            return min(1.0, isCurrentBiomeModded * GetModdedFogStrength() + 0.33);
        }
    #else
        float GetModdedBiomeFogTakeover() {
            return isCurrentBiomeModded;
        }
    #endif

    vec3 caveFogColorRaw = vec3(CAVE_FOG_R_NEW, CAVE_FOG_G_NEW, CAVE_FOG_B_NEW) * CAVE_FOG_I;
    #if CAVE_LIGHTING < 100
        vec3 caveFogColorRaw2 = caveFogColorRaw * 0.7;
    #elif CAVE_LIGHTING == 100
        vec3 caveFogColorRaw2 = caveFogColorRaw * (0.7 + 0.3 * vsBrightness); // Default
    #elif CAVE_LIGHTING > 100
        vec3 caveFogColorRaw2 = caveFogColorRaw;
    #endif
    vec3 sulfurCaveFogColor = vec3(0.22, 0.25, 0.1);
    vec3 iceCaveFogColor = vec3(0.1, 0.25, 0.5);
    #ifdef SULFUR_CAVE_FOG
        vec3 caveFogColor = mix(caveFogColorRaw2, sulfurCaveFogColor, inSulfurCaves);
        #ifdef ICE_CAVE_FOG
            caveFogColor = mix(caveFogColor, iceCaveFogColor, inIceCaves);
        #endif
    #else
        vec3 caveFogColor = mix(caveFogColorRaw2, mix(fogColor, skyColor, 0.5) * 0.75, isCurrentBiomeModded);
    #endif
#endif
