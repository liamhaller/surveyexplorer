#helper functions



#tranform a tibble column to an unnamed vector
#' Title
#'
#' @param tibblecolumn .
#'
#' @return .
#'
untibbled <- function(tibblecolumn){
  unlist(unname(as.vector(tibblecolumn)))
}






#' Generate unique level list
#'
#' @param dataframe .
#' @param column_names .
#' @importFrom purrr map_df
#' @importFrom rlang enexpr
#' @return .
#'
generate_unique_level_list <- function(dataframe, column_names){

  total_vars <- length(column_names)

  if (total_vars == 1) {


    answer_levels <- dataframe[,match(column_names, colnames(dataframe))] %>% unique %>% sort

    output <- data.frame(answer_levels)
    colnames(output) <- rlang::enexpr(column_names)
    unique_levels <- list()
    unique_levels[[1]] <- output

  } else {

    answer_levels <- dataframe[,match(column_names, colnames(dataframe))] %>% purrr::map_df(unique) %>% purrr::map_df(sort)
    unique_answer_levels <- answer_levels[!duplicated(as.list(answer_levels))]

    no_unique_levels <- NCOL(unique_answer_levels)

    #if there is only one answer category, the for loop will fail, so here we
    #handle that case by itself

    unique_levels <- list()
    for(i in 1:no_unique_levels){

      #Does the answer levels in the table(answer_levels) which contains all possible for each grou
      #match the uniqe level that is rotated by the forloop, if yes it should be included in the list
      string_match <- purrr::map_df(answer_levels, function(x) {
        dezim:::stringmatch(check_string = untibbled(unique_answer_levels[,i]), untibbled(x))
      })

      #a boolean vector of which columns matched the given string
      string_match <- untibbled(string_match)
      #the column names of the columns that matched the output
      matched_columns <- colnames(answer_levels[,string_match])

      df_name <- untibbled(unique_answer_levels[,i])
      #print(stringr::str_c(rlang::enexpr(df_name), collapse = ", "))
      output <- as.data.frame(matched_columns)
      colnames(output) <- stringr::str_c(rlang::enexpr(df_name), collapse = ",")

      unique_levels[[i]] <- output
    }
    #Now there is a list where each name is one of the unique levels
    #if a column's answer matches the answer's levels include append it to that list


  }

  return(unique_levels)
}
