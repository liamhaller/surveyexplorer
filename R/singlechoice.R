



#' Generate a summary table for a single categorical variable, providing counts and frequencies.
#'
#' This function analyzes a specified categorical variable, `question`,
#' optionally grouping by another variable, `group_by`. Counts and frequencies
#' are computed, taking into account provided survey weights. Subgroups can be
#' excluded, and NAs can be removed if necessary.
#'
#' @param dataset The input dataframe (or tibble) of survey questions
#' @param question The categorical variable of interest for which frequencies
#'   and counts will be calculated, can be selected by using **tidyselect**
#'   semantics
#' @param group_by Optional variable to group the analysis. If provided, the
#'   frequencies and counts will be calculated within each subgroup.
#' @param subgroups_to_exclude Optional vector specifying subgroups to exclude
#'   from the analysis.
#' @param weights Optional variable containing survey weights. If provided,
#'   frequencies and counts will be weighted accordingly.
#' @param na.rm Logical indicating whether to remove NA values from `question`
#'   before analysis.
#' @importFrom rlang .data
#' @importFrom dplyr all_of across %>%
#'
#' @return A tabled data frame with counts and frequencies for the specified
#'   variable and optional grouping variable. The output is pre-processed,
#'   considering subgroup exclusions, NA removal, and survey weights if
#'   provided.
#'
#' @export
#'
#' @family single-choice questions
#'
single_summary <- function(dataset,
                           question,
                           group_by = NULL,
                           subgroups_to_exclude = NULL,
                           weights = NULL,
                           na.rm){


  #Inputs to symbols to use with dplyr syntax
  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  n <- freq <- NULL


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
    if(!is.numeric(dataset %>% dplyr::pull(!!weights)))
      {stop('Please enter numeric vector for weights')}
    dataset <- dataset %>% dplyr::rename(weights = !!weights)

  }

  #remove NAs if specified
  if(isTRUE(na.rm)){
    dataset <- dataset %>%  dplyr::filter(!is.na(!!question))
  }


  #select question column  (group_by too, if specified)
  if(is.null(group_by)){
    tabled.question <-  dataset %>% dplyr::select(!!question, weights) %>%
      #question need to be converted to factors and NAs added as levels
      #so that count(..., .drop = FALSE) will keep zero rows
      dplyr::mutate(across(c(!!question), ~  addNA(.x, ifany = TRUE) ))

  } else {

    tabled.question <-  dataset %>%
      dplyr::select(!!question, !!group_by, weights) %>%
      #question and group_by need to be converted to factors and NAs added as levels
      #so that count(..., .drop = FALSE) will keep zero rows
      dplyr::mutate(across(c(!!question, !!group_by), ~  addNA(.x, ifany = TRUE) ))
  }

  #filter variables to exclude, if specified
  if(is.null(group_by) & !is.null(subgroups_to_exclude)){
    stop('Cannot specify `subgroups_to_exclude` without `group_by`.
           Please remove `subgroups_to_exclude` or specify a grouping variable')

  }

  if(!is.null(subgroups_to_exclude)){
    #Check that provided levels are contained within group_by variable
    group_by_levels <- tabled.question %>%
      dplyr::select(!!group_by) %>%
      unique %>%
      dplyr::pull(1) %>%
      as.character

    for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
      if(subgroups_to_exclude[[i]] %ni% group_by_levels){
        stop('Levels to exclude not found within group_by variable')
      }
    }
    tabled.question <- tabled.question %>%
      dplyr::filter(!!group_by %ni% subgroups_to_exclude) %>%
      droplevels() #drop (now) unused levels from variable
    #otherwise they would appear because of count(..., .drop = FALSE)


    }



  ## Sumerize data ##
  #compute dataset with and without group_by seperately
  #count of observations for each category, created in "count"
  #count of category divided by observations, created in "mutate"
  if(!is.null(group_by)){
    tabled.question <-  tabled.question %>%
      dplyr::group_by(!!question, !!group_by, .drop = FALSE) %>%
      dplyr::count(!!question, wt = weights, name = 'n') %>%
      dplyr::group_by(!!group_by, .drop = FALSE) %>%
      dplyr::mutate(freq = .data$n/sum(.data$n))

    colnames(tabled.question) <- c('question', 'group_by', 'n', 'freq')

  } else {
    tabled.question <- tabled.question %>%
      dplyr::group_by(!!question, .drop = FALSE) %>%
      dplyr::count(!!question, wt = weights, name = 'n') %>%
      dplyr::ungroup() %>%
      dplyr::mutate(freq = n/sum(n))
      colnames(tabled.question) <- c('question', 'n', 'freq')
  }


  return(tabled.question)


}



#' Plot frequencies of responses for a single-choice question.
#'
#' generates a  bar chart of class ggplot illustrating how responses are
#' distributed for a specific single-choice question. If you provide a grouping
#' variable using `group_by` the chart includes facets for each subgroup.
#' Additionally, if you specify survey weights with `weights` the chart reflects
#' weighted response frequencies.
#'
#'
#' @inheritParams single_summary
#' @importFrom ggplot2 ggplot aes labs
#' @importFrom dplyr %>%
#' @return A ggplot2 object with a bar chart displaying response frequencies. If
#'   "group_by" is provided, facets show subgroup details. If "weights" are
#'   specified, the chart displays weighted frequencies.
#'
#' @examples
#'
#'
#' #Simple barchart
#' single_freq(berlinbears, question = income)
#'
#' #Use `group_by` to facet the graph into several groups
#' single_freq(berlinbears, question = income, group_by = gender)
#'
#' #to ignore a subgroup, use `subgroups_to_exclude`
#' single_freq(berlinbears, question = income, group_by = species,
#' subgroups_to_exclude = c('black bear', NA))
#'
#' #Specify survey weights with `weights`
#' single_freq(berlinbears, question = h_winter, group_by = gender, weights = weights)
#'
#' #to ignore NA values in the responses to `question`, set na.rm = TRUE
#' single_freq(berlinbears, question = h_winter, na.rm = TRUE)
#'
#' @export
#'
#' @family single-choice questions

