module rbt.ssostack;

import std.stdio;

//for a RB tree, this is the height we can handle in a range
//without heap allocating for the range/iterator
//Create with SSOStack.make() to initialize the data slice
//
struct SSOStack(T, size_t capacity = 16) {

 private:
    T[capacity] backing = void;
    T[] data; //interior slice/pointer potentially, danger zone!

 public:

    @disable this();

    private this(void* dummy){
        data[] = backing[0..0];
    }

    static SSOStack make(){
        return SSOStack(null);
    }


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
        //writeln("push: size: ", size);
        //unnecessary now that we have the `make` function
        /*if(!data){
            data = backing[0 .. 0];
            }*/
        if(size < capacity){
            data = backing[0 .. data.length + 1];
            data[$-1] = t;
        } else {
            //writeln("push: size > cap: ", size);
            data ~= t;
            //assert(false);
        }
    }

    T pop(){
        //writeln("pop: size: ", size);
        auto ret = data[$-1];
        if(size == capacity + 1){
            //shrink from heap
            backing[0 .. capacity] = data[0 .. capacity];
            data = backing[0 .. $];
        } else {
            data = data[0 .. $ -1];
        }
        return ret;
    }

    ref T peek() { return data[$-1]; }

    size_t size() const { return data.length; }

    bool empty() const { return size == 0; }

    static void writeAsString(alias Mapper)(const ref SSOStack stack) {
        import std.algorithm.iteration: joiner, map;
        import std.stdio;

        writeln("Stack[ ", stack.data.map!(x => Mapper(x)).joiner(", "), "]");
    }
}


unittest {

    auto stack =  SSOStack!(int, 4).make();
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
    auto s = S4.make();
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
