#include "advanced_filter_ecg_ppg.h"
#include "data_reader.h"
#include "logger.h"
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>

FILE* file_ecg;
FILE* file_ppg;

void ecg_point_detector(adv_filter* filt, size_t data)
{
    fprintf(file_ecg, "%zu\n", data);
}

void ppg_point_detector(adv_filter* filt, size_t data)
{
    fprintf(file_ppg, "%zu\n", data);
}

// Learns and predicts hand written digits with 98% accuracy.
int main(void)
{
    // Tinn does not seed the random number generator.
    srand(time(0));
    
    FILE* const file = fopen("output_data.csv", "w");
    file_ecg = fopen("ecg_pts.csv", "w");
    file_ppg = fopen("ppg_pts.csv", "w");
    const int nips = 2;
    const int nops = 0;
    float target[3];
    adv_filter filter;
    data data;
    
    // Load the training set.
    DESCRIBE_LOG("Read started\n");
    build_data(&data, "input_data.txt", "\t", nips, nops);
    DESCRIBE_LOG("Files readed %zu rows\n", data.rows);

    // Train, baby, train.
    DESCRIBE_LOG("Initialization started\n");
    adv_filter_init(&filter, &ecg_point_detector, &ppg_point_detector);
    DESCRIBE_LOG("Load started\n");
    DESCRIBE_LOG("Inference started\n");
    for (size_t k = 0; k < data.rows; k++)
    {
        adv_filter_input(&filter, (uint16_t)data.in[k][0], (uint16_t)data.in[k][1]);
        const uint16_t out_ecg = get_last_parsed_ecg(&filter);
        const uint16_t out_ppg = get_last_parsed_ppg(&filter);
        fprintf(file, "%hu\t%hu\n", out_ecg, out_ppg);
    }
    DESCRIBE_LOG("diff = %zu\n", filter.diff);
    fclose(file);
    fclose(file_ecg);
    fclose(file_ppg);
    return 0;
}
