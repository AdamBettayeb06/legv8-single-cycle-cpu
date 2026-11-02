TARGET = power_test
CC ?= gcc
FLAGS = -g -O0

$(TARGET): main.c power.S my_mul.S
	$(CC) $(FLAGS) $^ -o $@

clean:
	rm -f $(TARGET)
