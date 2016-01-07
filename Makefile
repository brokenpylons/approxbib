SOURCES := index.md approx.bib
HTML_DIR := html
PDF_DIR := pdf
MADOKO := node_modules/.bin/madoko

# Shortcuts.
.PHONY: all html pdf
all: html pdf
html: $(HTML_DIR)/index.html
pdf: $(PDF_DIR)/index.pdf

# Build Web page.
$(HTML_DIR)/index.html: $(SOURCES) $(MADOKO)
	$(MADOKO) --odir=$(HTML_DIR) $<

# Build PDF via LaTeX.
$(PDF_DIR)/index.pdf: $(SOURCES) $(MADOKO)
	$(MADOKO) --odir=$(PDF_DIR) --pdf $<

# Install Madoko for document creation.
$(MADOKO):
	npm install madoko
	@touch $@

# Auto-build Web version using https://facebook.github.io/watchman/
.PHONY: watch
watch:
	watchman-make --settle 0.1 \
		-p $(SOURCES) -t html
