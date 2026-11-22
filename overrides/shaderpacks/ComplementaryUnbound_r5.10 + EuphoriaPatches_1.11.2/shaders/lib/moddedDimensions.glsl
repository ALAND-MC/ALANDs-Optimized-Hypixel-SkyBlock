// Overrides for modded dimensions

// Shared: clouds, weather effects and light shafts are off in all of them
#undef CLOUD_STYLE_DEFINE
#define CLOUD_STYLE_DEFINE 0
#undef CLOUD_STYLE
#define CLOUD_STYLE 0
#undef AURORA_STYLE
#define AURORA_STYLE 0
#undef CLOUD_SHADOWS
#undef SNOWY_WORLD
#undef AURORA_INFLUENCE

#ifndef DIMENSION_NO_CLOUDS // The no clouds variant keeps light shafts
    #undef LIGHTSHAFT_BEHAVIOUR
    #define LIGHTSHAFT_BEHAVIOUR 0
#endif

// Shared:
#undef RAIN_PUDDLES
#define RAIN_PUDDLES 0
#undef BLOOD_MOON
#define BLOOD_MOON 0
#undef MOON_PHASE_INF_REFLECTION

// Airless only
#ifdef DIMENSION_SPACE_AIRLESS
    #undef ATMOSPHERIC_FOG
    #undef ATM_COLOR_MULTS
    #undef LIGHT_COLOR_MULTS
    #undef MOON_PHASE_INF_ATMOSPHERE
    #undef SUN_MOON_HORIZON
    #undef SHADOW_SMOOTHING
    #define SHADOW_SMOOTHING 1
#endif

// Cave / void: no sky at all. The no clouds variant keeps atmospheric fog
#ifdef DIMENSION_CAVE_VOID
    #ifndef DIMENSION_NO_CLOUDS
        #undef ATMOSPHERIC_FOG
    #endif
    #undef ATM_COLOR_MULTS
    #undef LIGHT_COLOR_MULTS
    #undef MOON_PHASE_INF_ATMOSPHERE
    #undef SUN_MOON_STYLE
    #define SUN_MOON_STYLE 1 // Force to Reimagined, then discard them only in this dimension in skytextured
    #undef LENSFLARE_MODE
    #define LENSFLARE_MODE 0
    #undef NIGHT_NEBULAE
    #define NIGHT_NEBULAE -1
#endif

// Mars sunsets
#ifdef DIMENSION_SPACE_ATMOSPHERE
    #if defined CURRENT_EUPHORIA_PATCHES_DIMENSION_AD_ASTRA_MARS || defined CURRENT_EUPHORIA_PATCHES_DIMENSION_STELLARIS_MARS
        #define MODDED_MARS_SUNSET
        #define MARS_SUNSET_SUN_COLOR vec3(0.55, 0.78, 1.25)
        #define MARS_SUNSET_DESATURATION 0.75
        #define MARS_SUNSET_GLOW_HEIGHT 0.5
    #endif
#endif

#ifdef DIMENSION_SPACE_AIRLESS
    #if defined CURRENT_EUPHORIA_PATCHES_DIMENSION_AD_ASTRA_MOON || defined CURRENT_EUPHORIA_PATCHES_DIMENSION_STELLARIS_MOON
        #define MODDED_MOON_DEFINE
    #endif
#endif

#ifdef CURRENT_EUPHORIA_PATCHES_DIMENSION_TWILIGHTFOREST_TWILIGHT_FOREST
    #define FOG_COLORED_HORIZON
#endif
