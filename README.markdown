# CoreMLHelpers

This is a collection of types and functions that make it a little easier to work with Core ML in Swift.

Some of the things CoreMLHelpers has to offer:

- [convert images to `CVPixelBuffer` objects and back](Docs/CVPixelBuffer.markdown)
- [`MLMultiArray` to image conversion](Docs/MultiArray2Image.markdown)
- [handy functions](Docs/HandyFunctions.markdown) to get top-5 predictions, argmax, and so on
- [non-maximum suppression](Docs/NMS.markdown) for bounding boxes

Experimental features:

- [a more Swift-friendly version of `MLMultiArray`](Docs/SwiftyMultiArray.markdown)

Let me know if there's anything else you'd like to see added to this library!

## How to use CoreMLHelpers

Simply add the source files from the **CoreMLHelpers** folder to your project. You probably don't need all of them, so just choose the files you require and ignore the rest.

**Note:** A lot of the code in CoreMLHelpers is only intended as a demonstration of how to approach a certain problem. There's often more than one way to do it. It's quite likely you will need to customize the code for your particular situation, so use these routines as a starting point.

## Read more about Core ML

- [Apple's Machine Learning page](http://developer.apple.com/machine-learning/)
- [machinethink.net/blog](http://machinethink.net/blog)

## TODO

- proper unit tests
- add more numpy-like functionality to `MultiArray` (and fix the bugs!)

## License

CoreMLHelpers is copyright 2017-2018 Matthijs Hollemans and is licensed under the terms of the [MIT license](LICENSE.txt).
