# PDF Generator (with chapter selection)
## Index
- [About](#about)
- [Dependencies](#dependencies)
- [Build](#build)
  - [Build with Docker](#build-with-docker)
- [Clean the project](#clean-the-project)
    - [Clean the Docker Image](#clean-the-docker-stuff)

## About
This repository is a template to generate PDFs with the abilty to select 
from arguments (args) the chapters to include. This is useful for teachers 
who want to give study material gradually to their students.

## Dependencies
This project can be executed in two ways:
1) With Docker
- make
- Docker
2) Traditional build
- make
- pdflatex
- probably other stuff for LaTeX

## Build
It is possible to generate PDFs with all chapters with:
```/bin/bash
make "PDF_NAME=my-document"
```
Or just the interested chapters:
```/bin/bash
make "TOPICS=funzioni ricorsioni"
```

### Build with Docker
If you don't want to have a dirty system, here are the
build commands to use Docker :D
1) To include all chapters
```/bin/bash
make docker_build
```
2) To include only some chapters (in this example, just "funzioni 
and "ricorsioni"
```/bin/bash
make docker_build "TOPICS=funzioni ricorsioni"
```

## Clean the project
To clean everything:
```/bin/bash
make clean
```
This cleans the eventual Docker image created and the LaTeX files generated

### Clean the Docker image
To just clean the Docker image:
```/bin/bash
make docker_clean
```

## Use the Docker Image from Docker Hub
If you just want to create your PDF, you can pull the Docker Image from Docker Hub with:
```/bin/bash
docker pull ilkimo/ilkimo_latex_pdf_generator:latest
```
Create a build directory:
```/bin/bash
mkdir build
```
Then run the container with:
```/bin/bash
docker run --rm -v <PROJECT_PATH>:/usr/src/myapp/project -v ./build:/usr/src/myapp/build ilkimo_latex_pdf_generator:latest PDF_NAME=<PDF_NAME>"
```
To generate the full version with all chapters.

Or if you want to specify the chapter list:
```/bin/bash
docker run --rm -v <PROJECT_PATH>:/usr/src/myapp/project -v ./build:/usr/src/myapp/build ilkimo_latex_pdf_generator:latest TOPICS="chapter1 chapter2.." PDF_NAME="<PDF_NAME>"
```
The ".." are not meant to be written.

CARE!! This tool is opinionated, you HAVE to follow a structure like:
```
.
├── main.tex
├── preamble.tex
└── topics
    ├── my_chapter1
    │   └── main.tex
    ├── my_chapter2
    │   └── main.tex
    ├── my_chapter3
    │   └── main.tex
    └── my_chapter4
        └── main.tex
```
