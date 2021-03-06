BUILD_DIR := gen
BUILD_DIR_PDF := $(BUILD_DIR)/pdf
BUILD_DIR_LATEX := $(BUILD_DIR)/latex
BUILD_DIR_HTML := $(BUILD_DIR)/html
BUILD_DIR_DOCX := $(BUILD_DIR)/docx
BUILD_DIR_EPUB := $(BUILD_DIR)/epub

IMAGES_DIR := img
DEFAULT_IMAGES_SIZES := ALL:-density 72\npdf:-density 72
IMAGES_FORMATS := *png *gif *jpg
PANDOC := pandoc
LATEX_ENGINE := /usr/local/texlive/2014/bin/x86_64-darwin/pdflatex
TPL_DIR := tpl
#PDF_TEMPLATE := $(TPL_DIR)/template.tex
PDF_TEMPLATE := $(TPL_DIR)/custom.tex
LATEX_TEMPLATE := $(TPL_DIR)/custom.tex
HTML_TEMPLATE := $(TPL_DIR)/template.html
HTML_CSS := $(TPL_DIR)/kultiad-serif.css 
PANDOC_OPTS := -r markdown+simple_tables+table_captions+yaml_metadata_block
PANDOC_PDF_OPTS := -V -S -s --latex-engine $(LATEX_ENGINE) --template=$(PDF_TEMPLATE)
PANDOC_LATEX_OPTS := -V sansfont=Tahoma -V monofont="Courier New" -V mainfont=Verdana  -V papersize=a4paper -V fontsize=8pt -V lang=english -V documentclass=memoir --toc --chapters -S -s --latex-engine $(LATEX_ENGINE) --template=$(PDF_TEMPLATE)
PANDOC_HTML_OPTS := --toc --chapters -S -s --template=$(HTML_TEMPLATE) --css=$(HTML_CSS)
PANDOC_DOCX_OPTS := --toc --chapters -S -s

RSYNC_DST=root@ade.bertera.it:/srv/www/vhosts/www.bertera.it/mydocs/
GREP=pcregrep

MARKDOWN := $(wildcard *.md)
PDF := $(patsubst %.md,$(BUILD_DIR_PDF)/%.pdf,$(MARKDOWN))
LATEX := $(patsubst %.md,$(BUILD_DIR_LATEX)/%.tex,$(MARKDOWN))
DOCX := $(patsubst %.md,$(BUILD_DIR_DOCX)/%.docx,$(MARKDOWN))
HTML := $(patsubst %.md,$(BUILD_DIR_HTML)/%.html,$(MARKDOWN))
EPUB := $(patsubst %.md,$(BUILD_DIR_EPUB)/%.epub,$(MARKDOWN))

IMAGE_FILES := $(shell find $(IMAGES_DIR) -type f \! -name *sizes)
IMAGE_FILES_SIZES := $(shell find $(IMAGES_DIR) -type f -name *sizes)

IMAGES_PDF := $(patsubst %,$(BUILD_DIR_PDF)/%,$(IMAGE_FILES))
IMAGES_LATEX := $(patsubst %,$(BUILD_DIR_LATEX)/%,$(IMAGE_FILES))
IMAGES_DOCX := $(patsubst %,$(BUILD_DIR_DOCX)/%,$(IMAGE_FILES))
IMAGES_HTML := $(patsubst %,$(BUILD_DIR_HTML)/%,$(IMAGE_FILES))
IMAGES_EPUB := $(patsubst %,$(BUILD_DIR_EPUB)/%,$(IMAGE_FILES))
MKDIR=@mkdir -p $@

all: pdf docx html latex epub

checkdirs: $(BUILD_DIR) $(BUILD_DIR_PDF)/$(IMAGES_DIR) $(BUILD_DIR_PDF)/$(TPL_DIR) $(BUILD_DIR_LATEX)/$(IMAGES_DIR) $(BUILD_DIR_LATEX)/$(TPL_DIR) $(BUILD_DIR_DOCX)/$(IMAGES_DIR) $(BUILD_DIR_HTML)/$(IMAGES_DIR) $(BUILD_DIR_HTML)/$(TPL_DIR) $(BUILD_DIR_EPUB)/$(IMAGES_DIR)

# If img/image_name.ext.sizes doesn't exists create it using DEFAULT_IMAGES_SIZES content
.PHONY: imagessizes
imagessizes:
	cd $(IMAGES_DIR); echo "$(DEFAULT_IMAGES_SIZES)" > fallback.sizes
	#cd $(IMAGES_DIR); for a in $(IMAGES_FORMATS); do [ -f $$a.sizes ] || echo "$(DEFAULT_IMAGES_SIZES)" > $$a.sizes; done

.PHONY: imageshtml
imageshtml: checkdirs $(IMAGES_HTML)

.PHONY: imagespdf
imagespdf: checkdirs $(IMAGES_PDF)

.PHONY: imageslatex
imagespdf: checkdirs $(IMAGES_LATEX)

.PHONY: imagesdocx
imagesdocx: checkdirs $(IMAGES_DOCX)

.PHONY: imagesepub
imagesepub: checkdirs $(IMAGES_EPUB)

.PHONY: pdf
pdf: checkdirs imagessizes $(PDF)

.PHONY: latex
latex: checkdirs imagessizes $(LATEX)

.PHONY: html
html: checkdirs imagessizes $(HTML)

.PHONY: docx
docx: checkdirs imagessizes $(DOCX)

.PHONY: epub
epub: checkdirs imagessizes $(EPUB)

