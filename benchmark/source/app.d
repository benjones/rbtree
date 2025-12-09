
void main(string[] args)
{
    if(args.length > 1 && args[1] == "phobos"){
        import std.container.rbtree;
        auto result = benchmark!(RedBlackTree!long);
    } else {
        import rbt.rbtree;
        auto result = benchmark!(RBTree!long);
    }

}


bool benchmark(Tree)(){
    scope t = new Tree;

    const limit = 1_000_000;
    foreach(i; 0L..limit){
        t.insert(i);
    }

    ulong removeCount = 0;
    foreach(i; 0L.. limit){
        removeCount += t.removeKey(i);
    }
    return removeCount == limit;
}
