BUILD_DIR := gen
BUILD_DIR_PDF := $(BUILD_DIR)/pdf
BUILD_DIR_HTML := $(BUILD_DIR)/html
BUILD_DIR_DOCX := $(BUILD_DIR)/docx
IMAGES_DIR := img
DEFAULT_IMAGES_SIZES := ALL:-resize 500
IMAGES_FORMATS := *png *gif *jpg
PANDOC := pandoc
LATEX_ENGINE := /usr/local/texlive/2013basic/bin/x86_64-darwin/pdflatex
TPL_DIR := tpl
PDF_TEMPLATE := $(TPL_DIR)/template.tex
HTML_TEMPLATE := $(TPL_DIR)/template.html
HTML_CSS := $(TPL_DIR)/style.css
PANDOC_OPTS := -r markdown+simple_tables+table_captions+yaml_metadata_block
PANDOC_PDF_OPTS := -V sansfont=Tahoma -V monofont="Courier New" -V mainfont=Verdana  -V papersize=a5paper -V fontsize=8pt -V lang=english -V documentclass=memoir --toc --chapters -S -s --latex-engine $(LATEX_ENGINE) --template=$(PDF_TEMPLATE)

PANDOC_HTML_OPTS := --toc --chapters -S -s --template=$(HTML_TEMPLATE) --css=$(HTML_CSS)
PANDOC_DOCX_OPTS := --toc --chapters -S -s

MARKDOWN := $(wildcard *.md)
PDF := $(patsubst %.md,$(BUILD_DIR_PDF)/%.pdf,$(MARKDOWN))
DOCX := $(patsubst %.md,$(BUILD_DIR_DOCX)/%.docx,$(MARKDOWN))
HTML := $(patsubst %.md,$(BUILD_DIR_HTML)/%.html,$(MARKDOWN))

IMAGE_FILES := $(shell find $(IMAGES_DIR) -type f \! -name *sizes)
IMAGE_FILES_SIZES := $(shell find $(IMAGES_DIR) -type f -name *sizes)

IMAGES_PDF := $(patsubst %,$(BUILD_DIR_PDF)/%,$(IMAGE_FILES))
IMAGES_DOCX := $(patsubst %,$(BUILD_DIR_DOCX)/%,$(IMAGE_FILES))
IMAGES_HTML := $(patsubst %,$(BUILD_DIR_HTML)/%,$(IMAGE_FILES))

MKDIR=@mkdir -p $@

all: pdf docx html

checkdirs: $(BUILD_DIR) $(BUILD_DIR_PDF)/$(IMAGES_DIR) $(BUILD_DIR_PDF)/$(TPL_DIR) $(BUILD_DIR_DOCX)/$(IMAGES_DIR) $(BUILD_DIR_HTML)/$(IMAGES_DIR) $(BUILD_DIR_HTML)/$(TPL_DIR) 

# If img/image_name.ext.sizes doesn't exists create it using DEFAULT_IMAGES_SIZES content
.PHONY: imagessizes
imagessizes:
	cd $(IMAGES_DIR); for a in $(IMAGES_FORMATS); do [ -f $$a.sizes ] || echo "$(DEFAULT_IMAGES_SIZES)" > $$a.sizes; done

.PHONY: imageshtml
imageshtml: checkdirs $(IMAGES_HTML)

.PHONY: imagespdf
imagespdf: checkdirs $(IMAGES_PDF)

.PHONY: imagesdocx
imagesdocx: checkdirs $(IMAGES_DOCX)

.PHONY: pdf
pdf: checkdirs imagessizes $(PDF)

.PHONY: html
html: checkdirs imagessizes $(HTML)

.PHONY: docx
docx: checkdirs imagessizes $(DOCX)

# make gen
$(BUILD_DIR): ; $(MKDIR)
$(BUILD_DIR_PDF): ; $(MKDIR)
$(BUILD_DIR_DOCX): ; $(MKDIR)
$(BUILD_DIR_HTML): ; $(MKDIR)
$(BUILD_DIR_PDF)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_PDF)/$(TPL_DIR): ; $(MKDIR)
$(BUILD_DIR_DOCX)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_HTML)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_HTML)/$(TPL_DIR): ; $(MKDIR)

#make html images
$(BUILD_DIR_HTML)/img/%: img/% 
	./scripts/convert-img.sh $< html $(BUILD_DIR_HTML)/$(IMAGES_DIR)

#make pdf images
$(BUILD_DIR_PDF)/img/%: img/% 
	./scripts/convert-img.sh $< pdf $(BUILD_DIR_PDF)/$(IMAGES_DIR)

#make docx images
$(BUILD_DIR_DOCX)/img/%: img/% 
	./scripts/convert-img.sh $< docx $(BUILD_DIR_DOCX)/$(IMAGES_DIR)

$(BUILD_DIR_PDF)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_PDF)

$(BUILD_DIR_PDF)/$(PDF_TEMPLATE): $(PDF_TEMPLATE)
	cp $(PDF_TEMPLATE) $(BUILD_DIR_PDF)/$(PDF_TEMPLATE)

# make pdf
$(BUILD_DIR_PDF)/%.pdf: $(BUILD_DIR_PDF)/%.md imagespdf $(BUILD_DIR_PDF)/$(PDF_TEMPLATE)
	cd $(BUILD_DIR_PDF); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_PDF_OPTS) -o $*.pdf $*.md

$(BUILD_DIR_HTML)/%.md: %.md checkdirs $(BUILD_DIR_HTML)/$(HTML_TEMPLATE) $(BUILD_DIR_HTML)/$(HTML_CSS)
	cp $< $(BUILD_DIR_HTML)

$(BUILD_DIR_HTML)/$(HTML_TEMPLATE): $(HTML_TEMPLATE)
	cp $(HTML_TEMPLATE) $(BUILD_DIR_HTML)/$(HTML_TEMPLATE)

$(BUILD_DIR_HTML)/$(HTML_CSS): $(HTML_CSS)
	cp $(HTML_CSS) $(BUILD_DIR_HTML)/$(HTML_CSS)

# make html
$(BUILD_DIR_HTML)/%.html: $(BUILD_DIR_HTML)/%.md imageshtml
	cd $(BUILD_DIR_HTML); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_HTML_OPTS) -o $*.html $*.md

$(BUILD_DIR_DOCX)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_DOCX)

# make docx
$(BUILD_DIR_DOCX)/%.docx: $(BUILD_DIR_DOCX)/%.md imagesdocx
	cd $(BUILD_DIR_DOCX); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_DOCX_OPTS) -o $*.docx $*.md

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
