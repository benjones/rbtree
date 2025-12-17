
module rbt.rbtree;

import std.stdio;
import std.typecons : Tuple, tuple;
import std.conv : to;

/**
Self balancing BST

null pointers are black leaves, all value storing nodes are internal nodes

Balance is maintained with these rules:

red nodes can't have red children
black height of all children must be equal (# of black nodes from subtree root to a leaf)


 **/
class RBTree(T) {


    import rbt.ssostack;
    //"node stack"
    //SSO of 48 is enough to avoid allocation in benchmark adding 1M items
    private alias NS = SSOStack!(Node*, 48);


    private {
        static struct Node {
            Node* left;
            Node* right;
            T data;
            bool red = true;
        }

        Node* root;
        size_t _size;
    }

    bool insert(T val){
        //writeln("\ninsert ", val);
        auto stack = NS.make();

        Node* n = root;
        while(n != null){
            if(val == n.data){
                return false;
            }
            stack.push(n);
            n = (val < n.data) ? n.left : n.right;
        }
        //n is null
        _size++;
        //writeln("stack before writing hooking in new node");
        //NS.writeAsString!(function(x) => to!string(x.data))(stack);

        auto newNode = new Node(null, null, val);

        //as soon as newRoot is black, we know there can't be any red/red violations
        //so stop there
        while(!stack.empty && newNode.red){

            if(newNode.data < stack.peek.data){
                stack.peek.left = newNode;
            } else {
                stack.peek.right = newNode;
            }
            newNode = fixInsert(stack.pop);
        }

        if(stack.empty){
            //writeln("unwound to root");
            root = newNode;
            root.red = false;
        }
        return true;

        // original recursive implementation
        /*

        Node* insert(Node* n){
            if(n is null){
                _size++;
                return new Node(null, null, val);
            } else if(val < n.data){
                n.left = insert(n.left);
            } else {
                n.right = insert(n.right);
            }
            return fixInsert(n); //root didn't change
        }

        const oldSize = _size;
        root = insert(root);
        root.red = false; //make the root black.  This can't break anything
        return _size != oldSize;
        */
    }


    //if returns the node, as well as saying if the BH of this subtree
    //shrunk (deleting can decrease it by 1)
    private struct RemoveResult {
        Node* newRoot;
        bool bhChanged;
    }