single_freq <- function(dataset,
                        question,
                        group_by = NULL,
                        subgroups_to_exclude = NULL,
                        weights = NULL,
                        na.rm = FALSE){

  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  freq <- NULL #imported from single_summary function, needed to avoid visible global binding note


  #Generate a summary table for "question", including counts and frequencies
  tabled.question <- dataset %>% single_summary(!!question,
                                               if(!is.null(group_by)){group_by},
                                               subgroups_to_exclude,
                                               if(!is.null(weights)){weights},
                                                na.rm)

  ## Create Graph ##
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




#' Base table for single & multiple choice questions
#'
#' @param data.table Output from either mutli or single summary
#' @inheritParams single_summary
#' @importFrom stringr str_extract
#' @importFrom dplyr c_across %>% ends_with
#' @return Gt table
#'
frequency_table <- function(data.table, group_by){

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  . <- freq <- question <- everything <-  NULL #created useing NSE, necessary to avoid visible binding note

  #No subgroup
  if(is.null(group_by)){

    gt.table <-  data.table %>%
      gt::gt(rowname_col = 'question') %>%
      gt::tab_style(
        style = gt::cell_text(align = "center"),
        locations = gt::cells_column_labels()) %>%
      gt::cols_label(ends_with('_freq') ~ 'Frequency',
                     ends_with('_n') ~ 'Count') %>%
      gt::grand_summary_rows(columns = dplyr::matches('n'),
                             fns =  list(label = md('**Column Total**'), id = "totals", fn = "sum")) %>%
      gt::grand_summary_rows(columns = dplyr::matches('freq'),
                             fns =  list(label = md('**Column Total**'), id = "totals", fn = "sum")) %>%
      gt::fmt_percent(columns = dplyr::contains('freq'), decimals = 2)


    #with subgroup
  } else {
    #Define total count variabled, named zz because sorted alphabetically and should be last
    zztotal_n <- NULL

    gt.table <-  data.table %>%
      tidyr::pivot_wider(names_from=c(group_by),
                         values_from=c(n,freq),
                         names_glue = "{group_by}_{.value}",
                         names_sort = TRUE) %>%

      dplyr::rowwise(question) %>%
      dplyr::mutate(zztotal_n = sum(c_across(ends_with('_n')), na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(zztotal_freq = zztotal_n/sum(zztotal_n)) %>%
      dplyr::select(question, sort(names(.)))

    sample_size <- sum(data.table$n)


    columnwise_total <-
      gt.table %>%
      dplyr::select(ends_with('_n')) %>%
      purrr::map_df(sum) %>%
      dplyr::mutate(
        across(.cols = everything(),
               .fns = function(x) {x/sample_size},
               .names = "{str_extract(.col, pattern = '[^_]*')}_freq")
      ) %>%
      dplyr::select(sort(names(.))) %>%
      dplyr::mutate(question = "Columnwise Total", .before = everything())


    gt.table <- gt.table %>%
      dplyr::add_row(columnwise_total) %>%

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
      gt::fmt_percent(columns = dplyr::contains('freq'), decimals = 2) %>%
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



#' Create a table of frequencies and counts for single-choice questions
#'
#' Generates a detailed table summarizing the frequencies and counts for each level
#' of the specified variable, `question`. If a grouping variable, `group_by`, is provided,
#' the table extends to include row and column totals, along with additional count and
#' frequency columns for each level of `group_by` (excluding specified subgroups, if any).
#' When survey weights are specified with `weights`, the counts reflect the weighted values,
#' and a note is appended at the bottom of the table.
#'
#' @inheritParams single_summary
#' @importFrom gt md
#'
#' @return A gt table summarizing frequencies and counts based on the specified
#'   parameters. If the optional `group_by` parameter is provided, the output
#'   will be a grouped gt table, displaying frequencies and counts for each
#'   subgroup as well as row and column totals.
#' @examples
#' #Simple table
#' single_table(berlinbears, question = income)
#'
#' #Use `group_by` to partition the question into several groups
#' single_table(berlinbears, question = income, group_by = gender)
#'
#' #to ignore a subgroup, use `subgroups_to_exclude`
#' single_table(berlinbears, question = income, group_by = species,
#' subgroups_to_exclude = c('black bear', NA))
#'
#' #Specifiy survey weights with `weights`
#'  single_table(berlinbears, question = h_winter, group_by = gender,
#'  weights = weights)
#'
#' #to ignore NA values in the responses to `question`, set na.rm = TRUE
#' single_table(berlinbears, question = h_winter, na.rm = TRUE)
#'
#'
#' @export
#'
#'
#' @family single-choice questions
#'
single_table <- function(dataset,
                         question,
                         group_by = NULL,
                         subgroups_to_exclude = NULL,
                         weights = NULL,
                         na.rm = FALSE){


  question <- rlang::ensym(question)
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  . <- NULL  #to avoid visible binding note

  data.table <- dataset %>% single_summary(!!question,
                                              if(!is.null(group_by)){group_by},
                                              subgroups_to_exclude,
                                              if(!is.null(weights)){weights},
                                              na.rm)

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
      gt::fmt_number(columns = dplyr::contains('n'), decimals = 1)

  }
  return(gt.table)
  }


















