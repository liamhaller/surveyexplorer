#multiple choice



#' Compute summary statistics for a multiple choice questions
#'
#' This function generates summary statistics, including frequencies, based on
#' the provided question. It allows for optional grouping and weighting of data.
#'
#' @inheritParams single_summary
#' @param question The columns that contain each of the response options for a
#'   question, can be selected by using **tidyselect** semanatics or providing a
#'   vector of column names or numbers
#' @importFrom dplyr if_all
#' @return A data frame containing summary statistics, including frequencies,
#'   for the specified question.
#' @export
#'
#' @family multiple-choice questions
#'
multi_summary <- function(dataset,
                          question,
                          group_by = NULL,
                          subgroups_to_exclude = NULL,
                          weights = NULL,
                          na.rm = FALSE){

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  response <- NULL #created useing NSE, necessary to avoid visible binding note


  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)

  ## Data Selection ##
  #Evaluate users selection and select from data
    data.question <-
      tidyselect::eval_select(
        expr = rlang::enquo(question),
        data = dataset)


    #Select data from dataframe with optional group_by/weights if provided
    data.summary <- dplyr::case_when(
      #Both subgroup and weights
      !is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by, !!weights),
      #Only group_by
      !is.null(group_by) & is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by),
      #only weights
      is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!weights),
      #neither group_by nor weights
      TRUE ~ dataset %>%  dplyr::select(all_of(data.question))
    )


    ## Data pre-processing ##
    #remove NAs if specified
    if(isTRUE(na.rm)){
      data.summary <- data.summary %>% dplyr::filter(if_all(-!!group_by,  ~ !is.na(.x)))
    }



    if(is.null(group_by) & !is.null(subgroups_to_exclude)){
      stop('Cannot specify `subgroups_to_exclude` without `group_by`.
           Please remove `subgroups_to_exclude` or specify a grouping variable')

    }


    #if weights are not specified create vector of 1s
    if(is.null(weights)){
      data.summary$weights <- 1
      #if weights are specified, rename column to weights
      #necessary since weights column will always be selected
    } else {
      data.summary <- data.summary %>% dplyr::rename(weights = !!weights)
    }


    #filter variables to exclude, if specified
    if(!is.null(subgroups_to_exclude)){
      #Check that provided levels are contained within group_by variable
      group_by_levels <- data.summary %>%
        dplyr::select(!!group_by) %>%
        unique %>%
        dplyr::pull(1) %>%
        as.character

      for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
        if(subgroups_to_exclude[[i]] %ni% group_by_levels){
          stop('Levels to exclude not found within group_by variable')
        }
      }
      data.summary <- data.summary %>%
        dplyr::filter(!!group_by %ni% subgroups_to_exclude)}

    ## Compute Frequencies ##
    #transform all cols that aren't weights to character for count
    weight_column <- match('weights', colnames(data.summary))
    data.summary[,-weight_column] <-  purrr::map_df(data.summary[,-weight_column], as.character)


    if(is.null(group_by)){
      #no subgroup specified
      data.summary <- data.summary %>%
        tidyr::pivot_longer(-weights, names_to = 'question', values_to = 'response') %>%
        dplyr::group_by(question) %>%
        dplyr::count(response, wt = weights) %>%
        dplyr::mutate(freq = n/sum(n)) %>%
        dplyr::ungroup()
      colnames(data.summary) <- c('question', 'response', 'n', 'freq')

    } else {
      #subgroup specified
      data.summary <- data.summary %>%
        tidyr::pivot_longer(-c(weights, !!group_by), names_to = 'question', values_to = 'response') %>%
        dplyr::group_by(question, !!group_by) %>%
        dplyr::count(response, wt = weights) %>%
        dplyr::mutate(freq = n/sum(n)) %>%
        dplyr::ungroup()

      colnames(data.summary) <- c('question', 'group_by', 'response', 'n', 'freq')

    }


    return(data.summary)


}