    bool removeKey(T val){
        /*writeln("\ntree before removing ", val);
        printInOrder();
        scope(exit){
            writeln("\ntree after removing ", val);
            printInOrder();
            }*/

        auto stack = NS.make();
        auto n = root;

        while(true){
            if(n == null){
                return false; //not found, easy
            }
            stack.push(n);
            if(n.data == val){
                break;
            } else  if(val < n.data){
                n = n.left;
            } else {
                n = n.right;
            }
        }

        //node containing data is at the top of the stack
        n = stack.pop;
        _size--;



        bool isLeft = !stack.empty && n == stack.peek.left;

        void attachToParent(bool isLeft, Node* n){
            if(stack.empty){
                root = n;
            } else if(isLeft){
                stack.peek.left = n;
            } else {
                stack.peek.right = n;
            }
        }

        if(n.left == null){

            //no left child, stick the right child here, which could be null
            attachToParent(isLeft, n.right);

            if(n.red){
                //removed a red node, can't have broken any rules
                return true;
            }
            if(n.right !is null && n.right.red){
                //removed a black node, but can recolor it's only child
                n.right.red = false;
                return true;
            }
            // else, we just decreased the blackHeight of the subtree rooted at n
        } else if(n.right == null){

            //n only has a left child
            attachToParent(isLeft, n.left);

            if(n.red){
                return true;
            }
            if(n.left.red){
                n.left.red = false;
                return true;
            }
        } else {
            //n has 2 children, find predecessor
            stack.push(n);
            auto thiefNode = n;
            n = n.left;
            isLeft = true;
            while(n !is null){
                stack.push(n);
                n = n.right;
                if(n !is null){ //ugly...
                    isLeft = false;
                }
            }
            //steal the data
            auto pred = stack.pop;

            thiefNode.data = pred.data;

            //now delete the predecessor, which might have a left child
            //but can't have a right child
            if(isLeft){
                assert(stack.peek.left == pred);
                stack.peek.left = pred.left;
            } else {
                assert(stack.peek.right == pred);
                stack.peek.right = pred.left;
            }

            if(pred.red){
                return true;
            } else if(pred.left !is null && pred.left.red){
                // pred was black.  If it's stolen side was red,
                // make it black to make the fix easy.
                pred.left.red = false;
                return true;
            }
        }
        //at this point the stack stores the path from the root
        //to the removed node, and we need to fix a RB property at this point
        if(stack.empty){
            //tree must be empty
            root = null;
            return true;
        }

        //black height must have changed if we got here.
        n = stack.pop; //fix it 1 level up

        //fix it
        auto fixedN = isLeft ?
            fixDelete!true(RemoveResult(n, true)) :
            fixDelete!false(RemoveResult(n, true));

        isLeft = !stack.empty && stack.peek.left == n;
        n = fixedN.newRoot;
        bool bhChanged = fixedN.bhChanged;

        if(!stack.empty){
            if(isLeft){ stack.peek.left = n; }
            else { stack.peek.right = n; }
        }


        while(!stack.empty && (bhChanged || n.red)){
            if(isLeft){
                stack.peek.left = n;
            } else {
                stack.peek.right = n;
            }

            n = stack.pop;


            auto result = isLeft ?
                fixDelete!true(RemoveResult(n, bhChanged)):
                fixDelete!false(RemoveResult(n, bhChanged));

            bhChanged = result.bhChanged;
            isLeft = !stack.empty && stack.peek.left == n;
            n = result.newRoot;
        }

        if(stack.empty){
            root = n;
            root.red = false;
        }

        return true;



        //remove val from subtree rooted at n and return its new root
        /+ old recursive implementation
        RemoveResult remove(Node* n, T val){
            /*if(n !is null){
                write("recursive remove ", val, " from subtree rooted at ");
                writeln(n.data);
            }
            scope(exit){ write("finished recursive remove ", val, " from subtree rooted at ");
                writeln(n.data);
                writeln("subtree: ");
                printInOrder(n);
                }*/
            if(n is null){ return RemoveResult(null, false); }
            if(n.data == val){
                if(n.left == null){
                    _size--;
                    //if we caused a problem by removing a black node, we can't
                    //fix it here unless we can just recolor a red child
                    //hooray, no more issues!
                    if(!n.red && n.right !is null && n.right.red){
                        n.right.red = false;
                        return RemoveResult(n.right, false);
                    }
                    //otherwise fix problems up the tree if we have to (no problem if n was red)
                    return RemoveResult(n.right, !n.red);
                }
                if(n.right == null){
                    _size--;
                    assert(n.left);
                    if(!n.red && n.left.red){
                        n.left.red = false;
                        return RemoveResult(n.left, false);
                    }
                    //again, if we deleted a black node, we can't fix the issue here
                    return RemoveResult(n.left, !n.red); //1 child
                } else {
                    auto pred = n.left;
                    while(pred.right !is null){ pred = pred.right; }
                    n.data = pred.data;
                    auto leftResult = remove(n.left, pred.data);
                    n.left = leftResult.newRoot;
                    return fixDelete!true(RemoveResult(n, leftResult.bhChanged));
                }
            }
            if(val < n.data){
                auto result = remove(n.left, val);
                n.left = result.newRoot;
                return fixDelete!true(RemoveResult(n, result.bhChanged));
            } else {
                auto result = remove(n.right, val);
                n.right = result.newRoot;
                return fixDelete!false(RemoveResult(n, result.bhChanged));
            }
        }
        const oldSize = _size;
        root = remove(root, val).newRoot;
        if(root !is null){
            root.red = false;  //make the root black
        }
        return _size != oldSize;
    +/
    }


