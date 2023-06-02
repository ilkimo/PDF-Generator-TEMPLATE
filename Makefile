PDF_NAME=lezione-informatica
TMP_MAIN=$(PDF_NAME).tex
MAIN=main.pdf
BUILD_DIR=build
DOCKER_IMAGE=ilkimo_latex_pdf_generator
TOPICS=$(shell find topics/* -type d -exec basename {} \;) # Default topics

all: build

.PHONY: docker_build
docker_build: build_dir
	@if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then \
		@echo "\033[0;36Image does not exist. Building...\033[0m"; \
		docker build -t $(DOCKER_IMAGE) . ; \
	fi
	docker run --rm -v "$(shell pwd)":/usr/src/myapp $(DOCKER_IMAGE) TOPICS="$(TOPICS)"

build: $(PDF_NAME)

$(PDF_NAME): build_dir $(MAIN) preamble.tex $(addprefix topics/,$(addsuffix /main.tex,$(TOPICS)))
	@echo -e "\033[0;36mExecuting target $@\033[0m"

.PHONY: $(TMP_MAIN)
$(TMP_MAIN): main.tex
	@echo -e "\033[0;36mExecuting target $(TMP_MAIN)\033[0m"
	cp main.tex $(TMP_MAIN)
	for topic in $(TOPICS); do \
		sed -i "s|%\\\input{topics/$$topic/main.tex}|\\\input{topics/$$topic/main.tex}|g" $(TMP_MAIN); \
	done

$(MAIN): $(TMP_MAIN)
	@echo -e "\033[0;36mExecuting target $@\033[0m"
	pdflatex -output-directory $(BUILD_DIR) $(TMP_MAIN)

topics/%.pdf: 
	@echo -e "\033[0;36mExecuting target $@\033[0m"
	pdflatex -output-directory $(@:.pdf=) $(@:.pdf=)/main.tex ../preamble.tex
	mv $(@:.pdf=)/main.pdf $@

.PHONY: build_dir
build_dir:
	mkdir -p $(BUILD_DIR)

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

.PHONY: clean_build
clean_build: docker_clean clean
	rm -rf $(BUILD_DIR)
	rm -f $(TMP_MAIN)
	rm -f *.log *.aux *.toc *.lof *.lot *.out *.bbl *.blg *.synctex.gz

