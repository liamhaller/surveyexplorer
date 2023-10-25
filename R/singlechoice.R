
#' Visualize frequencies of single choice survey questions
#'
#' @param dataset Dataframe or a tibble containing survey question to be analyzed
#' @param question Name of the column in the `dataset` to be graphed
#' @param subgroup Optional variable to stratify the frequencies of `question` variable
#' @param levels_to_exclude Optional vector of levels of `subgroup` to exclude
#' @param weights Optional column containing survey weights
#' @param return_data If true, the function returns the filtered data to create custom graphs/tables
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
    #Check that provided levels are contained within subgroup variable
    subgroup_levels <- tabled.question %>%
      dplyr::select(!!subgroup) %>%
      unique %>%
      dplyr::pull(1) %>%
      as.character

    for(i in 1:length(levels_to_exclude)){ #vector has length at least 1
      if(levels_to_exclude[[i]] %ni% subgroup_levels){
        stop('Levels to exclude not found within subgroup variable')
      }
    }
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
      count(!!question, wt = weights, name = 'n') %>%
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
        labs(y = "", x = "", title = paste0('Question: ', question),
             subtitle = paste("Filter: none"))

      return(graph.singlechoice)

     } else {
       graph.singlechoice <- graph.singlechoice +
        labs(y = "", x = "", title = paste('Question: ', question),
             subtitle = paste("Filter: ",subgroup )) +
          facet_wrap(~subgroup, scales = "fixed", ncol = 2)

       return(graph.singlechoice)

    }
}


#sc_table

#' Summarize grouped counts and frequencies
#'
#' @param dataset Dataframe or a tibble containing survey question to be analyzed
#' @param question Name of the column in the `dataset` to be graphed
#' @param subgroup Optional variable to stratify the frequencies of `question` variable
#' @param levels_to_exclude Optional vector of levels of `subgroup` to exclude
#' @param weights Optional column containing survey weights
#' @param return_data If true, the function returns the filtered data to create custom graphs/tables
#'
#' @importFrom gt gt tab_style cols_label grand_summary_rows fmt_percent tab_header tab_footnote
#'
#' @return table of frequences
#' @export
#'
singlechoice_table <- function(dataset, question, subgroup = NULL,
                               levels_to_exclude = NULL, weights = NULL){


  question <- rlang::ensym(question)
  try(subgroup <- rlang::ensym(subgroup), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  data.table <- dataset %>%  singlechoice_graph(!!question,
                                              if(!is.null(subgroup)){subgroup},
                                              levels_to_exclude,
                                              if(!is.null(weights)){weights},
                                              return_data = TRUE)


  if(is.null(subgroup)){

    gt.table <-  data.table %>%
      gt(rowname_col = 'question') %>%
      tab_style(
        style = cell_text(align = "center"),
        locations = cells_column_labels()) %>%
      cols_label(matches('freq') ~ 'Frequency',
                 matches('n') ~ 'Count') %>%
      grand_summary_rows(columns = matches('n'),
                         fns =  list(label = md('**Column Totals**'), id = "totals", fn = "sum")) %>%
      grand_summary_rows(columns = matches('freq'),
                         fns =  list(label = md('**Column Totals**'), id = "totals", fn = "sum")) %>%
      fmt_percent(columns = contains('freq'), decimals = 2) %>%
      tab_header(
        title = paste0("Question: ", question))



  } else {

    gt.table <-  data.table %>%
    pivot_wider(names_from=c(subgroup),
                values_from=c(n,freq),
                names_glue = "{subgroup}_{.value}",
                names_sort = TRUE) %>%
      rowwise(question) %>%
      mutate(zztotal_n = sum(c_across(ends_with('_n')))) %>%
      ungroup() %>%
      mutate(zztotal_freq = zztotal_n/sum(zztotal_n)) %>%
      select(question, sort(colnames(.))) %>%
      gt(rowname_col = 'question', groupname_col = 'subgroup') %>%
      tab_spanner_delim(delim="_") %>%
      tab_style(
        style = cell_text(align = "center"),
        locations = cells_column_labels()) %>%
      tab_spanner(label = md('**Row Totals**'), columns = starts_with("zz"), level = 1, replace = TRUE) %>%
      cols_label(matches('freq') ~ 'Frequency',
                 matches('n') ~ 'Count') %>%
      grand_summary_rows(columns = matches('n'),
                         fns =  list(label = md('**Column Totals**'), id = "totals", fn = "sum")) %>%
      grand_summary_rows(columns = matches('freq'),
                         fns =  list(label = md('**Column Totals**'), id = "totals", fn = "sum")) %>%
      fmt_percent(columns = contains('freq'), decimals = 2)  %>%
      tab_header(
        title = paste0("Question: ", question),
        subtitle = paste0("Filter: ", subgroup))
  }


  if(!is.null(weights)){
    gt.table <- gt.table %>%
      tab_footnote(
        footnote = "Frequencies and counts are weighted") %>%
      fmt_number(columns = contains('n'), decimals = 1)

  }

  return(gt.table)
  }




















