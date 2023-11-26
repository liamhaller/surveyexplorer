#' DeZIM Graphics Style
#'
#' @param title_size Size of title
#' @param sub_title_size Size of subtitle
#' @param x_axis_title_size size of x axis title
#' @param y_axis_title_size size of y axis title
#' @param x_axis_text_size size of x axis text
#' @param y_axis_text_size size of y axis text
#' @param legend_text_size Size of text in legend
#' @importFrom ggplot2 element_text element_rect element_line
#'
#'
#' @return No return, just a theme to add to ggplotfiles
#' @export
#'
dezim_style <- function(title_size = 16, sub_title_size = 14, x_axis_title_size = 14,
                        y_axis_title_size = 14, x_axis_text_size = 12,
                        y_axis_text_size = 12, legend_text_size = 12){




    list_of_fonts <- as.data.frame(sysfonts::font_files())
    if(any(grepl("Calibri.ttf", list_of_fonts, ignore.case = TRUE))){
      Calibri <- list_of_fonts[list_of_fonts$file == "calibri.ttf",]
      sysfonts::font_add(family = Calibri[,3],
                         regular = list.files(path = Calibri$path,
                                              pattern = Calibri[,2],
                                              full.names = TRUE))
    } else{
      stop("The Calibri font is not installed on your machine, please install it and try again")
    }

    ggplot2::theme(
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
      legend.text= element_text(color = "#4d4d4d", size = legend_text_size),
      legend.title = element_text(color = "#4d4d4d"),
      legend.background = element_rect(fill = '#EAEDEC', color = NA),
      legend.key = element_rect(fill = "#EAEDEC"),
      legend.position = "bottom",

      ### Design ###
      plot.background = element_rect(fill = '#EAEDEC', colour = "#154a39"),
      axis.ticks = element_line(color = "#4d4d4d"),
      panel.grid.major=element_line(color="#D3D3D3"),
      panel.grid.minor=element_line("#D3D3D3"))


}



#' Vector of colors for DeZIM Plots
#'
#' @format ## `dezim_colors`
#' A data frame with 500 rows and 22 columns describing bears and thier prefrences:
#' \describe{
#'   \item{species}{name of species}
#'   ...
#' }
"dezim_colors"



