#include "advanced_filter_ecg_ppg.h"
#include "logger.h"

#define INCREMENTER (WINDOW / 2 + 1)

typedef union _tag_caster {
   uint32_t u32;
   uint16_t u16[2];
   uint8_t u8[4];
} caster;

static uint16_t ecg[WINDOW];
static uint16_t ppg[WINDOW];
static uint8_t ecg_parsed[WINDOW];
static uint8_t ppg_parsed[WINDOW];
static uint32_t mark_ecg[DOTS];
static uint32_t mark_ppg[DOTS];

static void init_adv_filter_input(adv_filter* filt,
        uint16_t data_ecg, uint16_t data_ppg);
static void after_adv_filter_input(adv_filter* filt,
        uint16_t data_ecg, uint16_t data_ppg);
static inline void adv_min_max(adv_filter* filt,
        uint16_t data_ecg, uint16_t data_ppg);
static inline void adv_min_max_clear(adv_filter* filt);
static inline void adv_min_max_stage(adv_filter* filt);
static inline size_t tang0_by_two_points(const size_t x1, const uint8_t y1,
        const size_t x2, const uint8_t y2);
static inline void adv_correction(adv_filter* filt,
        const uint16_t data_ecg, const uint16_t data_ppg);

void adv_filter_init(adv_filter* filt, point_detector ecg_det, point_detector ppg_det)
{
    TRACE_LOG("adv_filter_init\n");
    filt->ecg = ecg;
    filt->ppg = ppg;
    filt->ecg_parsed = ecg_parsed;
    filt->ppg_parsed = ppg_parsed;
    filt->mark_ecg = mark_ecg;
    filt->mark_ppg = mark_ppg;
    filt->window = WINDOW;
    memset(filt->ecg, 0, sizeof(ecg));
    memset(filt->ppg, 0, sizeof(ppg));
    memset(filt->ecg_parsed, 0, sizeof(ecg_parsed));
    memset(filt->ppg_parsed, 0, sizeof(ppg_parsed));
    memset(filt->mark_ecg, 0, sizeof(mark_ecg));
    memset(filt->mark_ppg, 0, sizeof(mark_ppg));
    adv_min_max_clear(filt);
    filt->min_ecg[1] = UINT_LEAST16_MAX;
    filt->max_ecg[1] = 1;
    filt->min_ecg_it[1] = 1;
    filt->max_ecg_it[1] = 1;
    filt->min_ppg[1] = UINT_LEAST16_MAX;
    filt->max_ppg[1] = 1;
    filt->min_ppg_it[1] = 1;
    filt->max_ppg_it[1] = 1;
    filt->min_ecg[2] = UINT_LEAST16_MAX;
    filt->max_ecg[2] = 1;
    filt->min_ecg_it[2] = 1;
    filt->max_ecg_it[2] = 1;
    filt->min_ppg[2] = UINT_LEAST16_MAX;
    filt->max_ppg[2] = 1;
    filt->min_ppg_it[2] = 1;
    filt->max_ppg_it[2] = 1;
    filt->diff = INCREMENTER;
    filt->tail = 0;
    filt->head = 0;
    filt->head_parsed = 0;
    filt->mark_ecg_head = 0;
    filt->mark_ppg_head = 0;
    filt->ecg_point_detector = ecg_det;
    filt->ppg_point_detector = ppg_det;
    filt->fp = &init_adv_filter_input;
    TRACE_LOG("adv_filter_init end\n");
}

uint16_t get_last_parsed_ecg(adv_filter* filt)
{
    TRACE_LOG("get_last_parsed_ecg %zu > 0 res(%zu) = %hu\n",
              filt->head_parsed, (filt->head_parsed - 1) % WINDOW,
              filt->ecg_parsed[(filt->head_parsed - 1) % WINDOW]);
    if (filt->head_parsed > 0)
        return filt->ecg_parsed[(filt->head_parsed - 1) % WINDOW];
    else
        return 0;
}

