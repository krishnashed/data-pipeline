# Installing CVAT using Docker Compose

> Computer Vision Annotation Tool (CVAT) is an interactive video and image annotation tool for computer vision.

## Prerequisites

- Dockers and Docker Compose plugin.

## Installing CVAT

### Cloning CVAT's Repo

```shell
git clone https://github.com/opencv/cvat
cd cvat
```

### Deploying CVAT

To bring up cvat with auto annotation tool, from cvat root directory, we need to run:

```shell
docker compose -f docker-compose.yml -f components/serverless/docker-compose.serverless.yml up -d
```

Creating superuser who can use an admin panel to assign the correct groups to the user.

```shell
docker exec -it cvat_server bash -ic 'python3 ~/manage.py createsuperuser'
```

Now we will be able to access CVAT UI at `http://localhost:8080/` with the credentials created.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-1.png"/>
</div>

Install `nuctl` command line tool to build and deploy serverless functions.

```shell
wget https://github.com/nuclio/nuclio/releases/download/1.8.14/nuctl-1.8.14-linux-amd64
```

After downloading the nuclio, give it a proper permission and do a softlink.

```shell
sudo chmod +x nuctl-1.8.14-linux-amd64
sudo ln -sf $(pwd)/nuctl-1.8.14-linux-amd64 /usr/local/bin/nuctl
```

Creating `cvat` project where we will deploy new serverless functions and deploy a couple of DL models.

```shell
nuctl create project cvat
```

The created project can be viewed at `http://localhost:8070/projects`

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-2.png"/>
</div>

Deploying models under the project

```shell
nuctl deploy --project-name cvat \
  --path serverless/openvino/dextr/nuclio \
  --volume `pwd`/serverless/common:/opt/nuclio/common \
  --platform local
```

```shell
nuctl deploy --project-name cvat \
  --path serverless/openvino/omz/public/yolo-v3-tf/nuclio \
  --volume `pwd`/serverless/common:/opt/nuclio/common \
  --platform local
```

The deployed serverless functions:

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-3.png"/>
</div>

### Annotation using CVAT UI

Creating a Task

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-4.png"/>
</div>

Fill details like `Task Name`, `Project Name`, Adding `Labels` and Input `Image(s)/Video`. Then choose `Submit & Open` to proceed.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-5.png"/>
</div>

Additional Configurations can be made in `Advances configuration` section.

The details of the created task can be viewed here. Click on `Job` under Tasks to Annotate.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-6.png"/>
</div>

This is the Annotations Playground.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-7.png"/>
</div>

Let's manually annotate a car using the `Draw a new Rectangle` tool. Select the label, Then click `Track` to annotate.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-8.png"/>
</div>

Selecting top-left and bottom-right points to enclose the object.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-9.png"/>
</div>

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-10.png"/>
</div>

Annotating using AI

Under `Detector`, Select the model available which was recently exposed as serverless function using Nuclio. Establish mapping between `Model labels` and `Task labels`. Then click `Annotate` to Auto-annotate.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-11.png"/>
</div>

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-12.png"/>
</div>

Exporting the annotations

To the top left, click `Menu` to `Export job dataset`

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-13.png"/>
</div>

Select among the many options in `Export Format`, If you wish to save images along with annotations, check the `Save Images` option. Save the dataset with `Custom Name`.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/cvat-14.png"/>
</div>