#' Generate an UpSet plot for multiple-choice questions
#'
#' Visualize multiple-choice question responses with an upset plot, a visual
#' tool for exploring the overlap and distribution of multiple-choice question
#' responses. The function supports optional subgrouping of data using the
#' `group_by` variable, exclusion of specific subgroups with
#' 'subgroups_to_exclude,' and data weighting with the 'weights' parameter.
#' Users can also choose to exclude NA values from the questions prior to
#' analysis using the 'na.rm' parameter.
#'
#' @inheritParams multi_summary
#' @inheritParams single_summary
#'
#'
#' @examples
#'
#' #Use dplyr to select questions
#' library(dplyr)
#'
#' #Basic Upset plot
#'
#' #Use `group_by` to partition the question into several groups
#'  multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by
#'  = gender)
#'
#' #to ignore a subgroup, use `subgroups_to_exclude`
#' multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by =
#' gender, subgroups_to_exclude = NA)
#'
#' #Specifiy survey weights with `weights`
#'  multi_freq(berlinbears, question = dplyr::starts_with('will_eat'), group_by
#'  = gender, weights = weights)
#'
#'
#'
#' @return An upset plot visualizing the distribution of responses to the multiple-choice question.
#'
#' @export
#'
#' @family multiple-choice questions
#'
multi_freq <- function(dataset,
                              question,
                              group_by = NULL,
                              subgroups_to_exclude = NULL,
                              weights = NULL,
                              na.rm = FALSE){

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  value <- count <- respondent <- NULL #created useing NSE, necessary to avoid visible binding note

  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)

  ## Data Selection ##
  #Evaluate users selection and select from data
  data.question <-
    tidyselect::eval_select(
      expr = rlang::enquo(question),
      data = dataset)

  #Select data from dataframe with optional group_by/weights if provided
  data.summary <- dplyr::case_when(
    #Both subgroup and weights
    !is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by, !!weights),
    #Only group_by
    !is.null(group_by) &  is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by),
    #only weights
    is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!weights),
    #neither group_by nor weights
    TRUE ~ dataset %>%  dplyr::select(all_of(data.question))
  )


  ## Data Validation ##

  #Make sure data is in correct format (only 1s and 0s)
  #create list with all unique responses for each column
  responses <- data.summary %>%
    dplyr::select(-c(!!group_by, !!weights)) %>%
    purrr::map(.f = unique) %>%
    unique

  #test to make sure each column only contains 1s, 0s or NAs
  for(i in 1:length(responses)){
    if(!all(responses[[i]] %in% c(1,0,NA))){
      stop('Multiple choice question data should consist of only 1s, 0s, or NA values')
    }
  }



  ## Data pre-processing ##
  #remove NAs if specified
  if(isTRUE(na.rm)){
    data.summary <- data.summary %>% dplyr::filter(if_all(-!!group_by,  ~ !is.na(.x)))
  }

  #if weights are not specified create vector of 1s
  if(is.null(weights)){
    data.summary$weights <- 1

    #if weights are specified, rename column to weights
    #necessary since weights column will always be selected
  } else {
    data.summary <- data.summary %>% dplyr::rename(weights = !!weights)
    message('Estimes are only preciese to one significant digit, weights may have been rounded')
  }


  #filter variables to exclude, if specified
  if(!is.null(subgroups_to_exclude)){
    #Check that provided levels are contained within group_by variable
    group_by_levels <- data.summary %>%
      dplyr::select(!!group_by) %>%
      unique %>%
      dplyr::pull(1) %>%
      as.character

    for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
      if(subgroups_to_exclude[[i]] %ni% group_by_levels){
        stop('Levels to exclude not found within group_by variable')
      }
    }
    data.summary <- data.summary %>%
      dplyr::filter(!!group_by %ni% subgroups_to_exclude)}


  if(is.null(group_by)){
  #no subgroup
    mc_upset <- data.summary %>%
      dplyr::as_tibble(rownames = "respondent") %>%
      tidyr::pivot_longer(-c(respondent, weights), names_to = 'question') %>%
      dplyr::filter(value != 0) %>%
      dplyr::group_by(respondent, weights) %>%
      dplyr::summarize(question = list(question)) %>%
      dplyr::group_by(question) %>%
      dplyr::summarise(count = round(sum(weights),0)) %>%
      tidyr::uncount(count) %>%
      ggplot2::ggplot(aes(x = question)) +
      ggplot2::geom_bar() +
      ggupset::scale_x_upset(order_by = 'freq') +
      labs(x = "", y = "", fill = "")

    #if weights are specified, transform y axis to percentage (absoulte values loose meaning)
    if(length(unique(data.summary$weights)) > 1){
      mc_upset <- mc_upset +
      ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 1))
    }

  } else {
  #with subgroup
    mc_upset <- data.summary %>%
      dplyr::as_tibble(rownames = "respondent") %>%
      tidyr::pivot_longer(-c(respondent, !!group_by, weights) , names_to = 'question') %>%
      dplyr::filter(value != 0) %>%
      dplyr::group_by(respondent, !!group_by, weights) %>%
      dplyr::summarize(question = list(question)) %>%
      dplyr::group_by(question, !!group_by) %>%
      dplyr::summarise(count = round(sum(weights),0)) %>%
      tidyr::uncount(count) %>%
      ggplot2::ggplot(aes(x = question, fill = !!group_by)) +
      ggplot2::geom_bar() +
      ggupset::scale_x_upset(order_by = 'freq') +
      labs(x = "", y = "", fill = "")

    #if weights are specified, transform y axis to percentage (absoulte values loose meaning
    if(length(unique(data.summary$weights)) > 1){
      mc_upset <- mc_upset +
      ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 1))
      }


  }


  return(mc_upset)




}





