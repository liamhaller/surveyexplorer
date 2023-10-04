
#' Visualize frequencies of single choice survey questions
#'
#' @param dataset Data frame or a tibble
#' @param question Name of the column in the dataset to graph
#' @param subgroup name of the subgroup to segment the data by
#' @param levels_to_exclude levels of the subgroup varable to exclude when stratifying `question`
#' @param weights an optional vector of survey weights
#' @param return_data Return only the filtered data to create custom graphs/tables
#'
#'
#' @return A barchart of frequencies
#' @export
#'
#' @importFrom dplyr rename select filter group_by count mutate ungroup
#' @importFrom ggplot2 ggplot geom_bar geom_text scale_x_discrete scale_y_continuous theme_minimal labs
#' @importFrom scales percent
#' @importFrom rlang ensym
#' @importFrom stringr str_wrap
#'
singlechoice_graph <- function(dataset, question, subgroup = NULL,
                               levels_to_exclude = NULL, weights = NULL,
                               return_data = FALSE){

  #Inputs to symbols to use with dplyr syntax
  question <- rlang::ensym(question)
  try(subgroup <- rlang::ensym(subgroup), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail


  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)


  ## Data pre-processing ##
  #if weights are not specified create vector of 1s
  if(is.null(weights)){
    dataset$weights <- 1
  #if weights are specified, rename column to weights
  #necessary since weights column will always be selected
  } else {
    dataset <- dataset %>% dplyr::rename(weights = !!weights)

  }

  #select subgroup, if specified
  if(is.null(subgroup)){
    tabled.question <-  dataset %>% dplyr::select(!!question, weights)
  } else {
    tabled.question <-  dataset %>% dplyr::select(!!question, !!subgroup, weights)
  }

  #filter variables to exclude, if specified
  if(!is.null(levels_to_exclude)){
    tabled.question <- tabled.question %>%
      dplyr::filter(!!subgroup %ni% levels_to_exclude)}

  #compute dataset with and without subgroup sepereatly
  if(!is.null(subgroup)){
    tabled.question <-  tabled.question %>%
      group_by(!!question, !!subgroup) %>%
      count(!!question, wt = weights, name = 'n') %>%
      group_by(!!subgroup) %>%
      mutate(freq = n/sum(n))

    colnames(tabled.question) <- c('question', 'subgroup', 'n', 'freq')

  } else {
    tabled.question <- tabled.question %>%
      group_by(!!question) %>%
      count(!!question, wt = weights, 'n') %>%
      ungroup() %>%
      mutate(freq = n/sum(n))

    colnames(tabled.question) <- c('question', 'n', 'freq')
  }


  #Return only dataset
  if(return_data == TRUE){return(tabled.question)}

  ## Create Graph ##
    #create base graph
    graph.singlechoice <- ggplot(tabled.question, aes(x = question, y= freq, label = scales::percent(freq))) +
      geom_bar(stat = 'identity', color = '#296334', fill = '#586994') +
      geom_text(position = position_dodge(width = .9),    # move to center of bars
                vjust = -0.5,    # nudge above top of bar
                size = 3) +
      scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
      scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
      theme_minimal()

    #if subgroup is specified, facet graphs and add subtitle
    if(is.null(subgroup)){
      graph.singlechoice <- graph.singlechoice +
        labs(y = "", x = "", title = paste0('Variable: ', question),
             subtitle = paste("Filter: none"))

      return(graph.singlechoice)

     } else {
       graph.singlechoice <- graph.singlechoice +
        labs(y = "", x = "", title = paste('Variable: ', question),
             subtitle = paste("Filter: ",subgroup )) +
          facet_wrap(~subgroup, scales = "fixed", ncol = 2)

       return(graph.singlechoice)

    }
}


#sc_table






















