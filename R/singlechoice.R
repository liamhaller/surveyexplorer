



#' Summarize count and frequency of a single choice survey question
#'
#' @param dataset Dataframe or a tibble containing the `question` column to be analyzed
#' @param question Name of the column in the `dataset` to be summerized
#' @param group_by Name of column in `dataset` used to partition the analysis into subgroups
#' @param subgroups_to_exclude vector that contains level(s) of `group_by` variable to exclude
#' @param weights Optional column containing survey weights
#' @importFrom rlang .data
#' @import dplyr
#' @return Dataframe of count and frequency for each
#' @export
#'
singlechoice_summary <- function(dataset, question, group_by = NULL,
                                 subgroups_to_exclude = NULL, weights = NULL){









  #Inputs to symbols to use with dplyr syntax
  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail


  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)

  ## Data pre-processing ##
  if(is.null(group_by) & !is.null(subgroups_to_exclude)){
    stop('Cannot specify `subgroups_to_exclude` without `group_by`.
           Please remove `subgroups_to_exclude` or specify a grouping variable')

  }

  #if weights are not specified create vector of 1s
  if(is.null(weights)){
    dataset$weights <- 1
    #if weights are specified, rename column to weights
    #necessary since weights column will always be selected
  } else {
    if(!is.numeric(dataset %>% pull(!!weights)))
      {stop('Please enter numeric vector for weights')}
    dataset <- dataset %>% rename(weights = !!weights)

  }

  #select group_by, if specified
  if(is.null(group_by)){
    tabled.question <-  dataset %>% select(!!question, weights) %>%
      #question need to be converted to factors and NAs added as levels
      #so that count(..., .drop = FALSE) will keep zero rows
      mutate(across(c(!!question), ~  addNA(.x, ifany = TRUE) ))

  } else {

    tabled.question <-  dataset %>%
      select(!!question, !!group_by, weights) %>%
      #question and group_by need to be converted to factors and NAs added as levels
      #so that count(..., .drop = FALSE) will keep zero rows
      mutate(across(c(!!question, !!group_by), ~  addNA(.x, ifany = TRUE) ))
  }

  #filter variables to exclude, if specified
  if(!is.null(subgroups_to_exclude)){
    #Check that provided levels are contained within group_by variable
    group_by_levels <- tabled.question %>%
      select(!!group_by) %>%
      unique %>%
      pull(1) %>%
      as.character

    for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
      if(subgroups_to_exclude[[i]] %ni% group_by_levels){
        stop('Levels to exclude not found within group_by variable')
      }
    }
    tabled.question <- tabled.question %>%
      filter(!!group_by %ni% subgroups_to_exclude) %>%
      droplevels() #drop (now) unused levels from variable
    #otherwise they would appear because of count(..., .drop = FALSE)


    }



  ## Sumerize data ##
  #compute dataset with and without group_by sepereatly
  n <- NULL #variable is created using NSE
  if(!is.null(group_by)){
    tabled.question <-  tabled.question %>%
      dplyr::group_by(!!question, !!group_by, .drop = FALSE) %>%
      count(!!question, wt = weights, name = 'n') %>%
      dplyr::group_by(!!group_by, .drop = FALSE) %>%
      mutate(freq = .data$n/sum(.data$n))

    colnames(tabled.question) <- c('question', 'group_by', 'n', 'freq')

  } else {
    tabled.question <- tabled.question %>%
      dplyr::group_by(!!question, .drop = FALSE) %>%
      count(!!question, wt = weights, name = 'n') %>%
      ungroup() %>%
      mutate(freq = n/sum(n))
      colnames(tabled.question) <- c('question', 'n', 'freq')
  }

  return(tabled.question)


}



#' Visualize frequencies of single choice survey questions
#'
#' @inheritParams singlechoice_summary
#'
#' @importFrom ggplot2 ggplot aes labs

#' @return A barchart of frequencies
#' @export
#'
#'
singlechoice_graph <- function(dataset, question, group_by = NULL,
                               subgroups_to_exclude = NULL, weights = NULL){

  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail


  tabled.question <- dataset %>% singlechoice_summary(!!question,
                                               if(!is.null(group_by)){group_by},
                                               subgroups_to_exclude,
                                               if(!is.null(weights)){weights})

  ## Create Graph ##
    #create base graph
    graph.singlechoice <- ggplot(tabled.question, aes(x = question, y= freq, label = scales::percent(freq))) +
      ggplot2::geom_bar(stat = 'identity', color = '#296334', fill = '#586994') +
      ggplot2::geom_text(position = ggplot2::position_dodge(width = .9),    # move to center of bars
                vjust = -0.5,    # nudge above top of bar
                size = 3) +
      ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
      ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
      ggplot2::theme_minimal()

    #if group_by is specified, facet graphs and add subtitle
    if(is.null(group_by)){
      graph.singlechoice <- graph.singlechoice +
        labs(y = "", x = "", title = paste0('Question: ', question))

      return(graph.singlechoice)

     } else {
       graph.singlechoice <- graph.singlechoice +
         ggplot2::labs(y = "", x = "", title = paste('Question: ', question),
             subtitle = paste("grouped by: ",group_by )) +
         ggplot2::facet_wrap(~group_by, scales = "fixed", ncol = 2)
       return(graph.singlechoice)

    }
}




