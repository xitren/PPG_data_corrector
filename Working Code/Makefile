testBIN = test

CFLAGS = -std=c99 -Wall -Wextra -pedantic -O0 -flto -march=native

INCLUDES = -Iref -Isrc -I.

LDFLAGS = -lm -Os

CC = gcc

FILTER = src/advanced_filter_ecg_ppg.c src/logger.c src/data_reader.c

all: test_filter_work

test_filter_work:
	rm -f $(testBIN)
	$(CC) -o $(testBIN) tests/test_run_filter.c $(FILTER) $(CFLAGS) $(INCLUDES) $(LDFLAGS)
	./$(testBIN)
	rm -f $(testBIN)

clean:
	rm -f $(testBIN)
