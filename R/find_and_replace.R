#' Find answer columns that match given answer choices
#'
#' @param dataframe placeholder
#' @param answer_pattern answers to look-up
#' @param categorical_only reccomended. only look at variables considered to be categorical
#' @param column_names placeholder
#'
#' @importFrom dplyr %>%
#'
#' @return column numbers that match the given string, or if column_names = TRUE then the names of the columns
#' @export
#'
Zfind <- function(dataframe, answer_pattern, categorical_only = TRUE, column_names = FALSE){

  if(categorical_only == TRUE){
    categorical_columns <- structure_categories(dataframe) %>% unlist(use.names = FALSE)
  } else {
    categorical_columns <- seq_along(dataframe)
  }

  answer_pattern <- sort(answer_pattern)

  matched_columns <- dataframe[,match(categorical_columns, colnames(dataframe))] %>%
    sapply(unique) %>%
    sapply(sort) %>%
    lapply(stringmatch, check_string = answer_pattern) %>%
    unlist(use.names = TRUE) %>%
    which() %>%
    names()

  matched_columns_to_og <- match(matched_columns, colnames(dataframe))

  if(column_names == TRUE){
    return(names(dataframe[,matched_columns_to_og])
    )

  } else {

    return(matched_columns_to_og)
  }

}


#' Stringmatch
#'
#' @param check_string placeholder
#' @param test_string placeholder
#'
#' @return placeholder
#'
stringmatch <- function(check_string, test_string){
  return(all(test_string %in% check_string))
}



#' Zreplace
#' Replace a given string with a new string in selected columns
#'
#' @param dataframe placeholder
#' @param columns_to_replace placeholder
#' @param old_text placeholder
#' @param new_text placeholder
#' @importFrom rlang expr parse_expr
#' @return dataset with values replaced in selected columns
#' @export
#'
Zreplace <- function(dataframe, columns_to_replace, old_text, new_text) {

  #check old tex == new text length

  base_expression <- expr('dataframe %>% mutate(across(columns_to_replace, ~case_when(')

  argument_string <- c()
  for(i in seq_along(old_text)){

    if(i == length(old_text)){
      #version without comma
      argument_element <- paste0('. == ', paste0("'",old_text[i],"'"),' ~ ', new_text[i])

    } else{
      argument_element <- paste0('. == ',  paste0("'",old_text[i],"'"),' ~ ', new_text[i], ',')
    }

    argument_string <- paste0(argument_string, argument_element)


  }

  expression <- paste0(base_expression, argument_string, ')))')
  eval(parse_expr(expression))

}

