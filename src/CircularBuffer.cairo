%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

struct CircularBuffer {
    buffer: felt*,
    bufferEnd: felt*,
    maxSize: felt,
    count: felt,
    itemSize: felt,
    head: felt*,
    tail: felt*,
}

namespace circularBuffer {

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
        );
        return (newBuffer,);
    }


    func pushBack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _item: felt*, _overwrite: felt
    ) -> (circularBuffer: CircularBuffer){
        alloc_locals;
        if (_cb.count != _cb.maxSize) {
            memcpy(_cb.head, _item, _cb.itemSize);
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            with_attr error_mesage("cannot overwrite") {
                assert _overwrite = 1;
            }
            let buffer: felt* = alloc();
            newBuffer(_cb, buffer, _item, 0);
            _cb.buffer = buffer;
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }
        local newHead: felt*;
        
        if (_cb.head + _cb.itemSize == _cb.tail) {
            _cb.head = _cb.buffer;
        } else {
            newHead = _cb.head + _cb.itemSize;
        }
        
        let circularBuffer = CircularBuffer(
            buffer = _cb.buffer,
            bufferEnd = _cb.bufferEnd,
            maxSize = _cb.maxSize,
            count = _cb.count + 1,
            itemSize = _cb.itemSize,
            head = newHead,
            tail = _cb.tail
        );
        return (circularBuffer,);
    }

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
        if (_cb.tail + _cb.itemSize == _cb.bufferEnd) {
            assert newTail = _cb.buffer;
        } else {
            newTail = _cb.tail + _cb.itemSize;
        }

        let circularBuffer = CircularBuffer(
            buffer = _cb.buffer,
            bufferEnd = _cb.bufferEnd,
            maxSize = _cb.maxSize,
            count = _cb.count - 1,
            itemSize = _cb.itemSize,
            head = _cb.head,
            tail = newTail
        );
        return (circularBuffer, item);
    }

    func newBuffer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _newBuffer: felt*, _item: felt*, _index: felt
    ) {
        memcpy(_newBuffer, _cb.buffer, _cb.count);
        assert _newBuffer[_cb.count] = [_item];
        memcpy(_newBuffer + _cb.count + 1, _cb.buffer + _cb.count + 1, _cb.maxSize - _cb.count - 1);
        return();
    }


}