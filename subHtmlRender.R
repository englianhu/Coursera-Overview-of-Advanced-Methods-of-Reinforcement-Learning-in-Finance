## Include HTML files in R Markdown file?
## https://stackoverflow.com/a/36525111/3806250
library(stringi)

subHtmlRender <- function(mdfile, htmlfile) {
  #replace <<insertHTML:htmlfile with actual html code
  #but without beginning white space
  lines <- readLines(mdfile)
  toSubcode <- paste0("<<insertHTML:[",htmlfile,"]")
  location <- which(stri_detect_fixed(lines, toSubcode) )
  htmllines <- stri_trim(readLines(htmlfile))
  
  #render html doc
  newRmdfile <- tempfile('temp', getwd(), '.Rmd')
  newlines <- c(lines[1:(location-1)],
                htmllines,
                lines[min(location+1, length(lines)):length(lines)])  #be careful when insertHTML being last line in .Rmd file
  write(newlines, newRmdfile)
  rmarkdown::render(newRmdfile, 'html_document')
  ## https://stackoverflow.com/a/36406375/3806250
  system(gsub('.Rmd', '.html', basename(newRmdfile), fixed = TRUE)) #use system() instead of shell()
} #end subHtmlRender

subHtmlRender('Final-Project.Rmd', 'QED_DJI_calibration_Coursera_course_4.html')
