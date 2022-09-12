SOURCE_RMD=$(wildcard source/post/*.Rmd)
CONTENT_RMD=$(shell echo ${SOURCE_RMD} | tr " " "\n" | sed "s/^source/content/g")
CONTENT_HTML=$(CONTENT_RMD:.Rmd=.html)

.PHONY=hugo install run
CONDA_PREFIX=wush978.github.com

all : install hugo $(CONTENT_HTML)

install :
	conda run -n $(CONDA_PREFIX) Rscript -e "if (!require('remotes')) install.packages('remotes')"
	conda run -n $(CONDA_PREFIX) Rscript -e "if (!require('pvm')) remotes::install_github('wush978/pvm')"
	conda run -n $(CONDA_PREFIX) Rscript -e "pvm::import.packages()"
	conda run -n $(CONDA_PREFIX) Rscript -e "blogdown::hugo_version()" || conda run -n $(CONDA_PREFIX) Rscript -e "blogdown::install_hugo()"

content/post/%.Rmd : source/post/%.Rmd
	conda run -n $(CONDA_PREFIX) Rscript R/source2content.R $< $@

content/post/%.html : content/post/%.Rmd
	conda run -n $(CONDA_PREFIX) Rscript -e "blogdown:::build_rmds('$<')"

hugo : install $(CONTENT_RMD) $(CONTENT_HTML)
	conda run -n $(CONDA_PREFIX) Rscript -e "blogdown::hugo_build()"

run : 
	conda run -n $(CONDA_PREFIX) Rscript -e "blogdown::hugo_server('localhost', 12345)"
