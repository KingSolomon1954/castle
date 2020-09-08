CNTR_EXEC := $(shell if which podman 1>&2 > /dev/null; then echo podman; else echo docker; fi)

DEST_DIR  := _build/ssdd
# Output directory structure
#
# _build/
#     ssdd/
#         ssdd.pdf
#         ssdd.html
#         images/    only if html-unpacked
#             image1.png
#             image2.png
#

# SSDD with embedded images (default since first in Makefile)
pdf: build
pdf: PROG_EXEC  := asciidoctor-pdf
pdf: IMAGE_DIR  := --attribute imagesdir=../resources/images
pdf: EXTRA_ARGS := --attribute data-uri --attribute allow-uri-read
pdf: EXTRA_ARGS += --attribute pdf-themesdir=resources/themes-pdf
pdf: EXTRA_ARGS += --attribute pdf-theme=vs-cui

# pdf: EXTRA_ARGS += --attribute pdf-themesdir=resources/themes-pdf
# pdf: EXTRA_ARGS += --attribute pdf-theme=howie

# SSDD with embedded images
html: build
html: PROG_EXEC  := asciidoctor
html: IMAGE_DIR  := --attribute imagesdir=../resources/images
html: EXTRA_ARGS := --attribute data-uri --attribute allow-uri-read
html: EXTRA_ARGS += --attribute stylesdir=../resources/styles-html
html: EXTRA_ARGS += --attribute stylesheet=adoc-colony.css

# SSDD with images in a side folder
html-unpacked: build
html-unpacked: PROG_EXEC  := asciidoctor
html-unpacked: IMAGE_DIR  := --attribute imagesdir=images
html-unpacked: EXTRA_ARGS := --attribute stylesdir=../resources/styles-html
html-unpacked: EXTRA_ARGS += --attribute stylesheet=adoc-colony.css

build:
	$(CNTR_EXEC) run \
	    --rm \
	    --volume="$$PWD:/documents" \
	    asciidoctor/docker-asciidoctor:latest \
	    $(PROG_EXEC) \
	    content/ssdd.adoc \
	    --destination-dir $(DEST_DIR) \
	    --safe-mode unsafe \
	    $(IMAGE_DIR) \
	    $(EXTRA_ARGS)
ifeq (unpacked,$(findstring unpacked,$(MAKECMDGOALS)))
	cp -r -p resources/images $(DEST_DIR)
endif

clean:
	rm -rf _build
.PHONY: clean all pdf html html-unpacked
