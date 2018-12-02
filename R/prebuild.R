library(magrittr)
flist <- dir("source/post", full.names = TRUE)
for(path in flist) {
  cat(sprintf("Processing %s...\n", path))
  .f <- file(path, encoding = "UTF-8")
  src <- readLines(.f)
  close(.f)
  stopifnot(sum(src == "---") == 2)
  . <- which(src == "---")
  start <- .[1] + 1
  end <- .[2] - 1
  src[seq.int(start, end, by = 1)]
  .config <- yaml::yaml.load(src[seq.int(start, end, by = 1)])
  .content <- src[seq.int(end + 2, length(src), by = 1)]
  .config$date <- strptime(.config$date, "%Y-%m-%d %H:%M") %>%
    as.Date() %>%
    format()
  .config$draft <- FALSE
  .config$slug <- substring(basename(path), 12, nchar(basename(path))) %>%
    tools::file_path_sans_ext()
  .config <- .config[c("title", "date", "slug")]
  .f <- sub("source/", "content/", path, fixed = TRUE) %>% file(open = "w", encoding = "UTF-8")
  c(sprintf("---\n%s---\n", yaml::as.yaml(.config)), .content) %>%
    cat(file = .f, sep = "\n")
  cat("\n", file = .f, append = TRUE)
  close(.f)
}
