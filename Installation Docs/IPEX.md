# Intel® Extension for PyTorch

> Intel® Extension for PyTorch* extends PyTorch* with up-to-date features optimizations for an extra performance boost on Intel hardware. Optimizations take advantage of AVX-512 Vector Neural Network Instructions (AVX512 VNNI) and Intel® Advanced Matrix Extensions (Intel® AMX) on Intel CPUs as well as Intel Xe Matrix Extensions (XMX) AI engines on Intel discrete GPUs. Moreover, through PyTorch* xpu device, Intel® Extension for PyTorch* provides easy GPU acceleration for Intel discrete GPUs with PyTorch\*.

## Prerequisites

- PyTorch

## Installation

### CPU version

You can use either of the following 2 commands to install Intel® Extension for PyTorch\* CPU version.

```shell
pip install intel_extension_for_pytorch
```

```shell
pip install intel_extension_for_pytorch -f https://developer.intel.com/ipex-whl-stable-cpu
```

## Benchmarking on Sapphire Rapids (fourth generation Xeon Scalable Intel servers)

Let's use ResNet50 which is a Deep residual networks pre-trained on ImageNet dataset.

### Get the dataset

Lets create directory to store datasets.

```shell
mkdir data
cd data
```

Downloading the datasets. Due to shortage of time and resources. Ill use the validation dataset to inference and quantize the model.

```shell
# Development kit (Task 1 & 2). 2.5MB.
wget https://image-net.org/data/ILSVRC/2012/ILSVRC2012_devkit_t12.tar.gz

# Validation images (all tasks). 6.3GB. MD5: 29b22e2961454d5413ddabcf34fc5622
wget https://image-net.org/data/ILSVRC/2012/ILSVRC2012_img_val.tar
```

You can download the full dataset by

```shell
# Training images (Task 1 & 2). 138GB. MD5: 1d675b47d978889d74fa0da5fadfb00e
wget https://image-net.org/data/ILSVRC/2012/ILSVRC2012_img_train.tar

# Test images (all tasks). 13GB. MD5: e1b8681fff3d63731c599df9b4b6fc02
wget https://image-net.org/data/ILSVRC/2012/ILSVRC2012_img_test_v10102019.tar
```

Refer https://image-net.org for more details.

### Benchmarking

Python Code can be found at https://github.com/krishnashed/ipex/tree/main/resnet50

Without IPEX Optimization

```shell
$ python3 without_ipex.py
Accuracy =  92.2
Time Taken 20.821481244638562
```

FP32 Ipex optimisation

```shell
$ python3 fp32.py
Accuracy =  92.2
Time Taken 9.5928565133363
```

BFloat16 Ipex optimisation

```shell
$ python3 bf16.py
Accuracy =  92.0
Time Taken 4.758904920890927
```

Quantize the Model to INT8

```shell
$ python3 quantize.py
calibrated on batch 0 out of 8
calibrated on batch 1 out of 8
calibrated on batch 2 out of 8
calibrated on batch 3 out of 8
calibrated on batch 4 out of 8
calibrated on batch 5 out of 8
calibrated on batch 6 out of 8
calibrated on batch 7 out of 8
```

INT8 Quantization

```shell
$ python3 int8.py
Accuracy =  91.6
Time Taken 6.051389267668128
```

## References

- https://www.intel.com/content/www/us/en/developer/articles/technical/tuning-guide-for-ai-on-the-4th-generation.html
- https://intel.github.io/intel-extension-for-pytorch/cpu/latest/tutorials/examples.html#inference
- https://pytorch.org/hub/pytorch_vision_resnet/
- https://image-net.org/challenges/LSVRC/2012/2012-downloads.php
- https://pytorch.org/vision/stable/datasets.html
