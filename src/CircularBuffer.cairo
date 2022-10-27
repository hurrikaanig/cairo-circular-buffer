%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

struct CircularBuffer {
    buffer: felt*,
    bufferEnd: felt*,
    maxSize: felt,
    count: felt,
    size: felt,
    head: felt*,
    tail: felt*,
}

namespace circularBuffer {

    func init{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _maxSize: felt, _itemSize: felt 
    ) {
        let buffer: felt* = alloc();
        let bufferEnd: felt* = buffer + _maxSize * _itemSize;
        let head: felt* = buffer;
        let tail: felt* = buffer;
        let newBuffer: CircularBuffer = CircularBuffer(
            buffer = buffer,
            bufferEnd = bufferEnd,
            maxSize = _maxSize,
            count = 0,
            head = head,
            tail = tail,
        );
    }


    func pushBack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _item: felt*, _overwrite: felt
    ) -> (circularBuffer: CircularBuffer){
        if (_cb.count != _cb.maxSize) {
            memcpy(_cb.head, _item, _cb.size);
        } else {
            with_attr error_mesage("cannot overwrite") {
                assert _overwrite = 1;
            }
            local buffer: felt*;
            newBuffer(_cb, buffer, _item, 0);
            _cb.buffer = buffer;
        }

        _cb.head = _cb.head + _cb.size;

        if (_cb.head == _cb.tail) {
            _cb.head = _cb.buffer;
        }

        let circularBuffer = CircularBuffer(
            buffer = _cb.buffer,
            bufferEnd = _cb.bufferEnd,
            maxSize = _cb.maxSize,
            count = _cb.count + 1,
            itemSize = _cb.itemSize,
            head = _cb.head,
            tail = _cb.tail
        );
        return (circularBuffer);
    }

    func popFront{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer
    ) -> (circularBuffer: CircularBuffer, item: felt*) {
        if (_cb.count == 0) {
            with_attr error_mesage("nothing to pop") {
                    assert 0 = 1;
            }
        }
        let item: felt* = alloc();
        memcpy(item, _cb.tail, _cb.size);
        _cb.tail = _cb.tail + _cb.size;
        if (_cb.tail == _cb.bufferEnd) {
            _cb.tail = _cb.buffer;
        }
        let circularBuffer = CircularBuffer(
            buffer = _cb.buffer,
            bufferEnd = _cb.bufferEnd,
            maxSize = _cb.maxSize,
            count = _cb.count - 1,
            itemSize = _cb.itemSize,
            head = _cb.head,
            tail = _cb.tail
        );
        return (circularBuffer, item);
    }

    func newBuffer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _cb: CircularBuffer, _newBuffer: felt*, _item: felt, _index: felt
    ) {
        _newBuffer = alloc();
        memcpy(_newBuffer, _cb.buffer, _cb.count);
        assert _newBuffer[_cb.count] = _item;
        memcpy(_newBuffer + _cb.count + 1, _cb.buffer + _cb.count + 1, _cb.maxSize - _cb.count - 1);
    }


}