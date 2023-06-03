# PDF Generator TEMPLATE (with chapter selection)
## Index
- [About](#about)
- [How to use this template](#how-to-use-this-template)
- [Dependencies](#dependencies)
- [Build](#build)
  - [Build with Docker](#build-with-docker)
  - [Select desired chapters](#select-desired-chapters)
  - [Other customizations](#other-customizations)
- [Clean the project](#clean-the-project)
    - [Clean the Docker Image](#clean-the-docker-stuff)
- [Use the Docker Image from Docker Hub](#use-the-docker-image-from-docker-hub)
- [Contribute](#contribute)

## About
This repository is a template to generate PDFs with the abilty to select 
from arguments (args) the chapters to include. This is useful for teachers 
who want to give study material gradually to their students.

## How to use this template
This template can be used in two ways:
1) Working directly in the repository (by forking it), inside the project/ directory
2) Using the structure shown in the example/ directory locally and using the Docker
Image (pulling it from Docker Hub as shown in 
[Use the Docker Image from Docker Hub](#use-the-docker-image-from-docker-hub) 
section) to generate the PDF without the need to download this repo and just using
docker.

## File structure
Here is an example of file structure to follow:
```
.
├── main.tex
├── preamble.tex
└── topics
    ├── chapter1
    │   └── main.tex
    ├── chapter2
    │   └── main.tex
    ├── chapter3
    │   └── main.tex
    └── introduction
        └── main.tex

6 directories, 6 files

```
The names of the chapters (introduction, chapter1, chapter2, ...) can be different, 
but the .tex files have to keep these names or the tool will not be able to 
function properly.

## Dependencies
This project can be executed in three ways, each of which has its dependencies:
1) With Docker Hub's publicly available image:
- Docker
2) By building this repository with Docker:
- make
- Docker
3) By building this repository with make:
- make
- pdflatex
- probably other stuff for LaTeX

## Build
To generate a PDF, it is enough to run:
```/bin/bash
make
```
This will try to find the project/ directory with main.tex inside it and 
start building the PDF. If it does not find ./project/main.tex, it will 
build the example PDF using the material inside ./example/ directory.

### Build with Docker
If you don't want to have a dirty system, here are the
build commands to use Docker :D
1) To include all chapters
```/bin/bash
make docker_build
```
2) To include only some chapters (in this example, just "introduction" 
and "chapter1"
```/bin/bash
make docker_build "TOPICS=introduction chapter1 chapter2"
```

## Build Example PDF
From project:
```/bin/bash
make build_example
```
From Docker:
```/bin/bash
make docker_build_example
```

### Select desired chapters
You can use the arg "TOPICS=introduction chapter1 chapter2" after the Makefile target to select
the desired chapters, for example:
```/bin/bash
make "TOPICS=introduction chapter1 chapter2"
```

If you are building with Docker, the args have to be written like a little differently: 
$ docker run ... TOPICS="introduction chapter1 chapter2" 
(refer to [Use the Docker Image from Docker Hub](#use-the-docker-image-from-docker-hub))


But keep in mind that the names you write in this list have to be the same names
of the directories inside the topics/ directory.

### Other customizations
Here are some other args to customize the PDF generation:
- "PDF_NAME=my-document" to change the name of the generated PDF


## Clean the project
To clean everything:
```/bin/bash
make clean
```
This cleans the eventual Docker image created and the LaTeX files generated.

You can also just clean the non-Docker stuff with:
```/bin/bash
make clean_build
```

### Clean the Docker image
To just clean the Docker image:
```/bin/bash
make docker_clean
```

## Use the Docker Image from Docker Hub
If you just want to create your PDF, you can pull the Docker Image from Docker Hub with:
```/bin/bash
docker pull ilkimo/latex_pdf_generator:latest
```
Create a build directory (otherwise you will not be able to se the generated file):
```/bin/bash
mkdir build
```
Then run the container with:
```/bin/bash
docker run --rm -v <PROJECT_PATH>:/usr/src/latex-generator/project -v ./build:/usr/src/latex-generator/build ilkimo/latex_pdf_generator:1.0 PDF_NAME="<PDF_NAME>"
```
To generate the full version with all chapters (PDF_NAME is optional).

Or if you want to specify the chapter list:
```/bin/bash
docker run --rm -v <PROJECT_PATH>:/usr/src/latex-generator/project -v ./build:/usr/src/latex-generator/build ilkimo/latex_pdf_generator:1.0 TOPICS="introduction chapter1 chapter2" PDF_NAME="<PDF_NAME>"
```
The ".." are not meant to be written, and PDF_NAME is optional.

CARE!! This tool is opinionated, you HAVE to follow the [file structure](#file-structure)

## Contribute
Feel free to open Pull Requests if you find (and fix) bugs or if you want to propose an improvement!
Also opening an Issue can be helpful, as long as the problem is precisely described and 
easy to reproduce.