#' Base table for single & multipe choice questions
#'
#' @param data.table Output from either mutli or single summary
#' @inheritParams singlechoice_summary
#' @importFrom stringr str_extract
#' @return Gt table
#'
frequency_table <- function(data.table, group_by){

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail


  #No subgroup
  if(is.null(group_by)){

    gt.table <-  data.table %>%
      gt::gt(rowname_col = 'question') %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels()) %>%
      gt::cols_label(ends_with('_freq') ~ 'Frequency',
                     ends_with('_n') ~ 'Count') %>%
      gt::grand_summary_rows(columns = matches('n'),
                             fns =  list(label = md('**Column Total**'), id = "totals", fn = "sum")) %>%
      gt::grand_summary_rows(columns = matches('freq'),
                             fns =  list(label = md('**Column Total**'), id = "totals", fn = "sum")) %>%
      gt::fmt_percent(columns = contains('freq'), decimals = 2)


    #with subgroup
  } else {
    #Define total count variabled, named zz because sorted alphabetically and should be last
    zztotal_n <- NULL

    gt.table <-  data.table %>%
      tidyr::pivot_wider(names_from=c(group_by),
                         values_from=c(n,freq),
                         names_glue = "{group_by}_{.value}",
                         names_sort = TRUE) %>%

      rowwise(question) %>%
      mutate(zztotal_n = sum(c_across(ends_with('_n')), na.rm = TRUE)) %>%
      ungroup() %>%
      mutate(zztotal_freq = zztotal_n/sum(zztotal_n)) %>%
      select(question, sort(names(.)))

    sample_size <- sum(data.table$n)


    columnwise_total <-
      gt.table %>%
      select(ends_with('_n')) %>%
      purrr::map_df(sum) %>%
      mutate(
        across(.cols = everything(),
               .fns = function(x) {x/sample_size},
               .names = "{str_extract(.col, pattern = '[^_]*')}_freq")
      ) %>%
      select(sort(names(.))) %>%
      mutate(question = "Columnwise Total", .before = everything())


    gt.table <- gt.table %>%
      add_row(columnwise_total) %>%

      gt::gt(rowname_col = 'question', groupname_col = 'group_by') %>%
      gt::tab_spanner_delim(delim="_") %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels()) %>%
      gt::tab_spanner(label = md('**Rowwise Total**'),
                      columns = dplyr::starts_with("zz"),
                      level = 1,
                      replace = TRUE,
                      id = 'rowwise'
      ) %>%
      gt::cols_label(ends_with('_freq') ~ 'Frequency',
                     ends_with('_n') ~ 'Count') %>%

      #Styling#
      #Make summary rows grey
      gt::fmt_percent(columns = contains('freq'), decimals = 2) %>%
      gt::tab_style(gt::cell_fill(color = '#d3d3d3'),
                    locations = list(
                      gt::cells_body(columns = dplyr::starts_with("zz")),
                      gt::cells_body(rows = dplyr::matches("Columnwise Total"))
                    )) %>%
      #Bold "columnwise total"
      gt::tab_style(gt::cell_text(weight = 'bold'),
                    locations = gt::cells_stub(rows = "Columnwise Total")
      )



  }
      return(gt.table)
}


#sc_table

#' Summarize grouped counts and frequencies
#'
#' @inheritParams singlechoice_summary
#' @param question Name of the column in the `dataset` to be graphed
#' @param group_by Optional variable to stratify the frequencies of `question` variable
#' @param subgroups_to_exclude Optional vector of levels of `group_by` to exclude
#' @param weights Optional column containing survey weights
#'
#' @importFrom gt md
#'
#' @return table of frequences
#' @export
#'
singlechoice_table <- function(dataset, question, group_by = NULL,
                               subgroups_to_exclude = NULL, weights = NULL){

  #Define dot as variable
  . <- NULL

  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  data.table <- dataset %>% singlechoice_summary(!!question,
                                              if(!is.null(group_by)){group_by},
                                              subgroups_to_exclude,
                                              if(!is.null(weights)){weights})

  gt.table <- frequency_table(data.table = data.table,
                              group_by =if(!is.null(group_by)){group_by})

  #Add names to the table
  if(is.null(group_by)){

    gt.table <- gt.table %>%
      gt::tab_header(
        title = paste0("Question: ", question))

  } else {

    gt.table <- gt.table %>%
      gt::tab_header(
        title = paste0("Question: ", question),
        subtitle = paste0("grouped by: ", group_by))

  }


  #if therey're weights, add a note
  if(!is.null(weights)){
    gt.table <- gt.table %>%
      gt::tab_footnote(
        footnote = "Frequencies and counts are weighted") %>%
      gt::fmt_number(columns = contains('n'), decimals = 1)

  }
  return(gt.table)
  }


