.PHONY: check
check:
	$(GREP) --color='auto' -n "[\x80-\xFF]" $(MARKDOWN); test $$? -eq 1

# Directories

$(BUILD_DIR): ; $(MKDIR)
$(BUILD_DIR_EPUB): ; $(MKDIR)
$(BUILD_DIR_EPUB)/$(IMAGES_DIR): ; $(MKDIR)

$(BUILD_DIR_PDF): ; $(MKDIR)
$(BUILD_DIR_PDF)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_PDF)/$(TPL_DIR): ; $(MKDIR)

$(BUILD_DIR_LATEX): ; $(MKDIR)
$(BUILD_DIR_LATEX)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_LATEX)/$(TPL_DIR): ; $(MKDIR)

$(BUILD_DIR_DOCX): ; $(MKDIR)
$(BUILD_DIR_DOCX)/$(IMAGES_DIR): ; $(MKDIR)

$(BUILD_DIR_HTML): ; $(MKDIR)
$(BUILD_DIR_HTML)/$(IMAGES_DIR): ; $(MKDIR)
$(BUILD_DIR_HTML)/$(TPL_DIR): ; $(MKDIR)

######## PDF #########

# make pdf images
$(BUILD_DIR_PDF)/img/%: img/% 
	./scripts/convert-img.sh $< pdf $(BUILD_DIR_PDF)/$(IMAGES_DIR)

# copy Markdown file to PDF build dir
$(BUILD_DIR_PDF)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_PDF)

# copy PDF template build dir
$(BUILD_DIR_PDF)/$(PDF_TEMPLATE): $(PDF_TEMPLATE)
	cp $(PDF_TEMPLATE) $(BUILD_DIR_PDF)/$(PDF_TEMPLATE)

# make pdf
$(BUILD_DIR_PDF)/%.pdf: $(BUILD_DIR_PDF)/%.md imagespdf $(BUILD_DIR_PDF)/$(PDF_TEMPLATE)
	cd $(BUILD_DIR_PDF); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_PDF_OPTS) -o $*.pdf $*.md

######## LATEX #########

# make latex images
$(BUILD_DIR_LATEX)/img/%: img/% 
	./scripts/convert-img.sh $< pdf $(BUILD_DIR_LATEX)/$(IMAGES_DIR)

# copy Markdown file to LATEX build dir
$(BUILD_DIR_LATEX)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_LATEX)

# copy LATEX template build dir
$(BUILD_DIR_LATEX)/$(LATEX_TEMPLATE): $(LATEX_TEMPLATE)
	cp $(LATEX_TEMPLATE) $(BUILD_DIR_LATEX)/$(LATEX_TEMPLATE)

# make latex
$(BUILD_DIR_LATEX)/%.tex: $(BUILD_DIR_LATEX)/%.md imageslatex $(BUILD_DIR_LATEX)/$(LATEX_TEMPLATE)
	cd $(BUILD_DIR_LATEX); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_LATEX_OPTS) -o $*.tex $*.md

######## HTML #########

# make html images
$(BUILD_DIR_HTML)/img/%: img/% 
	./scripts/convert-img.sh $< html $(BUILD_DIR_HTML)/$(IMAGES_DIR)

# copy Markdown file to HTML build dir
$(BUILD_DIR_HTML)/%.md: %.md checkdirs $(BUILD_DIR_HTML)/$(HTML_TEMPLATE) $(BUILD_DIR_HTML)/$(HTML_CSS)
	cp $< $(BUILD_DIR_HTML)

# copy HTML template build dir
$(BUILD_DIR_HTML)/$(HTML_TEMPLATE): $(HTML_TEMPLATE)
	cp $(HTML_TEMPLATE) $(BUILD_DIR_HTML)/$(HTML_TEMPLATE)

# copy HTML CSS build dir
$(BUILD_DIR_HTML)/$(HTML_CSS): $(HTML_CSS)
	cp $(HTML_CSS) $(BUILD_DIR_HTML)/$(HTML_CSS)

# make html
$(BUILD_DIR_HTML)/%.html: $(BUILD_DIR_HTML)/%.md imageshtml
	cd $(BUILD_DIR_HTML); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_HTML_OPTS) -o $*.html $*.md

######## DOCX #########

# make docx images
$(BUILD_DIR_DOCX)/img/%: img/% 
	./scripts/convert-img.sh $< docx $(BUILD_DIR_DOCX)/$(IMAGES_DIR)

# copy Markdown file to DOCX build dir
$(BUILD_DIR_DOCX)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_DOCX)

# make docx
$(BUILD_DIR_DOCX)/%.docx: $(BUILD_DIR_DOCX)/%.md imagesdocx
	cd $(BUILD_DIR_DOCX); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_DOCX_OPTS) -o $*.docx $*.md

######## DOCX #########

# make epub images
$(BUILD_DIR_EPUB)/img/%: img/% 
	./scripts/convert-img.sh $< epub $(BUILD_DIR_EPUB)/$(IMAGES_DIR)

# copy Markdown file to EPUB build dir
$(BUILD_DIR_EPUB)/%.md: %.md checkdirs
	cp $< $(BUILD_DIR_EPUB)

# make epub
$(BUILD_DIR_EPUB)/%.epub: $(BUILD_DIR_EPUB)/%.md imagesepub
	cd $(BUILD_DIR_EPUB); $(PANDOC) $(PANDOC_OPTS) $(PANDOC_EPUB_OPTS) -o $*.epub $*.md

# Remove all builds
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)

# Upload to the server
upload:
	rsync -avP --exclude .DS_Store --exclude .git --delete . $(RSYNC_DST)
