%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from src.CircularBuffer import (circularBuffer, CircularBuffer)

@external
func test_create_CircularBuffer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
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
    assert newBuffer3.head = newBuffer3.buffer;

    let item4: felt* = alloc();
    assert item4[0] = 9;
    %{ expect_revert() %}
    circularBuffer.pushBack(newBuffer3, item4, 0);

    return ();
}

@external
func test_push_should_overwrite{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
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
    assert newBuffer3.head = newBuffer3.buffer;

    let item4: felt* = alloc();
    assert item4[0] = 9;

    let newBuffer4: CircularBuffer = circularBuffer.pushBack(newBuffer3, item4, 1);
    assert newBuffer4.buffer[0] = 9;
    assert newBuffer4.buffer[1] = 12;
    assert newBuffer4.buffer[2] = 1;
    assert newBuffer4.tail = newBuffer4.buffer + myCircularBuffer.itemSize;
    assert newBuffer4.head = newBuffer4.buffer + myCircularBuffer.itemSize;

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

@external
func test_size_two_items{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let myCircularBuffer: CircularBuffer = circularBuffer.create(3, 2);
    let item1: felt* = alloc();
    assert item1[0] = 42;
    assert item1[1] = 24;
    let newBuffer1: CircularBuffer = circularBuffer.pushBack(myCircularBuffer, item1, 0);
    let item2: felt* = alloc();
    assert item2[0] = 12;
    assert item2[1] = 21;
    let newBuffer2: CircularBuffer = circularBuffer.pushBack(newBuffer1, item2, 0);
    let item3: felt* = alloc();
    assert item3[0] = 92;
    assert item3[1] = 29;
    let newBuffer3: CircularBuffer = circularBuffer.pushBack(newBuffer2, item3, 0);

    assert newBuffer3.buffer[0] = 42;
    assert newBuffer3.buffer[1] = 24;
    assert newBuffer3.buffer[2] = 12;
    assert newBuffer3.buffer[3] = 21;
    assert newBuffer3.buffer[4] = 92;
    assert newBuffer3.buffer[5] = 29;
    assert newBuffer3.count = 3;
    assert newBuffer3.head = newBuffer3.buffer;

    let item4: felt* = alloc();
    assert item4[0] = 43;
    assert item4[1] = 32;

    let newBuffer4: CircularBuffer = circularBuffer.pushBack(newBuffer3, item4, 1);
    assert newBuffer4.buffer[0] = 43;
    assert newBuffer4.buffer[1] = 32;
    assert newBuffer4.buffer[2] = 12;
    assert newBuffer4.buffer[3] = 21;
    assert newBuffer4.buffer[4] = 92;
    assert newBuffer4.buffer[5] = 29;
    assert newBuffer4.tail = newBuffer4.buffer + myCircularBuffer.itemSize;
    assert newBuffer4.head = newBuffer4.buffer + myCircularBuffer.itemSize;

    let item5: felt* = alloc();
    assert item5[0] = 98;
    assert item5[1] = 89;

    let newBuffer5: CircularBuffer = circularBuffer.pushBack(newBuffer4, item5, 1);
    assert newBuffer5.buffer[0] = 43;
    assert newBuffer5.buffer[1] = 32;
    assert newBuffer5.buffer[2] = 98;
    assert newBuffer5.buffer[3] = 89;
    assert newBuffer5.buffer[4] = 92;
    assert newBuffer5.buffer[5] = 29;
    assert newBuffer5.tail = newBuffer5.buffer + myCircularBuffer.itemSize * 2;
    assert newBuffer5.head = newBuffer5.buffer + myCircularBuffer.itemSize * 2;

    let item6: felt* = alloc();
    assert item6[0] = 19;
    assert item6[1] = 91;

    let newBuffer6: CircularBuffer = circularBuffer.pushBack(newBuffer5, item6, 1);
    assert newBuffer6.buffer[0] = 43;
    assert newBuffer6.buffer[1] = 32;
    assert newBuffer6.buffer[2] = 98;
    assert newBuffer6.buffer[3] = 89;
    assert newBuffer6.buffer[4] = 19;
    assert newBuffer6.buffer[5] = 91;
    assert newBuffer6.tail = newBuffer6.buffer;
    assert newBuffer6.head = newBuffer6.buffer;

    let item7: felt* = alloc();
    assert item7[0] = 76;
    assert item7[1] = 67;

    let newBuffer7: CircularBuffer = circularBuffer.pushBack(newBuffer6, item7, 1);
    assert newBuffer7.buffer[0] = 76;
    assert newBuffer7.buffer[1] = 67;
    assert newBuffer7.buffer[2] = 98;
    assert newBuffer7.buffer[3] = 89;
    assert newBuffer7.buffer[4] = 19;
    assert newBuffer7.buffer[5] = 91;
    assert newBuffer7.tail = newBuffer7.buffer + myCircularBuffer.itemSize;
    assert newBuffer7.head = newBuffer7.buffer + myCircularBuffer.itemSize;

    return ();
}