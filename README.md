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
from arguments (args) the chapters to include. This is useful for people that 
have to teach something and want to include the material gradually to the 
students.

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
make
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
