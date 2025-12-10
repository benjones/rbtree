module rbt.ssostack;

//for a RB tree, this is the height we can handle in a range
//without heap allocating for the range/iterator
struct SSOStack(T, size_t capacity = 16) {

 private:
    T[capacity] backing = void;
    T[] data; //interior slice/pointer potentially, danger zone!

 public:

    this(ref SSOStack other){
        if(data.length > capacity){
            data = cast(T[])other.data.dup;
        } else {
            backing[] = other.backing[];
            data = backing[0..other.data.length];
        }
    }

    @disable this(SSOStack);

    void push(T t){
        if(!data){
            data = backing[0 .. 0];
        }
        if(size < capacity){
            data = backing[0 .. data.length + 1];
            data[$-1] = t;
        } else {
            data ~= t;
        }
    }

    T pop(){
        auto ret = data[$-1];
        if(size == capacity + 1){
            //shrink from heap
            backing[0 .. capacity] = data[0 .. capacity];
        } else {
            data = data[0 .. $ -1];
        }
        return ret;
    }

    ref T peek() { return data[$-1]; }

    size_t size() const { return data.length; }

    bool empty() const { return size == 0; }

}


unittest {

    SSOStack!(int, 4) stack;
    foreach(i; 0..10){
        stack.push(i);
        assert(stack.peek == i);
        assert(stack.size == i+1);
    }

    foreach_reverse(i; 10..0){
        assert(stack.size == i);
        assert(stack.peek == (i - 1));
        assert(stack.pop() == (i -1));
        assert(stack.size == (i - 1));
    }
}

unittest {
    alias S4 = SSOStack!(int, 4);
    S4 s;
    s.push(1);
    S4 s2 = s;
    assert(s.size == 1);
    assert(s2.size == 1);

    assert(s.pop == 1);
    assert(s2.peek == 1);
    assert(s2.pop == 1);
    assert(s.empty);
    assert(s2.empty);

}
