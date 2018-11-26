# Handy Functions

## Predictions

When using Vision you will receive the model's predictions as an array of `VNClassificationObservation` or `VNCoreMLFeatureValueObservation` objects.

To get the top-5 classification predictions, do:

```swift
if let observations = request.results as? [VNClassificationObservation] {
  let top5 = top(5, observations)
  print(top5)
}
```

If you're using Core ML directly, then classifications are given as a `[String: Double]` dictionary. To get the top 5:

```swift
if let prediction = try? model.prediction(data: pixelBuffer) {
  let top5 = top(5, prediction.classLabelProbs)
  print(top5)
}
```

where `classLabelProbs` is the name of the model's output with the dictionary (this may be different depending on the model).

## MLMultiArray reshaping and transposing

**Reshaping** means you change the `MLMultiArray`'s `shape` so that the dimensions get different sizes. It also lets you add or remove dimensions. However, the actual data stays the same; reshaping is just another way of looking at it.

For example, assume that `multiArray` has a shape of `[1, 3, 200, 150, 1]`. Then you can get rid of these dimensions of size 1 as follows:

```swift
withExtendedLifetime(multiArray) {
  if let reshapedArray = try? multiArray.reshaped(to: [3, 200, 150]) {
    /* do something with the reshaped array */
  }
}
```

Important: The `reshaped()` method returns a new `MLMultiArray` object that uses the data pointer and data type of the original array. The caller is responsible for keeping the original object alive, for example using `withExtendedLifetime`.

**Transposing** or permuting also changes the dimensions, but unlike reshaping actually moves the data around in memory.

For example, given a multi-array of shape `[3, 200, 150]` you could turn it into a `[200, 150, 3]` array by writing:

```swift
if let transposedArray = try? multiArray.transposed(to: [1, 2, 0]) {
  /* do something with the transposed array */
}
```

Note that transposing makes a copy of the data and so you can let the original array be deallocated without problems.

## Other features

New `Array` functions:

- `argmax()`: returns the largest element in the array, as well as its index
- `argsort()`: returns the indices of the array's elements in sorted order
- `gather()`: creates a new array containing the elements at the specified indices

Machine learning math functions:

- `sigmoid()`: logistic sigmoid on scalars or vectors
- `softmax()`