uint16_t get_last_parsed_ppg(adv_filter* filt)
{
    TRACE_LOG("get_last_parsed_ppg %zu > 0 res(%zu) = %hu\n",
              filt->head_parsed, (filt->head_parsed - 1) % WINDOW,
              filt->ppg_parsed[(filt->head_parsed - 1) % WINDOW]);
    if (filt->head_parsed > 0)
        return filt->ppg_parsed[(filt->head_parsed - 1) % WINDOW];
    else
        return 0;
}

void get_lasts_parsed(adv_filter* filt, uint16_t* data_ecg, uint16_t* data_ppg, size_t n)
{
    size_t i;
    TRACE_LOG("get_lasts_parsed\n");
    for (i = 1;(i <= n) && (i <= filt->head_parsed);i++)
    {
        TRACE_LOG("%zu <= %zu && %zu <= %zu\n", i, n, i, filt->head_parsed);
        data_ecg[n - i] = filt->ecg_parsed[(filt->head_parsed - i) % WINDOW];
        data_ppg[n - i] = filt->ppg_parsed[(filt->head_parsed - i) % WINDOW];
        TRACE_LOG("data_ecg[%zu] = %hu[%zu], data_ppg[%zu] = %hu[%zu]\n",
                  n - i, filt->ecg_parsed[(filt->head_parsed - 1) % WINDOW],
                  (filt->head_parsed - 1) % WINDOW,
                  n - i, filt->ppg_parsed[(filt->head_parsed - 1) % WINDOW],
                  (filt->head_parsed - 1) % WINDOW);
    }
    for (;(i <= n);i++)
    {
        TRACE_LOG("%zu <= %zu\n", i, n);
        data_ecg[n - i] = 0;
        data_ppg[n - i] = 0;
    }
    TRACE_LOG("get_lasts_parsed end\n");
}

static inline void adv_min_max_clear(adv_filter* filt)
{
    TRACE_LOG("adv_min_max_clear\n");
    filt->min_ecg[0] = UINT_LEAST16_MAX;
    filt->max_ecg[0] = 1;
    filt->min_ecg_it[0] = 1;
    filt->max_ecg_it[0] = 1;
    filt->min_ppg[0] = UINT_LEAST16_MAX;
    filt->max_ppg[0] = 1;
    filt->min_ppg_it[0] = 1;
    filt->max_ppg_it[0] = 1;
    TRACE_LOG("adv_min_max_clear end\n");
}

static void init_adv_filter_input(adv_filter* filt, uint16_t data_ecg, uint16_t data_ppg)
{
    TRACE_LOG("init_adv_filter_input\n");
    filt->ecg[filt->head % WINDOW] = data_ecg;
    filt->ppg[filt->head % WINDOW] = data_ppg;
    filt->head++;
    TRACE_LOG("head = %zu\n", filt->head);
    if (filt->head >= WINDOW)
    {
        DEBUG_LOG("Start window collected\n");
        filt->fp = &after_adv_filter_input;
        TRACE_LOG("init_adv_filter_input end\n");
        return;
    }
    TRACE_LOG("init_adv_filter_input end\n");
}

static void after_adv_filter_input(adv_filter* filt, uint16_t data_ecg, uint16_t data_ppg)
{
    TRACE_LOG("after_adv_filter_input\n");
    const uint16_t old_ecg = filt->ecg[(filt->head - WINDOW/2) % WINDOW];
    const uint16_t old_ppg = filt->ppg[(filt->head - WINDOW/2) % WINDOW];
    filt->ecg[filt->head % WINDOW] = data_ecg;
    filt->ppg[filt->head % WINDOW] = data_ppg;
    filt->tail++;
    filt->head++;
    adv_correction(filt, old_ecg, old_ppg);
    TRACE_LOG("after_adv_filter_input end\n");
}

