CNTR_EXEC := $(shell if which podman 1>&2 > /dev/null; then echo podman; else echo docker; fi)
CNTR_NAME := asciidoctor/docker-asciidoctor:latest
DEST_DIR  := _build/ssdd

# SSDD (PDF) with images embedded (default since first in Makefile)
pdf: content/0-ssdd/ssdd.pdf

# SSDD (HTML) with images embedded 
html: content/0-ssdd/ssdd.html

# SSDD (HTML) with images in subfolder
unpacked: html-unpacked

%.pdf : CMD := asciidoctor-pdf
%.pdf : IMAGE_DIR  := --attribute imagesdir=../../resources/images
%.pdf : EXTRA_ARGS += --attribute pdf-themesdir=resources/themes-pdf
%.pdf : EXTRA_ARGS += --attribute pdf-theme=vs-cui
%.pdf : %.adoc
	# Generating $(DEST_DIR)/$(@F)
	$(call build-it,$<)

%.html : CMD := asciidoctor
%.html : IMAGE_DIR  := --attribute imagesdir=../../resources/images
%.html : EXTRA_ARGS += --attribute data-uri --attribute allow-uri-read
%.html : EXTRA_ARGS += --attribute stylesdir=../../resources/styles-html
%.html : EXTRA_ARGS += --attribute stylesheet=adoc-colony.css
%.html : %.adoc
	# Generating $(DEST_DIR)/$(@F)
	$(call build-it,$<)

html-unpacked: CMD := asciidoctor
html-unpacked: IMAGE_DIR  := --attribute imagesdir=images
html-unpacked: EXTRA_ARGS += --attribute stylesdir=../../resources/styles-html
html-unpacked: EXTRA_ARGS += --attribute stylesheet=adoc-colony.css
html-unpacked:
	# Generating $(DEST_DIR)/ssdd.html
	$(call build-it,content/0-ssdd/ssdd.adoc)
	cp -r -p resources/images $(DEST_DIR)

define build-it
    $(CNTR_EXEC) run \
        --rm \
        --volume="$$PWD:/documents" \
        $(CNTR_NAME) \
        $(CMD) \
        $1 \
        --destination-dir $(DEST_DIR) \
        --safe-mode unsafe \
        $(IMAGE_DIR) \
        $(EXTRA_ARGS)
endef

VPATH := content/0-ssdd \
         content/1-scope \
         content/2-system-wide-design-decisions \
         content/3-system-architectural-design \
         content/4-appendicies

clean:
	rm -rf _build
.PHONY: clean all pdf html packed html-unpacked

# Fragment for asciidoc to test for environment
#
# :man source:   Yabai
# :man version:  {revnumber}
# :man manual:   Yabai Manual
# 
# ifdef::env-github[]
# :toc:
# :toc-title:
# :toc-placement!:
# :numbered:
# endif::[]
# 
# yabai(1)
# ========
# 
# ifdef::env-github[]
# toc::[]
# endif::[]
#
