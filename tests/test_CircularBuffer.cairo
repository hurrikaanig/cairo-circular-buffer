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

@external
func test_push_cannot_overwrite{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 1);
    let item1: felt* = alloc();
    assert item1[0] = 42;
    let newBuffer1: CircularBuffer = circularBuffer.pushBack(myCircularBuffer, item1, 0);
    let item2: felt* = alloc();
    assert item2[0] = 12;
    let newBuffer2: CircularBuffer = circularBuffer.pushBack(newBuffer1, item2, 0);
    let item3: felt* = alloc();
    assert item3[0] = 1;
    let newBuffer3: CircularBuffer = circularBuffer.pushBack(newBuffer2, item3, 0);

    assert newBuffer3.buffer[0] = 42;
    assert newBuffer3.buffer[1] = 12;
    assert newBuffer3.buffer[2] = 1;
    assert newBuffer3.count = 3;
    assert newBuffer3.head = newBuffer3.buffer + 3;

    let item4: felt* = alloc();
    assert item4[0] = 9;
    %{ expect_revert() %}
    circularBuffer.pushBack(newBuffer3, item4, 0);

    let newBuffer: CircularBuffer = circularBuffer.pushBack(newBuffer3, item4, 1);
    assert newBuffer3.buffer[0] = 9;
    assert newBuffer3.buffer[1] = 12;
    assert newBuffer3.buffer[2] = 1;

    return ();
}

@external
func test_cannot_pop{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 1);
    let item1: felt* = alloc();
    assert item1[0] = 42;
    let newBuffer1: CircularBuffer = circularBuffer.pushBack(myCircularBuffer, item1, 0);
    let item2: felt* = alloc();
    assert item2[0] = 12;
    let newBuffer2: CircularBuffer = circularBuffer.pushBack(newBuffer1, item2, 0);

    let (newBuffer3: CircularBuffer, item1: felt*) = circularBuffer.popFront(newBuffer2);
    assert [item1] = 42;
    let (newBuffer4: CircularBuffer, item2: felt*) = circularBuffer.popFront(newBuffer3);
    assert [item2] = 12;

    %{ expect_revert() %}
    circularBuffer.popFront(newBuffer4);

    return ();
}