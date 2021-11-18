/* 
 * File:   pat_detector.c
 * Author: xitre
 *
 * Created on 18 ноября 2021 г., 16:16
 */

#include "pat_detector.h"
#include "logger.h"
#include "advanced_filter_ecg_ppg.h"

#define MAX_PAT_POINTS 600
#define MAX_PAT_DETECTORS 4

static pat_detector* det_list[MAX_PAT_DETECTORS];
static size_t detectors_list_cnt;

void ecg_point_detector(adv_filter* filt, size_t data)
{
    int i;
    for (i=0;(i < detectors_list_cnt) && (i < MAX_PAT_DETECTORS);i++)
    {
        if (filt == (det_list[i]->filter))
        {
            det_list[i]->ecg_pt = data;
            break;
        }
    }
}

void ppg_point_detector(adv_filter* filt, size_t data)
{
    int i;
    for (i=0;(i < detectors_list_cnt) && (i < MAX_PAT_DETECTORS);i++)
    {
        if (filt == (det_list[i]->filter))
        {
            const pat_detector* det = det_list[i];
            if ( (det->ecg_pt + MAX_PAT_POINTS) < data )
                break;
            if ( abs(det->prev_pat - det->last_pat)
                    > (det->corrector * det->corrector_cnt) )
            {
                det->corrector_cnt++;
            } 
            else
            {
                det->prev_pat = det->last_pat;
                det->last_pat = data - det->ecg_pt;
                det->ecg_pt = data + 1;
                if (det->event != 0)
                    det->event(det, det->last_pat);
                det->corrector_cnt = 1;
            }
            break;
        }
    }
}

int pat_initializer(pat_detector* detector, adv_filter* filter)
{
    detector->window;
    detector->filter = filter;
    detector->filter->ecg_point_detector = ecg_point_detector;
    detector->filter->ppg_point_detector = ppg_point_detector;
    detector->last_pat = 0;
    detector->prev_pat = 0;
    detector->ecg_pt = 0;
    if (detectors_list_cnt >= MAX_PAT_DETECTORS)
    {
        return -1;
    }
    return 0;
}

uint16_t pat_get_last(pat_detector* detector)
{
    return detector->last_pat;
}

void pat_register(pat_detector* detector, pat_event fn_event)
{
    detector->event = fn_event;
}