#' Create a table of frequencies and counts for multiple-choice questions
#'
#' Generates a table presenting the distribution of responses for a specified
#' multiple-choice question. If a grouping variable, `group_by`, is provided,
#' the table extends to include row and column totals, along with additional count and
#' frequency columns for each level of `group_by` (excluding specified subgroups, if any).
#' When survey weights are specified with `weights`, the counts reflect the weighted values,
#' and a note is appended at the bottom of the table.
#'
#'
#'
#' @inheritParams multi_summary
#'
#' @return A gt table displaying frequencies and counts for the specified multiple-choice question.
#' If a grouping variable is provided, the table includes subgroups for a comprehensive analysis.
#' If survey weights are specified, the table notes that frequencies and counts are weighted.
#'
#'
#' @examples
#' #Basic Table
#'  multi_table(berlinbears, question = dplyr::starts_with('will_eat'))
#'
#' #Use `group_by` to partition the question into several groups
#'  multi_table(berlinbears, question = dplyr::starts_with('will_eat'), group_by
#'  = gender)
#'
#' #to ignore a subgroup, use `subgroups_to_exclude`
#' multi_table(berlinbears, question = dplyr::starts_with('will_eat'), group_by
#' = gender, subgroups_to_exclude = NA)
#'
#' #Specifiy survey weights with `weights`
#'  multi_table(berlinbears, question = dplyr::starts_with('will_eat'), group_by
#'  = gender, weights = weights)
#'
#'
#' @export
#'
#' @family multiple-choice questions
#'
multi_table <- function(dataset,
                              question,
                              group_by = NULL,
                              subgroups_to_exclude = NULL,
                              weights = NULL,
                              na.rm = FALSE){

  #save user input for name of table
  question_name <-  deparse(substitute(question))
  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  contains <- response <- freq <- NULL #created useing NSE, necessary to avoid visible binding note

  data.table <- multi_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights},
                                    na.rm)

  ## Data Validation ##

  #Make sure data is in correct format (only 1s and 0s)
  responses <- data.table %>%
    dplyr::pull(response) %>%
    unique

  #if all of the responses are correct format
  if( !all(responses %in% c(1,0,NA)) ){
    stop('Multiple choice question data should consist of only 1s, 0s, or NA values')
  }

  #only include 'selected' counts
  data.table <- data.table %>%
    dplyr::filter(response != 0) %>%
    dplyr::select(-response) %>%
    #0.2.0 Add default arrange
    dplyr::arrange(dplyr::desc(freq), .by_group = ifelse(is.null(group_by), FALSE, TRUE))

  #create base of table
  gt.table <- frequency_table(data.table = data.table,
                              group_by =if(!is.null(group_by)){group_by})



  #Add names to the table
  if(is.null(group_by)){

    gt.table <- gt.table %>%
      gt::tab_header(
        title = paste0("Question: ", question_name))

  } else {

    gt.table <- gt.table %>%
      gt::tab_header(
        title = paste0("Question: ", question_name),
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








