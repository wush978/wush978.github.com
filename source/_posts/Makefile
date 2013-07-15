RMD = $(wildcard *.Rmd)
MD = $(RMD:.Rmd=.md)

all: $(MD)


%.md: %.Rmd
	Rscript -e "require(knitr);knit('$<', '$@')"
