# VARIABLES -------------------------------------------------------------------------------------
PDF_NAME=lezione-informatica
MAIN=main.pdf
BUILD_DIR=build
DOCKER_IMAGE=ilkimo_latex_pdf_generator

# Default values
PREFIX=example/
TOPICS=$(shell find $(PREFIX)topics/* -type d -exec basename {} \;)
TMP_MAIN=$(PREFIX)$(PDF_NAME).tex

# DEFAULT TARGET --------------------------------------------------------------------------------
all: check_imported_project build

# BUILD TARGETS ---------------------------------------------------------------------------------
build: check_imported_project $(PDF_NAME)
	@echo -e "\033[0;36mExecuting target build\033[0m"

.PHONY: docker_build
docker_build: check_imported_project build_dir
	@echo -e "\033[0;36mExecuting target docker_build\033[0m"
	@if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then \
		@echo "\033[0;36mImage does not exist. Building...\033[0m"; \
		docker build -t $(DOCKER_IMAGE) . ; \
	fi
	docker run --rm -v "$(shell pwd)":/usr/src/myapp $(DOCKER_IMAGE) TOPICS="$(TOPICS)"

# LATEX BUILD TARGETS ---------------------------------------------------------------------------
$(PDF_NAME): build_dir $(MAIN) $(PREFIX)preamble.tex $(addprefix $(PREFIX)topics/,$(addsuffix /main.tex,$(TOPICS)))
	@echo -e "\033[0;36mExecuting target PDF_NAME on name: $@\033[0m"

.PHONY: $(TMP_MAIN)
$(TMP_MAIN): $(PREFIX)main.tex
	@echo -e "\033[0;36mExecuting target TMP_MAIN on name: $(TMP_MAIN)\033[0m"
	cp $(PREFIX)main.tex $(TMP_MAIN)
	for topic in $(TOPICS); do \
		sed -i "s|%\\\input{topics/$$topic/main.tex}|\\\input{$(PREFIX)topics/$$topic/main.tex}|g" $(TMP_MAIN); \
	done
	sed -i "s|\\\input{preamble.tex}|\\\input{$(PREFIX)preamble.tex}|g" $(TMP_MAIN)

$(MAIN): $(TMP_MAIN)
	@echo -e "\033[0;36mExecuting target MAIN on name: $@\033[0m"
	pdflatex -output-directory $(BUILD_DIR) $(TMP_MAIN)

$(PREFIX)topics/%.pdf: 
	@echo -e "\033[0;36mExecuting target PREFIXtopics/*.pdf on name: $@\033[0m"
	pdflatex -output-directory $(@:.pdf=) $(@:.pdf=)/main.tex ../$(PREFIX)preamble.tex
	mv $(@:.pdf=)/main.pdf $@

# UTILITY TARGETS -------------------------------------------------------------------------------
.PHONY: build_dir
build_dir:
	mkdir -p $(BUILD_DIR)

.PHONY: check_imported_project
check_imported_project:
	@echo -e "\033[0;36mExecuting target check_imported_project\033[0m"
	@if [ -d "project" ]; then \
		PREFIX=project/; \
		TOPICS=$(shell find $(PREFIX)topics/* -type d -exec basename {} \;); \
		TMP_MAIN=$(PREFIX)$(PDF_NAME).tex; \
	fi

# CLEAN PROJECT ---------------------------------------------------------------------------------
.PHONY: clean
clean: docker_clean clean_build
	rm -rf $(BUILD_DIR)
	rm -f $(TMP_MAIN)
	rm -f *.log *.aux *.toc *.lof *.lot *.out *.bbl *.blg *.synctex.gz

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