    //fix any issues caused by removing a node from somewhere in this subtree
    //we might have decreased the black height (n.bhChanged) or
    //at some point caused 2 red nodes to be adjacent
    //Note, even if we can detect a problem here, we might not fix it if
    //the parent of n.newRoot needs to be changed to fix it
    private RemoveResult fixDelete(bool leftChanged)(RemoveResult n){
        /*writeln("fixDelete of ", n.newRoot.data, " red ? ", n.newRoot.red,
                 " bh changed? ", n.bhChanged, " left changed ", leftChanged);
        scope(exit){
            writeln("finished fixDelete at ", n.newRoot.data, " tree: ");
            printInOrder();
            }*/
        //if bh changed, the changedSide subtree must have a black root
        auto changedChild = leftChanged ? n.newRoot.left : n.newRoot.right;
        assert((n.bhChanged && (changedChild is null || !changedChild.red)) ||
               !n.bhChanged); //if BH didn't change, could be either color

        if(!n.bhChanged){
            //only violaion can be Red/Red issue, which the fixInsert
            //code already handles
            return RemoveResult(fixInsert(n.newRoot), false);
        } else { //bh of left or right child has decreased by 1
            if(n.newRoot.red){
                //easy fix!
                n.newRoot.red = false;
                //the unchanged child must have been black before
                //push the red there.  That might cause a red-red case
                //so call insert fix to fix it
                static if(leftChanged){
                    assert(n.newRoot.right && !n.newRoot.right.red);
                    n.newRoot.right.red = true;
                } else {
                    assert(n.newRoot.left && !n.newRoot.left.red);
                    n.newRoot.left.red = true;
                }
                return RemoveResult(fixInsert(n.newRoot), false);

            } else { //n.newroot is black
                static if(leftChanged){
                    auto oppChild = n.newRoot.right;
                    auto modChild = n.newRoot.left;
                } else {
                    auto oppChild = n.newRoot.left;
                    auto modChild = n.newRoot.right;
                }

                //if BH had changed, and we had a red root, we would have made
                //the root black to fix it
                assert(modChild is null || !modChild.red);

                if(oppChild.red){
                    // rotate the opposite child up, since
                    // the changedSide is too short.  This moves newRoot which was black
                    // to that side
                    static if(leftChanged){
                        auto midGC = oppChild.left;
                        oppChild.left = n.newRoot;
                        n.newRoot.right = midGC;
                    } else {
                        auto midGC = oppChild.right;
                        oppChild.right = n.newRoot;
                        n.newRoot.left = midGC;
                    }
                    //now the oppChild is the new root, and is red, but midGC makes our
                    //side too tall... so fix it

                    assert(!midGC.red); //it's parent was red, so it can't be
                    midGC.red = true;

                    //might have caused red/red at midGC + its child
                    //fix it at n.newRoot which is its parent
                    // fixInsert will work even if both of midGC's children were red
                    auto fixed = fixInsert(n.newRoot);

                    static if(leftChanged){
                        oppChild.left = fixed;
                    } else {
                        oppChild.right = fixed;
                    }

                    //oppChild is the new root.  It WAS red, if we make it black the tree height
                    //will be what it was before.  Fix a potential red/red problem, and return all good
                    oppChild.red = false;
                    return RemoveResult(fixInsert(oppChild), false);

                } else { //opChild is black
                    //if the opposite subtree root was black:
                    //   make it red to even the subtrees, then use fixInsert
                    //   to fix up a potential red-red situation there.  now this tree
                    //   is OK, but has reduced BH

                    oppChild.red = true;
                    auto fixed = fixInsert(n.newRoot);
                    if(fixed.red){
                        fixed.red = false;
                        //black height resolved itself... nice!
                        return RemoveResult(fixed, false);
                    } else {
                        //still gotta fix the black height
                        return RemoveResult(fixed, true);
                    }
                }
            }

        }
    }


