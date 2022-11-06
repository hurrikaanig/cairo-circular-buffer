# Cairo Circular Buffer
Circular buffer data structure written in Cairo

It is overwritable through a parameter and accept different item size (an item is a pointer to an array of felt).

This data structure is well-suited if you have to build a feature which need FIFO algorithm on a determined size of data.

Learn more about it: https://en.wikipedia.org/wiki/Circular_buffer

Compile:
```shell
protostar build
```
Test: 
```shell
protostar test
```
