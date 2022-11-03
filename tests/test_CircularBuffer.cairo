%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from src.CircularBuffer import (circularBuffer, CircularBuffer)

@external
func test_CreateCircularBuffer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 1);
    assert myCircularBuffer.maxSize = 3;
    assert myCircularBuffer.itemSize = 1;
    assert myCircularBuffer.count = 0;
    let calculateEnd: felt* = myCircularBuffer.buffer + myCircularBuffer.maxSize * myCircularBuffer.itemSize;
    assert calculateEnd = myCircularBuffer.bufferEnd;
    return ();
}

@external
func test_pushBack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 1);
    let item: felt* = alloc();
    assert item[0] = 42;
    let newBuffer: CircularBuffer = circularBuffer.pushBack(myCircularBuffer, item, 0);
    assert newBuffer.buffer[0] = 42;
    assert newBuffer.count = 1;
    assert newBuffer.head = myCircularBuffer.head + 1;
    return ();
}

@external
func test_popFront{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 1);
    let item: felt* = alloc();
    assert item[0] = 42;
    let newBuffer: CircularBuffer = circularBuffer.pushBack(myCircularBuffer, item, 0);
    let (secondBuffer: CircularBuffer, item: felt*) = circularBuffer.popFront(newBuffer);
    assert [item] = 42;
    assert secondBuffer.count = 0;
    assert secondBuffer.tail = secondBuffer.head;
    return ();
}