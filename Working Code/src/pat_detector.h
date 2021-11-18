/* 
 * File:   pat_detector.h
 * Author: xitre
 *
 * Created on 18 ноября 2021 г., 16:16
 */

#ifndef PAT_DETECTOR_H
#define PAT_DETECTOR_H

#ifdef __cplusplus
extern "C" {
#endif
    
#include <stdarg.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
    
typedef struct _tag_pat_detector pat_detector;

typedef void (*pat_event)(pat_detector* detector, uint16_t data);

struct _tag_pat_detector {
    // Window size
    size_t window;
    // ECG
    size_t ecg_pt;
    // PAT
    uint16_t prev_pat;
    uint16_t last_pat;
    uint16_t corrector;
    uint16_t corrector_cnt;
    // Event function
    pat_event event;
    // ECG PPG points filter
    adv_filter* filter;
};

int pat_initializer(pat_detector* detector, adv_filter* filter);
uint16_t pat_get_last(pat_detector* detector);
void pat_register(pat_detector* detector, pat_event fn_event);

#ifdef __cplusplus
}
#endif

#endif /* PAT_DETECTOR_H */