    //fix tree rooted at n and return the new root
    /*
      initially, we might break the no 2-reds-in-a-row rule
      in that case, we must not have a sibling because it would have been black,
      so the black heights would differ

      I think we have to fix stuff at a grandparent node by looking for child/grandchild which are both red
      if n is red when we reach it, unless it's the root, that can't be possible, assuming we fixed stuff
      below already


     */
    private Node* fixInsert(Node* n){
        /*writeln("fixing insert at ", n.data, " tree: ");
        printInOrder(n);
        scope(exit){
            writeln("finished fixing insert at ", n.data, " tree: ");
            printInOrder();
            }*/

        if(n.left !is null && n.left.red){
            auto l = n.left;
            if(l.left !is null && l.left.red){
                //zig zig
                assert(n is root || !n.red);

                //assert(l.right is null || !l.right.red); //other child must be black
                //NOT IF WE'RE DELETING!

                //rotate l, and move n to be its right child
                //n must have been black
                //pull n.left up, make it red, then make
                //its new children both black.  This won't change the black height of nodes above
                auto newRoot = l;
                n.left = l.right;
                newRoot.right = n;
                assert(newRoot.red); //must already be red
                //only necessary if n was the root, although we probably did make the root black already
                n.red = false;
                //the old left child was red before, and needs to be changed to black now
                newRoot.left.red = false;
                return newRoot;
            } else if(l.right !is null && l.right.red){
                //zig zag
                auto newRoot = l.right;

                l.right = newRoot.left;
                n.left = newRoot.right;

                newRoot.left = l;
                newRoot.right = n;

                l.red = false;
                n.red = false; //probably already was, but no harm in reassigning

                return newRoot;

            }

        }
        if(n.right !is null && n.right.red){
            auto r = n.right;
            if(r.right !is null && r.right.red){
                //zag zag

                assert(n is root || !n.red);

                //assert(r.left is null || !r.left.red); //other child must be black
                //NOT IF WE'RE DELETING!

                auto newRoot = r;
                n.right = r.left;
                newRoot.left = n;
                assert(newRoot.red); //must already be red
                n.red = false; //probably was already black
                newRoot.right.red = false; //grandchild was red, must be black now
                return newRoot;

            } else if(r.left !is null && r.left.red){
                //zag zig
                auto newRoot = r.left;

                r.left = newRoot.right;
                n.right = newRoot.left;

                newRoot.left = n;
                newRoot.right = r;

                r.red = false;
                n.red = false; //should already have been black

                return newRoot;
            }
        }

        return n;
    }

    bool contains(T val){
        Node* n = root;
        while(n !is null){
            if(n.data == val){ return true; }
            if(val < n.data){ n = n.left; }
            else { n = n.right; }
        }
        return false;
    }

    auto size() const { return _size; }


    Range opSlice(){
        return Range(root);
    }

    //range implementation

    private struct Range{
        auto stack = NS.make();

        @disable this();

        this(ref Range other){
            stack = NS(cast(NS)other.stack);
        }

        this(Node* root){
            Node* curr = root;
            while(curr !is null){
                stack.push(curr);
                curr = curr.left;
            }
            //writeln("stack after constructor");
            //writeln(stack);
            //writeln("top: ", stack.peek.data);
        }

        T front(){
            //writeln("front: ", stack.peek.data);
            return stack.peek.data;
        }

        bool empty(){
            return stack.empty;
        }

        void popFront(){
            //writeln("popFront, statck top: ", stack.peek.data);
            //writeln(stack);
            auto prev = stack.peek();
            //must be in the middle of the in-order traversal
            if(prev.right !is null){
                //writeln("traverse right");
                //trace down to the left
                auto curr = prev.right;
                while(curr !is null){
                    stack.push(curr);
                    curr = curr.left;
                }
            } else {
                while(!stack.empty){
                    //writeln("moving up from ", stack.peek.data);
                    prev = stack.pop();
                    if(stack.empty){ return; }//prev was the root, so we're done
                    if(prev == stack.peek.right){
                        continue; //
                    } else {
                        assert(prev == stack.peek.left);
                        //prev was left child, new top is the next
                        return; //done
                    }
                }
            }
        }
    }




    public void rbCheck(){
        if(root is null){
            assert(size == 0);
            return;
        }

        blackHeight(root); //don't care what it is, but need to check the asserts
        checkRedRule(root);
    }

    private int blackHeight(Node* n){
        if(n is null){ return 0; }
        //writeln("bh: ", n.data);

        auto lh = blackHeight(n.left);
        auto rh = blackHeight(n.right);
        //writeln("lh: ", lh, " rh: ", rh);
        assert(lh == rh);
        return lh + (n.red ? 0 : 1);

    }

    private void checkRedRule(Node* n){
        if(n is null) return;
        if(n.red){
            assert(n.left is null || !n.left.red);
            assert(n.right is null || !n.right.red);
        }
        checkRedRule(n.left);
        checkRedRule(n.right);

    }

