RENDERABLE := index.md approx.bib
HTML_DIR := html
PDF_DIR := pdf
PUBLIC_DIR := public
MADOKO := node_modules/.bin/madoko
SPLITERATE := node_modules/.bin/spliterate

# Shortcuts.
.PHONY: html pdf
html: $(HTML_DIR)/index.html
pdf: $(PDF_DIR)/index.pdf

# Split the literate file into BibTeX and Markdown.
index.md approx.part.bib: approxbib.md $(SPLITERATE)
	$(SPLITERATE) $< -m index.md -c approx.part.bib

# Concatenate the venues with the main bib entries.
approx.bib: venues.bib approx.part.bib
	cat $^ > $@

# Build Web page.
$(HTML_DIR)/index.html: $(RENDERABLE) $(MADOKO)
	$(MADOKO) --odir=$(HTML_DIR) $<

# Build PDF via LaTeX.
$(PDF_DIR)/index.pdf: $(RENDERABLE) $(MADOKO)
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
clean: rm -rf $(HTML_DIR) $(PDF_DIR) $(PUBLIC_DIR) node_modules

# Public compendium: a clean copy of everything we want to upload.
.PHONY: public
public: $(RENDERABLE) html pdf
	rm -rf $(PUBLIC_DIR)
	mkdir $(PUBLIC_DIR)
	cp $(HTML_DIR)/index.html $(PUBLIC_DIR)
	cp $(PDF_DIR)/index.pdf $(PUBLIC_DIR)
	cp $(RENDERABLE) $(PUBLIC_DIR)

# Deploy to the Web.
.PHONY: deploy
RSYNCARGS := --compress --recursive --checksum --delete -h -i -e ssh
DEST := dh:domains/approximate.computer/approxbib
deploy: public
	rsync $(RSYNCARGS) $(PUBLIC_DIR)/ $(DEST)
