## Swiftier MultiArray

**WARNING:** This code is highly experimental and some of it plain doesn't work!

Any data that is not images is treated by Core ML as an `MLMultiArray`, a type that can represent arrays with multiple dimensions. Like most Apple frameworks Core ML is written in Objective-C and unfortunately this makes `MLMultiArray` a little awkward to use from Swift. For example, to read from the array you must write:

```swift
let value = multiArray[[z, y, x] as [NSNumber]].floatValue
```

Yech! It's ugly and it's slow since everything gets converted to and from `NSNumber` instances.

CoreMLHelpers has a more Swift-friendly version called just `MultiArray` that lets you do the same as:

```swift
let value = multiArray[z, y, x]
```

To create a multi-array, write:

```swift
var m = MultiArray<Float>(shape: [3, 4, 2])
```

This makes a 3×4×2 array containing floats.

Internally, the data is stored in an `MLMultiArray`, so it's easy to pass the array to Core ML:

```swift
let coreMLArray: MLMultiArray = m.array
// do stuff with coreMLArray
```

You can also create a new multi-array object if you already have an `MLMultiArray`:

```swift
let coreMLArray = try! MLMultiArray(shape: [3, 4, 2], dataType: .double)
var m = MultiArray<Double>(coreMLArray)
```

Note that `MultiArray` uses Swift generics to specify the datatype of the array elements. You can use `Double`, `Float`, and `Int32`.

**Warning:** A new `MLMultiArray` may have junk values in it. If you're going to create an `MLMultiArray` from scratch, then set its values to 0 manually. (A new `MultiArray` from CoreMLHelpers *does* always contain zeros.)

Once you have a multi-array, you can access its elements like so:

```swift
let value = m[1, 2, 0]
```

You can also pass in an array containing the indices:

```swift
let indices = [1, 2, 0]
let value = m[indices]
```

And, of course, you can also modify the array this way:

```swift
m[1, 2, 0] = 3.14
```

**Note:** `MultiArray` is a struct. It's cheap to copy since the underlying data in the `MLMultiArray` is not copied. If you make a copy of a `MultiArray` object, then both instances refer to the same `MLMultiArray`. Modifying the one will also update the other.

To see the contents of the array (for debugging), just print it:

```swift
print(m)

[[[ 0.0, 0.0 ],
  [ 0.0, 0.0 ],
  [ 0.0, 0.0 ],
  [ 0.0, 0.0 ]],
 [[ 0.0, 0.0 ],
  [ 0.0, 0.0 ],
  [ 3.14, 0.0 ],
  [ 0.0, 0.0 ]],
 [[ 0.0, 0.0 ],
  [ 0.0, 0.0 ],
  [ 0.0, 0.0 ],
  [ 0.0, 0.0 ]]]
```

(You probably don't want to do this with really big arrays.)

Indeed the element at index `(1, 2, 0)` is set to 3.14. This is the first column (0) of the third row (2) in the second matrix (1). Notice how the indices appear backward: (matrix, row, column).

Subscripting `MultiArray` is pretty fast since it uses a pointer to the `MLMultiArray`'s internal storage. If you want, you can also use this pointer yourself:

```swift
let ptr = m.pointer
ptr[0] = 2.71828
```

Core ML might give you an `MLMultiArray` that has a shape such as 3×100×150. Maybe you'd like to treat it as 100×150×3 instead. To do this, you can transpose the array:

```swift
let coreMLArray: MLMultiArray = ...  // 3×100×150

var m = MultiArray<Double>(coreMLArray).transposed([1, 2, 0])
print(m.shape)                       // 100×150×3
```

The list `[1, 2, 0]` tells the multi-array to rearrange the dimensions so that the first dimension (0) now becomes the last dimension.

**Note:** Transposing does not change the underlying data in the `MLMultiArray`, only how it is interpreted by `MultiArray` (i.e. only the "strides" change). So if you transpose the array and then pass `m.array` to Core ML, nothing will actually have changed. Therefore transposing is mostly useful for when you take the result of Core ML and then want to interpret it elsewhere in your app.

You can also change the number of dimensions of the array altogether:

```swift
let reshaped = m.reshaped([900, 50])
print(reshaped.shape)
```

This works because 900 × 50 = 3 × 100 × 150, so the number of elements remains the same, but it completely changes how `MultiArray` interprets the array. (Just as with transposing, the underlying `MLMultiArray` does not actually change.)

> **NOTE:** `MultiArray` is still in early stages of development. Over time I want to add more functionality, like you'd find in numpy. Let me know if there is anything in particular you'd like to see added to `MultiArray`.
