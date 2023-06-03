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

# Default value (can be overwritten from args when launching make target)
PDF_NAME=example-document
TOPICS=$(shell find $(PREFIX)topics/* -type d -exec basename {} \;)
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
.PHONY: _run_docker
_run_docker:
	@echo -e "\033[0;36mExecuting target _run_docker\033[0m"
	@if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then \
		@echo "\033[0;36mImage does not exist. Building...\033[0m"; \
		docker build -t $(DOCKER_IMAGE) . ; \
	fi
	docker run \
		--rm \
		-v "$(shell pwd)/build":/usr/src/myapp/build/ \
		-v "$(PROJECT_PATH)":/usr/src/myapp/project/ \
		$(DOCKER_IMAGE) \
		PDF_NAME="$(PDF_NAME)";

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
	for topic in $(TOPICS); do \
		sed -i "s|%\\\input{topics/$$topic/main.tex}|\\\input{$(PREFIX)topics/$$topic/main.tex}|g" $(BUILD_DIR)/$(TMP_MAIN); \
	done
	sed -i "s|\\\input{preamble.tex}|\\\input{../$(PREFIX)preamble.tex}|g" $(BUILD_DIR)/$(TMP_MAIN)

_$(PREFIX)topics/%.pdf: 
	@echo -e "\033[0;36mExecuting target _PREFIXtopics/*.pdf on name: $@\033[0m"
	pdflatex -output-directory $(@:.pdf=) $(@:.pdf=)/main.tex ../$(PREFIX)preamble.tex
	mv $(@:.pdf=)/main.pdf $@

# UTILITY TARGETS -------------------------------------------------------------------------------
.PHONY: _build_dir
_build_dir:
	@echo -e "\033[0;36mExecuting target _build_dir\033[0m"
	mkdir -p $(BUILD_DIR)

