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
dezim_style <- function(title_size = 16, sub_title_size = 14, x_axis_title_size = 14,
                        y_axis_title_size = 14, x_axis_text_size = 12,
                        y_axis_text_size = 12){


  dezim_colors <- c("#D9AB11", "#2F5D47", "#8C9981", "#EED394","#D57F43",
                    "#EBBA8B", "#973B3A", "#C38878", "#2E6B75")



  #Check for Calibri font
  if (!require(showtext)) install.packages("showtext")
  #> Loading required package: showtext
  #> Loading required package: sysfonts
  #> Loading required package: showtextdb
  library(showtext)
  list_of_fonts <- as.data.frame(font_files())
  if(any(grepl("Calibri.ttf", list_of_fonts, ignore.case = TRUE))){
    Calibri <- list_of_fonts[list_of_fonts$file == "calibri.ttf",] #this is case sensitive on my machine
    sysfonts::font_add(family = "calibri",
                       regular = list.files(path = Calibri$path,
                                            pattern = "calibri.ttf", #this is case sensitive on my machine
                                            full.names = TRUE))
    print("Calibri available")
  } else{
    stop("The Calibri font is not installed on your machine, please install it and try again")
  }



  theme(
    ### Text ###
    #Title
    plot.title = element_text(size = title_size, color = "#154a39", family = "calibri", face = 'bold'),
    plot.subtitle = element_text(size = sub_title_size, color = "#154a39",  family = "overpass"),
    plot.caption = element_text(color = "#154a39"),

    #Axis text
    axis.title.x = element_text(size = x_axis_title_size, color = "#154a39", family = 'calibri'),
    axis.text.x = element_text(size = x_axis_text_size, color = "#154a39", family = 'calibri'),
    axis.title.y = element_text(size = y_axis_title_size, color = "#154a39", family = 'calibri'),
    axis.text.y = element_text(size = y_axis_text_size, color = "#154a39", family = 'calibri'),


    #colors
    scale_color_manual(values = dezim_colors),
    scale_fill_manual(values = dezim_colors),

    ### Legend ###
    legend.text= element_text(color = "#154a39"),
    legend.title = element_text(color = "#154a39"),
    legend.background = element_rect(fill = '#EAEDEC'),
    legend.position = "bottom",

    ### Design ###
    panel.border = element_rect(colour = "#154a39", fill=NA, size=0.5),
    plot.background = element_rect(fill = '#EAEDEC'),
    axis.ticks = element_line(color = "#154a39"),
    panel.grid.major=element_line(color="#D3D3D3"),
    panel.grid.minor=element_line("#D3D3D3"))


}




sysfonts::font_add(family = "Calibri",
                   regular = list.files(path = Calibri$path,
                                        pattern = "Calibri.ttf",
                                        full.names = TRUE))

Calibri <- list_of_fonts[list_of_fonts$file == "calibri.ttf",]

list.files(path = Calibri$path,
           pattern = "Calibri.ttf",
           full.names = TRUE)



fonts <- sysfonts::font_files()
print(as_tibble(list_of_fonts), n = 361)
sysfonts::font_add_google("Overpass", family = 'overpass')
sysfonts::font_add_google("Overpass Mono", family = 'overpass-mono')
?sysfonts::font_add()
#sysfonts::font_add()

sysfonts::font_families()


extrafont::font_import(paths = "/Library/Fonts", pattern = "calibri.ttf")


fonts <- as.data.frame(sysfonts::font_files())
grep(pattern = "Calibri", x = fonts$family, ignore.case = TRUE, value = TRUE)
