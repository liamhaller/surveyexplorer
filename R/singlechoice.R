




#' Visualize frequencies in single choice survey questions
#'
#' @param dataset data frame or a tibble
#' @param question name of the column in the dataset to graph
#' @param subgroup name of the subgroup to segment the data by
#' @param levels_to_exclude levels of the question varable to exclude in the graph
#'
#' @return A barchart of frequencies
#' @export
#'
#' @import ggplot2
#' @import dplyr
#' @importFrom rlang ensym
#'
singlechoice_graph <- function(dataset, question, subgroup = NULL, levels_to_exclude = NULL){

  question <- rlang::ensym(question)

  #convert subgroup into symobl, try function is here since if is null, then it will fail
  try(subgroup <- rlang::ensym(subgroup), silent = TRUE)


  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)


  #### Data ####

  #convert data into frequencies (table format) needed for bar graph
  #select subgroup only if it is specified, else will compute without stratificaiton
  if(is.null(subgroup)){
    tabled.question <-  dataset %>% select(!!question)
  } else {
    tabled.question <-  dataset %>% select(!!question, !!subgroup)
  }

  #filter out variables to exclude, if they are specified
  if(!is.null(levels_to_exclude)){
    tabled.question <- tabled.question %>%
      filter(!!subgroup %ni% levels_to_exclude)}

  tabled.question <- tabled.question %>%
    table %>%
    as.data.frame

  #if there is a subgroup specified, group by it
  if(!is.null(subgroup)){
    tabled.question <- tabled.question %>%
      group_by(!!subgroup)}

  tabled.question <- tabled.question %>%
    mutate(Freq = Freq/sum(Freq))

  #### Graphing ####

  if(is.null(subgroup)){
    #no subgroup, graph all values together

    colnames(tabled.question) <- c('question', 'freq')

    graph.singlechoice <- ggplot(tabled.question, aes(x = question, y= freq, label = scales::percent(freq))) +
      geom_bar(stat = 'identity', color = '#296334', fill = '#586994') +
      geom_text(position = position_dodge(width = .9),    # move to center of bars
                vjust = -0.5,    # nudge above top of bar
                size = 3) +
      theme(axis.text.x=element_text(angle = -15, hjust = 0, size = 8)) +
      scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
      scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
      labs(y = "", x = "", title = paste0('Variable: ', question), subtitle = paste("Filter: none")) +
      theme_minimal()

    return(graph.singlechoice)

  } else {
    #subgroup specified, facet plots based on subgroup

    colnames(tabled.question) <- c('question', 'subgroup', 'freq')

    graph.singlechoice <- ggplot(tabled.question, aes(x = question, y= freq, label = scales::percent(freq))) +
      geom_bar(stat = 'identity', color = '#296334', fill = '#586994') +
      geom_text(position = position_dodge(width = .9),    # move to center of bars
                vjust = -0.5,    # nudge above top of bar
                size = 3) +
      theme(axis.text.x=element_text(angle = -15, hjust = 0, size = 8)) +
      scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
      scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
      labs(y = "", x = "", title = paste('Variable: ', question), subtitle = paste("Filter: ",subgroup )) +
      facet_wrap(~subgroup, scales = "fixed", ncol = 2) +
      theme_minimal()

    return(graph.singlechoice)


  }

}


#sc_table
