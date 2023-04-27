# Performance Benefits of Intel(R) Extension for Scikit-learn

> Intel(R) Extension for Scikit-learn is a seamless way to speed up your Scikit-learn application

## Prerequisites

- Anaconda

## Setup

Creating Conda environment

```shell
conda create -n optimised-scikit-learn -c conda-forge python=3.9 scikit-learn-intelex

# Activate conda environment
conda activate scikit-learn-intelex
```

Get the Notebooks to test different algorithms against workloads

```shell
git clone https://github.com/intel/scikit-learn-intelex.git

# cd into the notebooks directory
cd scikit-learn-intelex/examples/notebooks
```

Convert the IPYNB files into .py files, or clone the repo https://github.com/krishnashed/Intel-Optimized-Models.git which has all IPYNB files converted to .py scripts

## Results

### Linear Regression

```shell
$ python linear_regression.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 0.09 s
Patched Scikit-learn MSE: 0.7718488574028015
Original Scikit-learn time: 1.22 s
Original Scikit-learn MSE: 0.7716856598854065
Get speedup in 13.5 times
```

### Lasso Regression

```shell
$ python lasso_regression.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 0.11 s
Patched Scikit-learn MSE: 0.967659592628479
Original Scikit-learn time: 3.87 s
Original Scikit-learn MSE: 0.9676599502563477
Get speedup in 35.1 times.
```

### KMeans

```shell
$ python kmeans.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 35.60 s
Intel® extension for Scikit-learn inertia: 13346.834638940036
Intel® extension for Scikit-learn number of iterations: 213
Original Scikit-learn time: 100.00 s
Original Scikit-learn inertia: 13352.813785961605
Original Scikit-learn number of iterations: 212
Get speedup in 2.8 times
```

### KNeighborsClassifier

```shell
$ python knn_mnist.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Classification report for Intel® extension for Scikit-learn KNN:
              precision    recall  f1-score   support

           0       0.97      0.99      0.98      1365
           1       0.93      0.99      0.96      1637
           2       0.99      0.94      0.96      1401
           3       0.96      0.95      0.96      1455
           4       0.98      0.96      0.97      1380
           5       0.95      0.95      0.95      1219
           6       0.96      0.99      0.97      1317
           7       0.94      0.95      0.95      1420
           8       0.99      0.90      0.94      1379
           9       0.92      0.94      0.93      1427

    accuracy                           0.96     14000
   macro avg       0.96      0.96      0.96     14000
weighted avg       0.96      0.96      0.96     14000


Classification report for original Scikit-learn KNN:
              precision    recall  f1-score   support

           0       0.97      0.99      0.98      1365
           1       0.93      0.99      0.96      1637
           2       0.99      0.94      0.96      1401
           3       0.96      0.95      0.96      1455
           4       0.98      0.96      0.97      1380
           5       0.95      0.95      0.95      1219
           6       0.96      0.99      0.97      1317
           7       0.94      0.95      0.95      1420
           8       0.99      0.90      0.94      1379
           9       0.92      0.94      0.93      1427

    accuracy                           0.96     14000
   macro avg       0.96      0.96      0.96     14000
weighted avg       0.96      0.96      0.96     14000


Get speedup in 2.3 times.
```

### Ridge Regression

```shell
$ python ridge_regression.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 0.21 s
Patched Scikit-learn MSE: 1.0014288520707861
Original Scikit-learn time: 0.55 s
Original Scikit-learn MSE: 1.0014288520708057
Get speedup in 2.6 times.
```

### SVC

```shell
$ python svc.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 145.19 s
Classification report for Intel® extension for Scikit-learn SVC:
              precision    recall  f1-score   support

        -1.0       0.87      0.90      0.88      7414
         1.0       0.64      0.58      0.61      2355

    accuracy                           0.82      9769
   macro avg       0.76      0.74      0.75      9769
weighted avg       0.82      0.82      0.82      9769


Original Scikit-learn time: 665.91 s
Classification report for original Scikit-learn SVC:
              precision    recall  f1-score   support

        -1.0       0.87      0.90      0.88      7414
         1.0       0.64      0.58      0.61      2355

    accuracy                           0.82      9769
   macro avg       0.76      0.74      0.75      9769
weighted avg       0.82      0.82      0.82      9769


Get speedup in 4.6 times.
```

### ElasticNet

```shell
$ python ElasticNet.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 0.38 s
Patched Scikit-learn MSE: 1.0109113399224974
Original Scikit-learn time: 10.37 s
Original Scikit-learn MSE: 1.0109113399545735
Get speedup in 27.5 times.
```

### NuSVR

```shell
$ python nusvr_medical_charges.py

Intel(R) Extension for Scikit-learn* enabled (https://github.com/intel/scikit-learn-intelex)
Intel® extension for Scikit-learn time: 21.04 s
Intel® extension for Scikit-learn R2 score: 0.8635961795898657
Original Scikit-learn time: 400.37 s
Original Scikit-learn R2 score: 0.8636031741516902
Get speedup in 19.0 times.
```

Table of contents

|      Algorithm       |      Workload       |      Task      |                                                                 Notebook                                                                 |                                                          Scikit-learn estimator                                                           |
| :------------------: | :-----------------: | :------------: | :--------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------: |
|  LogisticRegression  |      CIFAR-100      | Сlassification | [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/logistictic_regression_cifar.ipynb) | [sklearn.linear_model.LogisticRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html) |
|         SVC          |        Adult        | Сlassification |          [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/svc_adult.ipynb)           |                         [sklearn.svm.SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html)                         |
| KNeighborsClassifier |        MNIST        | Сlassification |          [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/knn_mnist.ipynb)           |  [sklearn.neighbors.KNeighborsClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html)  |
|        NuSVR         |   Medical charges   |   Regression   |    [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/nusvr_medical_charges.ipynb)     |                       [sklearn.svm.NuSVR](https://scikit-learn.org/stable/modules/generated/sklearn.svm.NuSVR.html)                       |
|        Ridge         |  Airlines DepDelay  |   Regression   |       [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/ridge_regression.ipynb)       |              [sklearn.linear_model.Ridge](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.Ridge.html)              |
|      ElasticNet      |  Airlines DepDelay  |   Regression   |          [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/ElasticNet.ipynb)          |         [sklearn.linear_model.ElasticNet](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.ElasticNet.html)         |
|        Lasso         |  YearPredictionMSD  |   Regression   |       [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/lasso_regression.ipynb)       |              [sklearn.linear_model.Lasso](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.Lasso.html)              |
|  Linear Regression   |  YearPredictionMSD  |   Regression   |      [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/linear_regression.ipynb)       |   [sklearn.linear_model.LinearRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LinearRegression.html)   |
|        KMeans        | Spoken arabic digit |   Clustering   |            [View source on GitHub](https://github.com/intel/scikit-learn-intelex/blob/master/examples/notebooks/kmeans.ipynb)            |                  [sklearn.cluster.KMeans](https://scikit-learn.org/stable/modules/generated/sklearn.cluster.KMeans.html)                  |
