
#' Structure of answers
#'
#' @param dataframe placeholder
#' @param category_threshold The number of unique answers to a question above which it is considered unstructured
#' @importFrom dplyr %>%
#' @return a dataframe indicating how many questions are an integer, numeric, logical, unstructured, or categorical
#' @export
#'
structure_answers <- function(dataframe, category_threshold = 20){

  #calculate number of variables that have each structure
  integer_count <- NCOL(dataframe[sapply(dataframe, class) == "integer"])
  numeric_count <- NCOL(dataframe[sapply(dataframe, class) == "numeric"])
  logical_count <- NCOL(dataframe[sapply(dataframe, class) == "logical"])

  df_char <- dataframe[,sapply(dataframe, class) == 'character']

  #decompose class == character into unstructured and categorical
  n_unique_response <- sapply(df_char, function(x) length(unique(x)))
  qual_columns <- which(unname(n_unique_response) > category_threshold)
  df_qual <- df_char[,qual_columns]
  df_cat <- df_char[,-qual_columns]

  #get counts of each
  unstructured_count <- NCOL(df_qual)
  categorical_count <- NCOL(df_cat)

  answer_structure <- data.frame(data_type = c('integer', 'numeric', 'logical', 'unstructured', 'categorical'),
                                 variable_count = c(integer_count,numeric_count,logical_count,unstructured_count,categorical_count))

  return(answer_structure)

}



#' Structure of categorical answeres
#'
#' @param dataframe placeholder
#' @param category_threshold The number of unique answers to a question above which it is considered unstructured
#' @importFrom dplyr %>% filter

#'
#' @return a list grouped by how many unique answers each variable has
#' @export
#'
structure_categories <- function(dataframe, category_threshold = 20){

  df_char <- dataframe[,sapply(dataframe, class) == 'character']
  #decompose class == character into unstructured and categorical
  n_unique_response <- sapply(df_char, function(x) length(unique(x)))
  qual_columns <- which(unname(n_unique_response) > category_threshold)
  df_cat <- df_char[,-qual_columns]

  #Get dataframe of all category column by total unique levels
  categories <- df_cat %>% sapply(unique) %>%  lapply(length) %>% unlist %>% as.data.frame
  colnames(categories) <- c('unique_responses')

  #Get list of total number of categories with unique levels
  unique_categories <- sort(unique(categories[,1]))

  #PRE LOOP
  #Establish empty vector for category names and list
  category_name <- vector(,length(unique_categories))
  categorical_variables <- list()
  for(i in seq_along(unique_categories)){

    #get list of names of each variable with set level of unique levels
    names <-categories %>% dplyr::filter(unique_responses ==  unique_categories[i]) %>% rownames %>% as.data.frame
    category_name[i] <- paste0(unique_categories[i], " unique levels") #save generated name for list

    #add to list
    categorical_variables <- c(categorical_variables, placeholder_name = names)

  }

  #rename list
  names(categorical_variables) <-  category_name


  ############# Now return list of answer options sorted by column ######

  generate_unique_level_list(dataframe, categorical_variables)

  final_list <- list()
  for(i in 1:length(categorical_variables)){

    final_list[[i]] <-  generate_unique_level_list(panel, categorical_variables[[i]])

  }

  return(final_list)

}





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
