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
  
  As of commit  e3d76e1e0c09962ac90519d3930d305c397e10ec
  
  ```
  dub build --build=release-debug :benchmark && hyperfine --warmup 3  "benchmark/rbtree_benchmark"
    Starting Performing "release-debug" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
Benchmark 1: benchmark/rbtree_benchmark
  Time (mean ± σ):     204.7 ms ±   3.0 ms    [User: 198.0 ms, System: 5.8 ms]
  Range (min … max):   200.8 ms … 209.4 ms    14 runs
  ```
  
  Delete was broken and some pieces of the tree were lost during delete operations...  Fixed as of  d28064be7769a10ab399e754ad3aed0609e5ebd4
  
  Results:
  
  ```
  dub build --build=release-debug :benchmark && hyperfine --warmup 3  "benchmark/rbtree_benchmark phobos"
    Starting Performing "release-debug" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
clang: warning: overriding deployment version from '16' to '26.0' [-Woverriding-deployment-version]
Benchmark 1: benchmark/rbtree_benchmark phobos
  Time (mean ± σ):     118.8 ms ±   1.6 ms    [User: 110.6 ms, System: 7.3 ms]
  Range (min … max):   116.2 ms … 122.4 ms    24 runs

/Users/ben/projects/dlang/rbtree $ dub build --build=release-debug :benchmark && hyperfine --warmup 3  "benchmark/rbtree_benchmark"
    Starting Performing "release-debug" build using ldc2 for aarch64, arm_hardfloat.
    Building rbtree:benchmark ~main: building configuration [application]
     Linking rbtree_benchmark
clang: warning: overriding deployment version from '16' to '26.0' [-Woverriding-deployment-version]
Benchmark 1: benchmark/rbtree_benchmark
  Time (mean ± σ):     277.5 ms ±   1.7 ms    [User: 269.1 ms, System: 7.1 ms]
  Range (min … max):   274.9 ms … 280.3 ms    10 runs
  ```
  
  Remove is 43ms in phobos, 40ms in mine.  Yay!!!
  
  Insert is 130ms in mine, 71ms in phobos (boooo)