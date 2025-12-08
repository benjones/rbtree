module ssostack;

//for a RB tree, this is the height we can handle in a range
//without heap allocating for the range/iterator
struct SSOStack(T, size_t capacity = 16) {

 private:
    T[capacity] backing = void;
    T[] data; //interior slice/pointer potentially, danger zone!

 public:
    @disable this(this);
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

    T peek() const { return data[$-1]; }

    size_t size() const {
        return data.length;
    }

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
    static assert(!__traits(compiles, {auto t = s;}));

    static void f1(S4 byVal){}

    static assert(!__traits(compiles, {f1(s);}));
}
