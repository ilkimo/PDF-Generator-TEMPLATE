# VARIABLES -------------------------------------------------------------------------------------
MAIN=main.pdf
BUILD_DIR=build
DOCKER_IMAGE=ilkimo_latex_pdf_generator

ifneq (,$(filter $(MAKECMDGOALS),build_example docker_build_example))
    PREFIX=example/
else ifeq ($(wildcard project/main.tex),) # Checks if there could be a project ongoing 
    PREFIX=example/
else
    PREFIX=project/
endif

# PDF_NAME defaults to the name of the project's directory, 
# but can be overwritten from args when launching make target.
PDF_NAME=$(patsubst %/,%,$(PREFIX))
CHAPTERS=$(shell find $(PREFIX)chapters/* -type d -exec basename {} \;)
TMP_MAIN=$(PDF_NAME).tex

# DEFAULT TARGET --------------------------------------------------------------------------------
all: build

# OTHER CALLABLE TARGETS ------------------------------------------------------------------------
# ATTENTION!!!
# The example targets seem duplicated versions of the non-example ones, but there is a 
# conditional variable assignment on the selected target that makes the Makefile act
# differently.

build_example: _build_dir \
		_$(PDF_NAME)

build: _build_dir \
	_$(PDF_NAME)

.PHONY: _docker_build_example
docker_build_example: _build_dir _run_docker

.PHONY: docker_build
docker_build: _build_dir _run_docker

# CLEAN PROJECT ---------------------------------------------------------------------------------
.PHONY: clean
clean: docker_clean clean_build

.PHONY: docker_clean
docker_clean:
	@if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then \
		echo "Docker image not present."; \
	else \
		docker rmi $(DOCKER_IMAGE); \
	fi
	@if [ -z "$(shell docker images -q nanozoo/pdflatex:3.14159265--f2f4a3f)" ]; then \
		echo "Docker image not present."; \
	else \
		docker rmi nanozoo/pdflatex:3.14159265--f2f4a3f; \
	fi

.PHONY: clean_build
clean_build:
	rm -rf $(BUILD_DIR)
	rm -f $(TMP_MAIN)
	rm -f *.log *.aux *.toc *.lof *.lot *.out *.bbl *.blg *.synctex.gz

# LATEX BUILD TARGETS (private targets) ---------------------------------------------------------
# _run_docker installs and executes the container capable of generating PDFs with pdflatex.
# Mounting the PREFIX should not be needed for the example PDF creation, since
# the template files are already inside the Docker Image, but in this way we avoid more
# complex solutions that apply conditional logic based on example / project scenarios.
# 
# Another workaround is the path mounted to /usr/src/latex-genrator/project. Putting a '.' after
# $(PREFIX) removes the Docker error when using a path like ./project/ that has a trailing '/'.
.PHONY: _run_docker
_run_docker:
	@echo -e "\033[0;36mExecuting target _run_docker\033[0m"
	@if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then \
		@echo "\033[0;36mImage does not exist. Building...\033[0m"; \
		docker build -t $(DOCKER_IMAGE) . ; \
	fi
	docker run \
		--rm \
		-v "$(shell pwd)/build":/usr/src/latex-generator/build/ \
		-v "./$(PREFIX).":/usr/src/latex-generator/project/ \
		$(DOCKER_IMAGE) \
		PDF_NAME="$(PDF_NAME)" \
		CHAPTERS="$(CHAPTERS)" \
		PREFIX="$(PREFIX)";

_$(PDF_NAME): _$(MAIN) \
		$(PREFIX)preamble.tex
	@echo -e "\033[0;36mExecuting target _PDF_NAME on name: $@\033[0m"

_$(MAIN): _$(TMP_MAIN)
	@echo -e "\033[0;36mExecuting target _MAIN on name: $@\033[0m"
	pdflatex -output-directory $(BUILD_DIR) $(TMP_MAIN)

.PHONY: _$(TMP_MAIN)
_$(TMP_MAIN): $(PREFIX)main.tex
	@echo -e "\033[0;36mExecuting target _TMP_MAIN on name: $(TMP_MAIN)\033[0m"
	cp $(PREFIX)main.tex $(BUILD_DIR)/$(TMP_MAIN)
	for topic in $(CHAPTERS); do \
		sed -i "s|%\\\input{chapters/$$topic/main.tex}|\\\input{$(PREFIX)chapters/$$topic/main.tex}|g" $(BUILD_DIR)/$(TMP_MAIN); \
	done
	sed -i "s|\\\input{preamble.tex}|\\\input{../$(PREFIX)preamble.tex}|g" $(BUILD_DIR)/$(TMP_MAIN)

_$(PREFIX)chapters/%.pdf: 
	@echo -e "\033[0;36mExecuting target _PREFIXchapters/*.pdf on name: $@\033[0m"
	pdflatex -output-directory $(@:.pdf=) $(@:.pdf=)/main.tex ../$(PREFIX)preamble.tex
	mv $(@:.pdf=)/main.pdf $@

# UTILITY TARGETS -------------------------------------------------------------------------------
.PHONY: _build_dir
_build_dir:
	@echo -e "\033[0;36mExecuting target _build_dir\033[0m"
	mkdir -p $(BUILD_DIR)

