#' DeZIM Graphics Style
#'
#' @param calibri Use calibri as font family
#' @param title_size Size of title
#' @param sub_title_size Size of subtitle
#' @param x_axis_title_size size of x axis title
#' @param y_axis_title_size size of y axis title
#' @param x_axis_text_size size of x axis text
#' @param y_axis_text_size size of y axis text
#' @import ggplot2
#' @return No return, just a theme to add to ggplotfiles
#' @export
#'
dezim_style <- function(calibri = FALSE, title_size = 16, sub_title_size = 14, x_axis_title_size = 14,
                        y_axis_title_size = 14, x_axis_text_size = 12,
                        y_axis_text_size = 12){




  if(calibri == TRUE){

    #Check for Calibri font
    if (!require(showtext)) install.packages("showtext")
    #> Loading required package: showtext
    #> Loading required package: sysfonts
    #> Loading required package: showtextdb
    library(showtext)
    list_of_fonts <- as.data.frame(font_files())
    if(any(grepl("Calibri.ttf", list_of_fonts, ignore.case = TRUE))){
      Calibri <- list_of_fonts[list_of_fonts$file == "calibri.ttf",]
      sysfonts::font_add(family = Calibri[,3],
                         regular = list.files(path = Calibri$path,
                                              pattern = Calibri[,2],
                                              full.names = TRUE))
    } else{
      stop("The Calibri font is not installed on your machine, please install it and try again or set: Calibri = FALSE")
    }

    theme(
      ### Text ###
      #154a39
      #4d4d4d
      #Title
      plot.title = element_text(size = title_size, color = "#154a39", family = "Calibri"),
      plot.subtitle = element_text(size = sub_title_size, color = "#154a39"),
      plot.caption = element_text(color = "#154a39"),

      #Axis text
      axis.title.x = element_text(size = x_axis_title_size, color = "#4d4d4d", family = 'Calibri'),
      axis.text.x = element_text(size = x_axis_text_size, color = "#4d4d4d", family = 'Calibri'),
      axis.title.y = element_text(size = y_axis_title_size, color = "#4d4d4d", family = 'Calibri'),
      axis.text.y = element_text(size = y_axis_text_size, color = "#4d4d4d", family = 'Calibri'),

      ### Legend ###
      legend.text= element_text(color = "#4d4d4d"),
      legend.title = element_text(color = "#4d4d4d"),
      legend.background = element_rect(fill = '#EAEDEC'),
      legend.key = element_rect(fill = "#EAEDEC"),
      legend.position = "bottom",

      ### Design ###
      plot.background = element_rect(fill = '#EAEDEC', colour = "#154a39"),
      axis.ticks = element_line(color = "#4d4d4d"),
      panel.grid.major=element_line(color="#D3D3D3"),
      panel.grid.minor=element_line("#D3D3D3"))


  }  else {

    theme(
      ### Text ###
      #154a39
      #4d4d4d
      #Title
      plot.title = element_text(size = title_size, color = "#154a39", family = "Calibri"),
      plot.subtitle = element_text(size = sub_title_size, color = "#154a39"),
      plot.caption = element_text(color = "#154a39"),

      #Axis text
      axis.title.x = element_text(size = x_axis_title_size, color = "#4d4d4d", family = 'Calibri'),
      axis.text.x = element_text(size = x_axis_text_size, color = "#4d4d4d", family = 'Calibri'),
      axis.title.y = element_text(size = y_axis_title_size, color = "#4d4d4d", family = 'Calibri'),
      axis.text.y = element_text(size = y_axis_text_size, color = "#4d4d4d", family = 'Calibri'),

      ### Legend ###
      legend.text= element_text(color = "#4d4d4d"),
      legend.title = element_text(color = "#4d4d4d"),
      legend.background = element_rect(fill = '#EAEDEC'),
      legend.key = element_rect(fill = "#EAEDEC"),
      legend.position = "bottom",

      ### Design ###
      plot.background = element_rect(fill = '#EAEDEC', colour = "#154a39"),
      axis.ticks = element_line(color = "#4d4d4d"),
      panel.grid.major=element_line(color="#D3D3D3"),
      panel.grid.minor=element_line("#D3D3D3"))
  }




}



