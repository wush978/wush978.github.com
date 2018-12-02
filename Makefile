all :
	Rscript R/prebuild.R
	Rscript -e "blogdown::build_site()"
