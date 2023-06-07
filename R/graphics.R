#' DeZIM Graphics Style
#'
#' @param title_size Size of title
#' @param x_axis_title_size size of x axis title
#' @param y_axis_title_size size of y axis title
#' @param x_axis_text_size size of x axis text
#' @param y_axis_text_size size of y axis text
#' @import ggplot2
#' @return No return, just a theme to add to ggplotfiles
#' @export
#'
dezim_style <- function(title_size = 16, x_axis_title_size = 14,
                        y_axis_title_size = 14, x_axis_text_size = 12,
                        y_axis_text_size = 12){


  theme(
    ### Text ###
    #Title
    plot.title = element_text(size = title_size, color = "#154a39"),

    #Axis text
    axis.title.x = element_text(size = x_axis_title_size, color = "#154a39"),
    axis.text.x = element_text(size = x_axis_text_size, color = "#154a39"),
    axis.title.y = element_text(size = y_axis_title_size, color = "#154a39"),
    axis.text.y = element_text(size = y_axis_text_size, color = "#154a39"),

    ### Legend ###
    legend.text= element_text(color = "#154a39"),
    legend.title = element_text(color = "#154a39"),
    legend.background = element_rect(fill = '#EAEDEC'),

    ### Design ###
    plot.background = element_rect(fill = '#EAEDEC'),
    axis.ticks = element_line(color = "#154a39"),
    panel.grid.major=element_line(color="#D3D3D3"),
    panel.grid.minor=element_line("#D3D3D3"))


}
