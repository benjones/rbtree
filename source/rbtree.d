
module rbtree;

import std.stdio;

/**
Self balancing BST

null pointers are black leaves, all value storing nodes are internal nodes

Balance is maintained with these rules:

red nodes can't have red children
black height of all children must be equal (# of black nodes from subtree root to a leaf)


 **/
class RBTree(T) {

    private {
        struct Node {
            Node* left;
            Node* right;
            T data;
            bool red = true;
        }

        Node* root;
        size_t _size;
    }

    bool add(T val){

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
    }

    //fix tree rooted at n and return the new root
    /*
      initially, we might break the no 2-reds-in-a-row rule
      in that case, we must not have a sibling because it would have been black,
      so the black heights would differ

      I think we have to fix stuff at a grandparent node by looking for child/grandchild which are both red
      if n is red when we reach it, unless it's the root, that can't be possible, assuming we fixed stuff below already


     */
    private Node* fixInsert(Node* n){

        if(n.left !is null && n.left.red){
            auto l = n.left;
            if(l.left !is null && l.left.red){
                //zig zig
                assert(n is root || !n.red);
                assert(l.right is null || !l.right.red); //other child must be black
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
                assert(r.left is null || ~r.left.red); //other child must be black

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

    private void rbCheck(){
        if(root is null){
            assert(size == 0);
            return;
        }

        int blackHeight(Node* n){
            if(n is null){ return 0; }
            //            writeln("bh: ", n.data);

            auto lh = blackHeight(n.left);
            auto rh = blackHeight(n.right);
            //            writeln("lh: ", lh, " rh: ", rh);
            assert(lh == rh);
            return lh + (n.red ? 0 : 1);

        }

        void checkRedRule(Node* n){
            if(n is null) return;
            if(n.red){
                assert(n.left is null || !n.left.red);
                assert(n.right is null || !n.right.red);
            }
            checkRedRule(n.left);
            checkRedRule(n.right);

        }

        blackHeight(root); //don't care what it is, but need to check the asserts
        checkRedRule(root);
    }

    private void printInOrder(Node* n){
        if(n is null) return;
        printInOrder(n.left);
        writeln(n.data, "(", n.red, ")");
        printInOrder(n.right);
    }

}


unittest {

    {
        scope tree = new RBTree!int();
        foreach_reverse(i; 0..5){
            writeln("about to insert", i, "before: \n");
            assert(tree.add(i));
            tree.rbCheck();
            assert(tree.contains(i));
        }
    }
    //force zig zags
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 5, 7, 8, 9]){
            writeln("about to insert", x, "before: \n");
            assert(tree.add(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //force zag zigs
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 16, 13, 19, 17]){
            writeln("about to insert", x, "before: \n");
            assert(tree.add(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //force zag zags
    {
        scope tree = new RBTree!int();
        foreach(x; [10, 15, 20, 25, 30]){
            writeln("about to insert", x, "before: \n");
            assert(tree.add(x));
            tree.rbCheck();
            assert(tree.contains(x));
        }
    }

    //stress test
    {
        import std.range: iota;
        import std.algorithm.iteration: permutations;
        writeln("checking all permutations of iota(10)");
        foreach(perm; iota(10).permutations){
            scope tree = new RBTree!int();
            foreach(x; perm){
                assert(tree.add(x));
                tree.rbCheck();
                assert(tree.contains(x));
            }
        }
    }

}
