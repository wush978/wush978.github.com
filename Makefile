SOURCE_RMD=$(wildcard source/post/*.Rmd)
CONTENT_RMD=$(shell echo ${SOURCE_RMD} | tr " " "\n" | sed "s/^source/content/g")
CONTENT_HTML=$(CONTENT_RMD:.Rmd=.html)

.PHONY=hugo install

all : hugo

install :
	Rscript -e "if (!require('pvm')) install.packages('pvm', repos = 'https://wush978.github.io/R', type = 'source')"
	Rscript -e "pvm::import.packages()"
	Rscript -e "blogdown::install_hugo()"
	
content/post/%.Rmd : source/post/%.Rmd
	Rscript R/source2content.R $< $@

content/post/%.html : content/post/%.Rmd
	Rscript -e "knitr::knit('$<', '$@')"

hugo : $(CONTENT_HTML)
	Rscript -e "blogdown::hugo_build()"

