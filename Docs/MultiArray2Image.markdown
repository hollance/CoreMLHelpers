# MLMultiArray to image conversion

If the Core ML model outputs an `MLMultiArray` that is really an image, CoreMLHelpers makes it easy to convert the multi-array into a `UIImage`:

```swift
let multiArray: MLMultiArray = ...
let image: UIImage = multiArray.image(min: 0, max: 255)
```

The multi-array is expected to have the shape **(channels, height, width)** for color images or **(height, width)** for grayscale images. 

If your `MLMultiArray` has a shape that is something like (1, 1, height, width, 3) then you have two options:

1. Manually reshape and transpose the array. CoreMLHelpers has [some functions for this](HandyFunctions.markdown).
2. Pass in an `axes` argument. This tells the `image()` function which dimensions from the array represent the color channels, height, and width.

The `axes` argument is a tuple that always takes three values: (channel axis, height axis, width axis). For the given example of (1, 1, height, width, 3), you would use `axes: (4, 2, 3)` to map the last dimension (4) to the channels, dimension 2 to the height, and dimension 3 to the width of the image:

```swift
let multiArray: MLMultiArray = ...
let image: UIImage = multiArray.image(min: 0, max: 255, axes: (4, 2, 3))
```

If a channels dimension is present in the `MLMultiArray`, the following is possible:

- 1 channel: the image is grayscale
- 3 channels: the image is RGB
- 4 channels: the image is RGBA
- for any other number of channels: you can supply a `channel` parameter to convert just that particular channel to a grayscale image

The `min` and `max` parameters are used to put the values from the multi-array into the range [0, 255]. For example, if the range of the data is [-1, 1], use `min: -1` and `max: 1`. The min values will be mapped to 0, the max values to 255, and everything else somewhere in between.

## Fast version

If your `MLMultiArray` has the shape **(3, height, width)** and has the data type `FLOAT32` then you can use the vImage framework to do a very fast array-to-image conversion. It's easily 10 times faster than the other method.

This is implemented in the `createUIImage(fromFloatArray)` function:

```swift
let multiArray: MLMultiArray = ...
let image = createUIImage(fromFloatArray: multiArray, min: 0, max: 255)
```

This function returns a `UIImage` object, but you can easily change it to do additional image processing with vImage, or convert the image to a `CVPixelBuffer` or other type of image object.
