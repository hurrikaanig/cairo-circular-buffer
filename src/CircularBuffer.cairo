%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

struct CircularBuffer {
    buffer: felt*,      // pointer to the buffer where data is stored
    bufferEnd: felt*,   // pointer to the end of the buffer
    maxSize: felt,      // maximum of items in the buffer
    count: felt,        // current number of items in the buffer
    itemSize: felt,     // size of an item in felt
    head: felt*,        // pointer to head
    tail: felt*,        // pointer to tail
    headIndex: felt,
    tailIndex: felt,
}

namespace circularBuffer {

    // create a new Circular Buffer
    func create{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _maxSize: felt, _itemSize: felt 
    ) -> (circularBuffer: CircularBuffer) {
        let buffer: felt* = alloc();
        let bufferEnd: felt* = buffer + _maxSize * _itemSize;
        let head: felt* = buffer;
        let tail: felt* = buffer;
        let newBuffer: CircularBuffer = CircularBuffer(
            buffer = buffer,
            bufferEnd = bufferEnd,
            maxSize = _maxSize,
            count = 0,
            itemSize = _itemSize,
            head = head,
            tail = tail,
            headIndex = 0,
            tailIndex = 0,
        );
        return (newBuffer,);
    }

    // Push an item into the buffer
    // Returns the modified buffer
    // @param _cb circular buffer to modify
    // @param _item to add to the buffer
    // @param _overwrite if set to 1 it will overwrite the item at head
    func pushBack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _item: felt*, _overwrite: felt
    ) -> (circularBuffer: CircularBuffer){
        alloc_locals;
        local buffer: felt*;
        local bufferEnd: felt*;
        local head: felt*;
        local headIndex: felt;
        local tail: felt*;
        local tailIndex: felt;
        local count: felt;
        if (_cb.count != _cb.maxSize) {
            memcpy(_cb.head, _item, _cb.itemSize);
            assert buffer = _cb.buffer;
            assert bufferEnd = _cb.bufferEnd;
            assert head = _cb.head;
            assert tail = _cb.tail;
            assert tailIndex = _cb.tailIndex;
            assert count = _cb.count + 1;
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            with_attr error_mesage("cannot overwrite") {
                assert _overwrite = 1;
            }
            let newBuffer: felt* = overwrite(_cb, _item); 
            assert buffer = newBuffer;
            assert bufferEnd = buffer + _cb.maxSize * _cb.itemSize;
            assert head = buffer + _cb.headIndex;
            if (buffer + _cb.tailIndex + _cb.itemSize == bufferEnd) {
                assert tail = buffer;
                assert tailIndex = 0;
            } else {
                assert tail = buffer + _cb.tailIndex + _cb.itemSize;
                assert tailIndex = _cb.tailIndex + _cb.itemSize;
            }
            assert count = _cb.count;
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }

        local newHead: felt*;
        if (head + _cb.itemSize == bufferEnd) {
            assert newHead = buffer;
            assert headIndex = 0;
        } else {
            assert newHead = head + _cb.itemSize;
            assert headIndex = _cb.headIndex + _cb.itemSize;
        }
        
        let circularBuffer = CircularBuffer(
            buffer = buffer,
            bufferEnd = bufferEnd,
            maxSize = _cb.maxSize,
            count = count,
            itemSize = _cb.itemSize,
            head = newHead,
            tail = tail,
            headIndex = headIndex,
            tailIndex = tailIndex,
        );
        return (circularBuffer,);
    }

    // Remove an item from the buffer
    // Return the item
    func popFront{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer
    ) -> (circularBuffer: CircularBuffer, item: felt*) {
        alloc_locals;
        if (_cb.count == 0) {
            with_attr error_mesage("nothing to pop") {
                    assert 0 = 1;
            }
        }
        let item: felt* = alloc();
        memcpy(item, _cb.tail, _cb.itemSize);

        local newTail: felt*;
        local newTailIndex: felt;
        if (_cb.tail + _cb.itemSize == _cb.bufferEnd) {
            assert newTail = _cb.buffer;
            assert newTailIndex = 0;
        } else {
            assert newTail = _cb.tail + _cb.itemSize;
            assert newTailIndex = _cb.tailIndex + _cb.itemSize;
        }

        let circularBuffer = CircularBuffer(
            buffer = _cb.buffer,
            bufferEnd = _cb.bufferEnd,
            maxSize = _cb.maxSize,
            count = _cb.count - 1,
            itemSize = _cb.itemSize,
            head = _cb.head,
            tail = newTail,
            headIndex = _cb.headIndex,
            tailIndex = newTailIndex,
        );
        return (circularBuffer, item);
    }

    // copy data from old to new buffer and replace the new item
    func overwrite{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _item: felt*
    ) -> (buffer: felt*) {
        alloc_locals;
        let newBuffer: felt* = alloc();
        // copy before item to replace
        memcpy(newBuffer, _cb.buffer, _cb.tailIndex);
        // insert new item
        memcpy(newBuffer + _cb.tailIndex, _item, _cb.itemSize);
        // copy after item to replace
        let address1: felt* = newBuffer + _cb.tailIndex + _cb.itemSize;
        let address2: felt* = _cb.tail + _cb.itemSize;
        let address3: felt = _cb.itemSize * (_cb.maxSize - _cb.tailIndex) - _cb.itemSize;
        if (_cb.buffer + _cb.tailIndex + _cb.itemSize != _cb.bufferEnd) {
            memcpy(newBuffer + _cb.tailIndex + _cb.itemSize, _cb.tail + _cb.itemSize, _cb.itemSize * (_cb.maxSize - _cb.tailIndex) - _cb.itemSize);
        }
        return(newBuffer,);
    }

}