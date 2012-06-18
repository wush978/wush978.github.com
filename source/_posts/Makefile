RMDFILE := $(wildcard *.Rmd)

MDFILE := $(RMDFILE:.Rmd=.md)

MARKDOWNFILE := $(RMDFILE:.Rmd=.markdown)

all : $(MARKDOWNFILE)

$(MARKDOWNFILE) : $(MDFILE)
	php knitr2octopress/md2markdown.php $(@:.markdown=.md)

$(MDFILE) : $(RMDFILE)
	R --slave --vanilla --args $(@:.md=.Rmd) < knitr2octopress/Rmd2md.R

clean:
	-rm *.md
	-rm -rf figure
	-rm NA
