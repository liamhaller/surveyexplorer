#' Find answer columns that match given answer choices
#'
#' @param dataframe placeholder
#' @param answer_pattern answers to look-up
#' @param categorical_only reccomended. only look at variables considered to be categorical
#' @param column_names placeholder
#'
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




#' Zreplace
#' Replace a given string with a new string in selected columns
#'
#' @param dataframe placeholder
#' @param columns_to_replace placeholder
#' @param old_text placeholder
#' @param new_text placeholder
#' @return dataset with values replaced in selected columns
#' @export
#'
#'
Zreplace <- function(dataframe, columns_to_replace, old_text, new_text) {

  ##Checks ##
  #ensure vector lengths are teh same
  if(length(old_text) != length(new_text)){
    stop("Length of old_text and new_text must be equal")
  }

  #TODO
  #Check to see if each (or maybe at least one) element of old_text
  #is contained within the col to replace

  #TODO
  #there's an issue if you want to replace just one element and leave the rest the same

  #save whether vectors are characters to use for processing during input
  old_text_character <- is.character(old_text)
  new_text_character <- is.character(new_text)


  base_expression <- rlang::expr('dataframe %>% dplyr::mutate(across(columns_to_replace, ~dplyr::case_when(')
  argument_string <- c()
  for(i in seq_along(old_text)){

    #Character inputs need to be wrapped in commas or else they will be recognized as objects
    #by the Dplyr processing
    old_text_input <- ifelse(old_text_character, paste0("'",old_text[i],"'"),old_text[i])
    new_text_input <- ifelse(new_text_character, paste0("'",new_text[i],"'"),new_text[i])

    #On the last run of the loop, the final symbol does not include a comma
    if(i == length(old_text)){
      argument_element <- paste0('. == ', old_text_input, ' ~ ', new_text_input)
    } else {
      argument_element <- paste0('. == ', old_text_input ,' ~ ', new_text_input, ',')
    }
    argument_string <- paste0(argument_string, argument_element)
  }


  expression <- paste0(base_expression, argument_string, ')))')
  eval(rlang::parse_expr(expression))
}





