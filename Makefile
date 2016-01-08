SOURCES := index.md approx.bib
HTML_DIR := html
PDF_DIR := pdf
MADOKO := node_modules/.bin/madoko
SPLITERATE := node_modules/.bin/spliterate

# Shortcuts.
.PHONY: html pdf
html: $(HTML_DIR)/index.html
pdf: $(PDF_DIR)/index.pdf

# Split the literate file into BibTeX and Markdown.
index.md approx.bib: approxbib.md $(SPLITERATE)
	$(SPLITERATE) $< -m index.md -c approx.bib

# Build Web page.
$(HTML_DIR)/index.html: $(SOURCES) $(MADOKO)
	$(MADOKO) --odir=$(HTML_DIR) $<

# Build PDF via LaTeX.
$(PDF_DIR)/index.pdf: $(SOURCES) $(MADOKO)
	$(MADOKO) --odir=$(PDF_DIR) --pdf $<

# Install Madoko and Spliterate.
$(MADOKO):
	npm install madoko
	@touch $@
$(SPLITERATE):
	npm install spliterate
	@touch $@

# Clean.
.PHONY: clean
clean: rm -rf $(HTML_DIR) $(PDF_DIR) node_modules

# Deploy to the Web.
.PHONY: deploy
RSYNCARGS := --compress --recursive --checksum --delete -e ssh
DEST := dh:domains/approximate.computer/approxbib
deploy: html
	rsync $(RSYNCARGS) $(HTML_DIR)/ $(DEST)

# Auto-build Web version using https://facebook.github.io/watchman/
.PHONY: watch
watch:
	watchman-make --settle 0.1 \
		-p $(SOURCES) -t html
