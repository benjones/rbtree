as of commit b8218c8d5a28c8ca14f94b95e9cc33832c91b905

```
dub build --build=release :benchmark && hyperfine --warmup 3 "benchmark/rbtree_benchmark phobos"
    Starting Performing "release" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
Benchmark 1: benchmark/rbtree_benchmark phobos
  Time (mean ± σ):     120.2 ms ±   1.2 ms    [User: 110.7 ms, System: 8.5 ms]
  Range (min … max):   116.9 ms … 121.9 ms    24 runs
  ```
  ```
  dub build --build=release :benchmark && hyperfine --warmup 3 --show-output "benchmark/rbtree_benchmark"
    Starting Performing "release" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
Benchmark 1: benchmark/rbtree_benchmark
  Time (mean ± σ):     399.3 ms ±   5.7 ms    [User: 390.5 ms, System: 7.7 ms]
  Range (min … max):   392.7 ms … 411.0 ms    10 runs
  ```
  
  As of commit 529acd19e651d8271aeb0a2f81a5c3d4ddb504c
 ``` 
  dub build --build=release :benchmark && hyperfine --warmup 3  "benchmark/rbtree_benchmark"
    Starting Performing "release" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~iterateInsert: building configuration [application]
     Linking rbtree_benchmark
Benchmark 1: benchmark/rbtree_benchmark
  Time (mean ± σ):     374.2 ms ±   3.2 ms    [User: 364.4 ms, System: 8.4 ms]
  Range (min … max):   369.0 ms … 380.0 ms    10 runs
  ```
  
  As of commit 09c0825b4a868efdae80843b6b9b94b1434e7651
  ```
   dub build --build=release :benchmark && hyperfine --warmup 3  "benchmark/rbtree_benchmark"
    Starting Performing "release" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
Benchmark 1: benchmark/rbtree_benchmark
  Time (mean ± σ):     225.4 ms ±   2.7 ms    [User: 218.1 ms, System: 6.0 ms]
  Range (min … max):   221.8 ms … 231.7 ms    13 runs
  ```