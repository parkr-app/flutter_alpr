# Third-party notices

The AlprKit SDK bundles the following third-party components. They are not covered by the Parkr ALPR SDK License Agreement. Each is licensed by its own authors under the terms below.

## OCR model: `cct-xs-v2-global-model`

- Files: `cct-xs-v2-global-model.mlmodelc` (iOS), `models/cct-xs-v2-global-model.tflite` (Android), `ocr_config.json`
- Source: [fast-plate-ocr](https://github.com/ankandrew/fast-plate-ocr), weights from the [cnn-ocr-lp](https://github.com/ankandrew/cnn-ocr-lp/releases/tag/arg-plates) release, converted to Core ML and LiteRT
- License: MIT. The author has stated that both the code and the model weights are MIT and may be used commercially ([fast-alpr#30](https://github.com/ankandrew/fast-alpr/issues/30), [open-image-models#20](https://github.com/ankandrew/open-image-models/issues/20)).

## Plate detection model: `yolo-v9-t-384-license-plate-end2end`

- Files: `yolo-v9-t-384-license-plate-end2end.mlmodelc` (iOS), `models/yolo-v9-t-384-license-plate-end2end.tflite` (Android)
- Source: [open-image-models](https://github.com/ankandrew/open-image-models), weights from its `assets` release, converted to Core ML and LiteRT
- License: the open-image-models code is MIT. The license of these weights is not settled. The author has stated that they were trained with a fork of [WongKinYiu/yolov9](https://github.com/WongKinYiu/yolov9), which is licensed under GPL-3.0, and that he does not know whether the GPL applies to the exported weights ([open-image-models#14](https://github.com/ankandrew/open-image-models/issues/14), [open-image-models#22](https://github.com/ankandrew/open-image-models/issues/22), [fast-alpr#47](https://github.com/ankandrew/fast-alpr/issues/47)). The training data is about 11,000 images collected from the web, mostly from free or open datasets.

If your use requires clear licensing, check with your own legal counsel before shipping this model.

## MIT License text

The MIT-licensed components above are distributed under the following terms:

```
MIT License

Copyright (c) 2024 ankandrew

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
