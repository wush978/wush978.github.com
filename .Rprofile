local({
  .lib <- file.path(".lib", sprintf("%s.%s", R.version$major, R.version$minor))
  .lib <- normalizePath(.lib, mustWork = FALSE)
  if (!file.exists(.lib)) dir.create(.lib, recursive = TRUE, showWarnings = FALSE)
  .libPaths(new = .lib)
  Sys.setenv(R_LIBS=.lib)
})
options(blogdown.ext = ".Rmd", blogdown.author = "Wush Wu", repos = "http://cran.csie.ntu.edu.tw")
