#multiple choice


#mc_summary (data)

#' Title
#'
#' @inheritParams singlechoice_summary
#' @param question The columns that contain each of the response options, can be selected by
#' using **tidyselect** semanlatics or providing a vector of column names or numbers
#'
#' @return placehodler
#' @export
#'
multichoice_summary <- function(dataset, question, group_by = NULL, subgroups_to_exclude = NULL, weights = NULL){

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)

  ## Data Selection ##
  #Evaluate users selection and select from data
    data.question <-
      tidyselect::eval_select(
        expr = rlang::enquo(question),
        data = dataset)

    #Select data from dataframe with optional group_by/weights if provided
    data.summary <- case_when(
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
    #if weights are not specified create vector of 1s
    if(is.null(weights)){
      data.summary$weights <- 1
      #if weights are specified, rename column to weights
      #necessary since weights column will always be selected
    } else {
      data.summary <- data.summary %>% rename(weights = !!weights)
    }


    #filter variables to exclude, if specified
    if(!is.null(subgroups_to_exclude)){
      #Check that provided levels are contained within group_by variable
      group_by_levels <- data.summary %>%
        dplyr::select(!!group_by) %>%
        unique %>%
        pull(1) %>%
        as.character

      for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
        if(subgroups_to_exclude[[i]] %ni% group_by_levels){
          stop('Levels to exclude not found within group_by variable')
        }
      }
      tabled.question <- data.summary %>%
        filter(!!group_by %ni% subgroups_to_exclude)}

    ## Compute Frequencies ##
    #transform all cols that aren't weights to character for count
    weight_column <- match('weights', colnames(data.summary))
    data.summary[,-weight_column] <-  purrr::map_df(data.summary[,-weight_column], as.character)


    if(is.null(group_by)){
      #no subgroup specified
      data.summary <- data.summary %>%
        tidyr::pivot_longer(-weights, names_to = 'question', values_to = 'response') %>%
        dplyr::group_by(question) %>%
        count(response, wt = weights) %>%
        mutate(freq = n/sum(n)) %>%
        ungroup()
      colnames(data.summary) <- c('question', 'response', 'n', 'freq')



    } else {
      #subgroup specified
      data.summary <- data.summary %>%
        tidyr::pivot_longer(-c(weights, !!group_by), names_to = 'question', values_to = 'response') %>%
        dplyr::group_by(question, !!group_by) %>%
        count(response, wt = weights) %>%
        mutate(freq = n/sum(n)) %>%
        ungroup()

      colnames(data.summary) <- c('question', 'group_by', 'response', 'n', 'freq')

    }

    return(data.summary)


}


#mc graph

#' Title
#'
#' @inheritParams multichoice_summary
#' @inheritParams singlechoice_summary
#'
#' @return placehodler
#' @export
#'
multichoice_graph <- function(dataset, question, group_by = NULL, subgroups_to_exclude = NULL, weights = NULL){

  #ggupset required to make graph, but only used in this function
  if (!requireNamespace("ggupset", quietly = TRUE)) {
    stop(
      "Package \"ggupset\" must be installed to use this function.",
      call. = FALSE
    )
  }

  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  #function to identify what to exclude rather than what to include
  `%ni%` <- Negate(`%in%`)

  ## Data Selection ##
  #Evaluate users selection and select from data
  data.question <-
    tidyselect::eval_select(
      expr = rlang::enquo(question),
      data = dataset)

  #Select data from dataframe with optional group_by/weights if provided
  data.summary <- case_when(
    #Both subgroup and weights
    !is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by, !!weights),
    #Only group_by
    !is.null(group_by) &  is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!group_by),
    #only weights
    is.null(group_by) & !is.null(weights) ~ dataset %>%  dplyr::select(all_of(data.question),!!weights),
    #neither group_by nor weights
    TRUE ~ dataset %>%  dplyr::select(all_of(data.question))
  )


  ## Data pre-processing ##
  #if weights are not specified create vector of 1s
  if(is.null(weights)){
    data.summary$weights <- 1

    #if weights are specified, rename column to weights
    #necessary since weights column will always be selected
  } else {
    data.summary <- data.summary %>% rename(weights = !!weights)
    message('Estimes are only preciese to one significant digit, weights may have been rounded')
  }


  #filter variables to exclude, if specified
  if(!is.null(subgroups_to_exclude)){
    #Check that provided levels are contained within group_by variable
    group_by_levels <- data.summary %>%
      dplyr::select(!!group_by) %>%
      unique %>%
      pull(1) %>%
      as.character

    for(i in 1:length(subgroups_to_exclude)){ #vector has length at least 1
      if(subgroups_to_exclude[[i]] %ni% group_by_levels){
        stop('Levels to exclude not found within group_by variable')
      }
    }
    tabled.question <- data.summary %>%
      filter(!!group_by %ni% subgroups_to_exclude)}



  if(is.null(group_by)){
  #no subgroup
    mc_upset <- data.summary %>%
      as_tibble(rownames = "respondent") %>%
      tidyr::pivot_longer(-c(respondent, weights) , names_to = 'question') %>%
      filter(value != 0) %>%
      dplyr::group_by(respondent, weights) %>%
      summarize(question = list(question)) %>%
      dplyr::group_by(question) %>%
      summarise(count = round(sum(weights),0)) %>%
      tidyr::uncount(count) %>%
      ggplot2::ggplot(aes(x = question)) +
      ggplot2::geom_bar() +
      ggupset::scale_x_upset(order_by = 'freq')

    #if weights are specified, transform y axis to percentage (absoulte values loose meaning)
    if(length(unique(data.summary$weights)) > 1){
      mc_upset <- mc_upset +
      ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 1))
    }

  } else {
  #with subgroup
    mc_upset <- data.summary %>%
      as_tibble(rownames = "respondent") %>%
      tidyr::pivot_longer(-c(respondent, !!group_by, weights) , names_to = 'question') %>%
      filter(value != 0) %>%
      dplyr::group_by(respondent, !!group_by, weights) %>%
      summarize(question = list(question)) %>%
      dplyr::group_by(question, !!group_by) %>%
      summarise(count = round(sum(weights),0)) %>%
      tidyr::uncount(count) %>%
      ggplot2::ggplot(aes(x = question, fill = !!group_by)) +
      ggplot2::geom_bar() +
      ggupset::scale_x_upset(order_by = 'freq')

    #if weights are specified, transform y axis to percentage (absoulte values loose meaning
    if(length(unique(data.summary$weights)) > 1){
      mc_upset <- mc_upset +
      ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 1))
      }


  }


  return(mc_upset)




}




#mc table

#' Title
#' @inheritParams multichoice_summary
#'
#' @return gt table
#' @export
#'
multichoice_table <- function(dataset, question, group_by = NULL,
                              subgroups_to_exclude = NULL, weights = NULL){


  try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail

  data.table <- multichoice_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights})


    #only include 'selected' counts
    data.table <- data.table %>%
    filter(response != 0) %>%
    select(-response)


  #create base of table
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