    private void printInOrder(Node* n){
        if(n is null) return;
        printInOrder(n.left);
        writeln(n.data, "(", n.red, ")");
        printInOrder(n.right);
    }

    public void printInOrder(){

        import std.conv: to;
        if(root is null){
            writeln("empty tree");
            return;
        }
        writeln("tree root is: ", root.data);
        writeln("root.left: ", root.left ? to!string(root.left.data) : "null",
                " root.right: ", root.right ? to!string(root.right.data) : "null");
        printInOrder(root);
    }

}


unittest {

    {
        scope tree = new RBTree!int();
        foreach_reverse(i; 0..5){
            //writeln("about to insert ", i, " before: \n");
            //tree.printInOrder();
            assert(tree.insert(i));
            tree.rbCheck();
            assert(tree.contains(i));
        }
    }
    //force zig zags
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 5, 7, 8, 9]){
            //writeln("about to insert", x, "before: \n");
            assert(tree.insert(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //force zag zigs
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 16, 13, 19, 17]){
            //writeln("about to insert", x, "before: \n");
            assert(tree.insert(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //force zag zags
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 15, 20, 25, 30]){
            //writeln("about to insert", x, "before: \n");
            assert(tree.insert(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //stress test
    {
        import std.range: iota;
        import std.algorithm.iteration: permutations;
        import std.random : randomShuffle, Random;
        import std.array;
        import std.parallelism: parallel;

        //got it to pass with limit = 11 in ~1 minute
        const limit = 9;        //TODO BUMP UP TO 10!
        auto rnd = Random(42);

        //writeln("checking all permutations of iota(", limit,")");


        auto removeOrder = iota(limit).array;
        foreach(perm; iota(limit).permutations){

            //writeln("perm: ", perm);
            scope tree = new RBTree!int();
            foreach(x; perm){
                assert(tree.insert(x));
                tree.rbCheck();
                assert(tree.contains(x));
                //tree.printInOrder;
            }
            //remove them in a random order
            removeOrder.randomShuffle(rnd);
            //writeln("remove order: ", removeOrder);
            ulong size = limit;
            foreach(x; removeOrder){
                //writeln("about to remove ", x);
                assert(tree.removeKey(x));
                size--;
                assert(tree.size == size);
                tree.rbCheck();
                //tree.printInOrder();
            }
            assert(tree.size == 0);
        }
    }

}

//delete
unittest {
    import std.range : iota;
    //writeln("remove tests");
    scope tree = new RBTree!int();
    foreach(x; iota(10)){
        tree.insert(x);
    }
    foreach(x; iota(10)){
        // tree.printInOrder();
        //writeln("removing ", x);
        assert(tree.removeKey(x));
        assert(!tree.contains(x));
        tree.rbCheck();
    }

}

//delete, but delete stuff in backwards order
unittest {
    import std.range : iota;
    //writeln("remove tests part 2");
    scope tree = new RBTree!int();
    foreach(x; iota(10)){
        tree.insert(x);
    }
    foreach_reverse(x; iota(10)){
        //        tree.printInOrder();
        //        writeln("removing ", x);
        assert(tree.removeKey(x));
        assert(!tree.contains(x));
        tree.rbCheck();
    }

}

private void fillAndClear(int[] insert, int[] remove){
    import std.stdio;
    import std.array;
    import std.algorithm: sort, equal;
    import std.range: iota;

    scope tree = new RBTree!int;
    foreach(x; insert){
        assert(tree.insert(x));
        tree.rbCheck();
        //this assumes insert is a permutation of 0..N
        //tree.printInOrder();
    }

    auto asArray = tree[].array;
    sort(asArray);
    assert(equal(iota(insert.length), asArray));

    //tree.printInOrder();
    foreach(x; remove){
        //writeln("removing ", x);
        assert(tree.removeKey(x));
        tree.rbCheck();
        //if(tree.size > 0){
        //  tree.printInOrder();
        //}
    }

}

//specific permutations that caused problems at some point or another
unittest {
    fillAndClear( [4,3,1,0,2,5,6],  [4,5,6,0,3,2,1]);
}

unittest {
    fillAndClear([1, 0, 2, 3, 4, 5, 6, 7],
        [4, 0, 7, 3, 1, 2, 5, 6]);
}