static inline size_t tang0_by_two_points(const size_t x1, const uint8_t y1,
        const size_t x2, const uint8_t y2)
{
    const float fx1 = (float)x1;
    const float fy1 = (float)y1;
    const float fx2 = (float)x2;
    const float fy2 = (float)y2;
    const float fy = 0;
    const float fx = ((fy - fy1) * (fx2 - fx1) / (fy2 - fy1)) + fx1;
    return floor(fx);
}

static inline void adv_correction(adv_filter* filt, const uint16_t data_ecg, const uint16_t data_ppg)
{
    size_t i;
    TRACE_LOG("adv_correction\n");
    static uint32_t old_ppg[MVAVERAGE];
    static uint32_t old_ppg_sum;
    static uint8_t old_ppg_ress;
    static uint8_t old_ppg_cnt;
    uint32_t ecg_t = data_ecg - filt->min_ecg[2];
    uint32_t ppg_t = data_ppg - filt->min_ppg[2];
    PRECISE_LOG("selected %u = %hu - %hu\n", ecg_t, data_ecg, filt->min_ecg[2]);
    PRECISE_LOG("selected %u = %hu - %hu\n", ppg_t, data_ppg, filt->min_ppg[2]);
    ecg_t = ecg_t * UINT_LEAST8_MAX / (uint32_t)(filt->max_ecg[2] - filt->min_ecg[2]);
    ppg_t = ppg_t * UINT_LEAST8_MAX / (uint32_t)(filt->max_ppg[2] - filt->min_ppg[2]);
    PRECISE_LOG("resized %u *= 1 / (%hu - %hu)\n",
            ecg_t, filt->max_ecg[2], filt->min_ecg[2]);
    PRECISE_LOG("resized %u *= 1 / (%hu - %hu)\n",
            ppg_t, filt->max_ppg[2], filt->min_ppg[2]);
    filt->ecg_parsed[filt->head_parsed % WINDOW] = (uint8_t)ecg_t;
    old_ppg[(old_ppg_cnt++) % MVAVERAGE] = ppg_t;
    old_ppg_sum = 0;
    for (i = 0;i < MVAVERAGE;i++)
        old_ppg_sum += old_ppg[i];
    const uint8_t old_ppg_res = (uint8_t)(old_ppg_sum / MVAVERAGE);
    filt->ppg_parsed[filt->head_parsed % WINDOW] = old_ppg_res;
    if ((old_ppg_ress < 100) && (100 <= old_ppg_res))
    {
        const size_t x = tang0_by_two_points(filt->head - WINDOW/2 - MVAVERAGE,
                filt->ppg_parsed[(filt->head_parsed - MVAVERAGE) % WINDOW],
                filt->head - WINDOW/2, old_ppg_res);
        if (((filt->head - WINDOW/2 - 300) < x) && (x < (filt->head - WINDOW/2)))
        {
            filt->mark_ppg[filt->mark_ppg_head % DOTS] = x;
            filt->mark_ppg_head++;
            (filt->ppg_point_detector)(filt, x + filt->diff);
        }
    }
    old_ppg_ress = old_ppg_res;
    PRECISE_LOG("saved %hhu (%zu)\n", ecg_t, filt->head_parsed % WINDOW);
    PRECISE_LOG("saved %hhu (%zu)\n", ppg_t, filt->head_parsed % WINDOW);
    filt->head_parsed++;
    TRACE_LOG("adv_correction end\n");
}

void adv_filter_input(adv_filter* filt, uint16_t data_ecg, uint16_t data_ppg)
{
    static size_t old_ecg;
    TRACE_LOG("adv_filter_input (%hu, %hu)\n",data_ecg,data_ppg);
    data_ecg++;
    data_ppg++;
    (filt->fp)(filt, data_ecg, data_ppg);
    adv_min_max(filt, data_ecg, data_ppg);
    if (!(filt->head % (WINDOW / 2)))
    {
        if (old_ecg != filt->max_ecg_it[2])
        {
            old_ecg = filt->mark_ecg[filt->mark_ecg_head % DOTS] = filt->max_ecg_it[2];
            filt->mark_ecg_head++;
            (filt->ecg_point_detector)(filt, filt->max_ecg_it[2] + filt->diff);
        }
        adv_min_max_stage(filt);
        filt->min_ecg[1] = filt->min_ecg[0];
        filt->max_ecg[1] = filt->max_ecg[0];
        filt->min_ecg_it[1] = filt->min_ecg_it[0];
        filt->max_ecg_it[1] = filt->max_ecg_it[0];
        filt->min_ppg[1] = filt->min_ppg[0];
        filt->max_ppg[1] = filt->max_ppg[0];
        filt->min_ppg_it[1] = filt->min_ppg_it[0];
        filt->max_ppg_it[1] = filt->max_ppg_it[0];
        adv_min_max_clear(filt);
    }
    TRACE_LOG("adv_filter_input end\n");
}

void adv_filter_inputs(adv_filter* filt, uint16_t* data_ecg, uint16_t* data_ppg, size_t n)
{
    TRACE_LOG("adv_filter_inputs\n");
    size_t i;
    for (i = 0;i < n;i++)
    {
        DEBUG_LOG("Pass data to filter %zu\n", i);
        adv_filter_input(filt, data_ecg[i], data_ppg[i]);
    }
    TRACE_LOG("adv_filter_inputs end\n");
}

#ifdef SIMD
//res[15:0]  = val1[15:0]  - val2[15:0]
//res[31:16] = val1[31:16] - val2[31:16]
//__SSUB16(cast1, cast2);
//if res[15:0] >= 0 then APSR.GE[1:0] = 11 else 00
//if res[31:16] >= 0 then APSR.GE[3:2] = 11 else 00
//if APSR.GE[0] == 1 then res[7:0] = val1[7:0] else res[7:0] = val2[7:0]
//if APSR.GE[1] == 1 then res[15:8] = val1[15:8] else res[15:8] = val2[15:8]
//if APSR.GE[2] == 1 then res[23:16] = val1[23:16] else res[23:16] = val2[23:16]
//if APSR.GE[3] == 1 then res[31;24] = val1[31:24] else res = val2[31:24]
//res = __SEL(cast1, cast2);
static inline void adv_min_max(adv_filter* filt, uint16_t data_ecg, uint16_t data_ppg)
{
    TRACE_LOG("adv_min_max\n");
    caster cast1, cast2, res;
    cast1.u16[0] = filt->min_ecg[0];
    cast1.u16[1] = filt->min_ppg[0];
    cast2.u16[0] = data_ecg;
    cast2.u16[1] = data_ppg;
    PRECISE_LOG("cast1(%hu, %hu) cast2(%hu, %hu)\n",
            filt->min_ecg[0], filt->min_ppg[0], data_ecg, data_ppg);
    __SSUB16(cast1, cast2);
    res = __SEL(cast1, cast2);
    PRECISE_LOG("__SSUB16 & __SEL\n");
    filt->min_ecg[0] = res.u16[0];
    filt->min_ppg[0] = res.u16[1];
    PRECISE_LOG("result(%hu, %hu)\n", filt->min_ecg[0], filt->min_ppg[0]);
    cast1.u16[0] = filt->max_ecg[0];
    cast1.u16[1] = filt->max_ppg[0];
    PRECISE_LOG("cast1(%hu, %hu) cast2(%hu, %hu)\n",
            filt->max_ecg[0], filt->max_ppg[0], data_ecg, data_ppg);
    __SSUB16(cast1, cast2);
    res = __SEL(cast2, cast1);
    PRECISE_LOG("__SSUB16 & __SEL\n");
    filt->max_ecg[0] = res.u16[0];
    filt->max_ppg[0] = res.u16[1];
    PRECISE_LOG("result(%hu, %hu)\n", filt->max_ecg[0], filt->max_ppg[0]);
    TRACE_LOG("adv_min_max end\n");
}
static inline void adv_min_max_stage(adv_filter* filt)
{
    TRACE_LOG("adv_min_max\n");
    caster cast1, cast2, res;
    cast1.u16[0] = filt->min_ecg[1];
    cast1.u16[1] = filt->min_ppg[1];
    cast2.u16[0] = filt->min_ecg[0];
    cast2.u16[1] = filt->min_ppg[0];
    PRECISE_LOG("cast1(%hu, %hu) cast2(%hu, %hu)\n",
            filt->min_ecg[1], filt->min_ppg[1], filt->min_ecg[0], filt->min_ppg[0]);
    __SSUB16(cast1, cast2);
    res = __SEL(cast1, cast2);
    PRECISE_LOG("__SSUB16 & __SEL\n");
    filt->min_ecg[2] = res.u16[0];
    filt->min_ppg[2] = res.u16[1];
    PRECISE_LOG("result(%hu, %hu)\n", filt->min_ecg[2], filt->min_ppg[2]);
    cast1.u16[0] = filt->max_ecg[1];
    cast1.u16[1] = filt->max_ppg[1];
    cast2.u16[0] = filt->max_ecg[0];
    cast2.u16[1] = filt->max_ppg[0];
    PRECISE_LOG("cast1(%hu, %hu) cast2(%hu, %hu)\n",
            filt->max_ecg[1], filt->max_ppg[1], filt->max_ecg[0], filt->max_ppg[0]);
    __SSUB16(cast1, cast2);
    res = __SEL(cast2, cast1);
    PRECISE_LOG("__SSUB16 & __SEL\n");
    filt->max_ecg[2] = res.u16[0];
    filt->max_ppg[2] = res.u16[1];
    PRECISE_LOG("result(%hu, %hu)\n", filt->max_ecg[2], filt->max_ppg[2]);
    TRACE_LOG("adv_min_max end\n");
}
#else
//(result && (max = a)) || (max = b)
static inline void adv_min_max(adv_filter* filt, uint16_t data_ecg, uint16_t data_ppg)
{
    TRACE_LOG("adv_min_max\n");
    const uint16_t min_ecg_cmp = filt->min_ecg[0] < data_ecg;
    const uint16_t min_ppg_cmp = filt->min_ppg[0] < data_ppg;
    const uint16_t max_ecg_cmp = filt->max_ecg[0] > data_ecg;
    const uint16_t max_ppg_cmp = filt->max_ppg[0] > data_ppg;
    
    PRECISE_LOG("min_ecg(%hu, %hu)", filt->min_ecg[0], data_ecg);
    (min_ecg_cmp && (filt->min_ecg[0] = filt->min_ecg[0]))
            || (filt->min_ecg[0] = data_ecg);
    PRECISE_LOG(" = %hu ", filt->min_ecg[0]);
    (min_ecg_cmp && (filt->min_ecg_it[0] = filt->min_ecg_it[0]))
            || (filt->min_ecg_it[0] = (filt->head - 1));
    PRECISE_LOG("(%zu)(%zu - %zu)\n", filt->min_ecg_it[0],
                (filt->head - 1));
    
    PRECISE_LOG("min_ppg(%hu, %hu)", filt->min_ppg[0], data_ppg);
    (min_ppg_cmp && (filt->min_ppg[0] = filt->min_ppg[0]))
            || (filt->min_ppg[0] = (data_ppg));
    PRECISE_LOG(" = %hu ", filt->min_ppg[0]);
    (min_ppg_cmp && (filt->min_ppg_it[0] = filt->min_ppg_it[0]))
            || (filt->min_ppg_it[0] = (filt->head - 1));
    PRECISE_LOG("(%zu)\n", filt->min_ppg_it[0]);
    
    PRECISE_LOG("max_ecg(%hu, %hu)", filt->max_ecg[0], data_ecg);
    (max_ecg_cmp && (filt->max_ecg[0] = filt->max_ecg[0]))
            || (filt->max_ecg[0] = data_ecg);
    PRECISE_LOG(" = %hu ", filt->max_ecg[0]);
    (max_ecg_cmp && (filt->max_ecg_it[0] = filt->max_ecg_it[0]))
            || (filt->max_ecg_it[0] = (filt->head - 1));
    PRECISE_LOG("(%zu)\n", filt->max_ecg_it[0]);
    
    PRECISE_LOG("max_ppg(%hu, %hu)", filt->max_ppg[0], data_ppg);
    (max_ppg_cmp && (filt->max_ppg[0] = filt->max_ppg[0]))
            || (filt->max_ppg[0] = (data_ppg));
    PRECISE_LOG(" = %hu ", filt->max_ppg[0]);
    (max_ppg_cmp && (filt->max_ppg_it[0] = filt->max_ppg_it[0]))
            || (filt->max_ppg_it[0] = (filt->head - 1));
    PRECISE_LOG("(%zu)\n", filt->max_ppg_it[0]);
    TRACE_LOG("adv_min_max end\n");
}
static inline void adv_min_max_stage(adv_filter* filt)
{
    TRACE_LOG("adv_min_max_stage\n");
    const uint16_t min_ecg_cmp = filt->min_ecg[1] < filt->min_ecg[0];
    const uint16_t min_ppg_cmp = filt->min_ppg[1] < filt->min_ppg[0];
    const uint16_t max_ecg_cmp = filt->max_ecg[1] > filt->max_ecg[0];
    const uint16_t max_ppg_cmp = filt->max_ppg[1] > filt->max_ppg[0];
    
    PRECISE_LOG("min_ecg(%hu, %hu)", filt->min_ecg[1], filt->min_ecg[0]);
    (min_ecg_cmp && (filt->min_ecg[2] = filt->min_ecg[1]))
            || (filt->min_ecg[2] = filt->min_ecg[0]);
    PRECISE_LOG(" = %hu ", filt->min_ecg[2]);
    (min_ecg_cmp && (filt->min_ecg_it[2] = filt->min_ecg_it[1]))
            || (filt->min_ecg_it[2] = filt->min_ecg_it[0]);
    PRECISE_LOG("(%zu)\n", filt->min_ecg_it[2]);
    
    PRECISE_LOG("min_ppg(%hu, %hu)", filt->min_ppg[1], filt->min_ppg[0]);
    (min_ppg_cmp && (filt->min_ppg[2] = filt->min_ppg[1]))
            || (filt->min_ppg[2] = filt->min_ppg[0]);
    PRECISE_LOG(" = %hu ", filt->min_ppg[2]);
    (min_ppg_cmp && (filt->min_ppg_it[2] = filt->min_ppg_it[1]))
            || (filt->min_ppg_it[2] = filt->min_ppg_it[0]);
    PRECISE_LOG("(%zu)\n", filt->min_ppg_it[2]);
    
    PRECISE_LOG("max_ecg(%hu, %hu)", filt->max_ecg[1], filt->max_ecg[0]);
    (max_ecg_cmp && (filt->max_ecg[2] = filt->max_ecg[1]))
            || (filt->max_ecg[2] = filt->max_ecg[0]);
    PRECISE_LOG(" = %hu ", filt->max_ecg[2]);
    (max_ecg_cmp && (filt->max_ecg_it[2] = filt->max_ecg_it[1]))
            || (filt->max_ecg_it[2] = filt->max_ecg_it[0]);
    PRECISE_LOG("(%zu)\n", filt->max_ecg_it[2]);
    
    PRECISE_LOG("max_ppg(%hu, %hu)", filt->max_ppg[1], filt->max_ppg[0]);
    (max_ppg_cmp && (filt->max_ppg[2] = filt->max_ppg[1]))
            || (filt->max_ppg[2] = filt->max_ppg[0]);
    PRECISE_LOG(" = %hu ", filt->max_ppg[2]);
    (max_ppg_cmp && (filt->max_ppg_it[2] = filt->max_ppg_it[1]))
            || (filt->max_ppg_it[2] = filt->max_ppg_it[0]);
    PRECISE_LOG("(%zu)\n", filt->max_ppg_it[2]);
    TRACE_LOG("adv_min_max_stage end\n");
}
#endif