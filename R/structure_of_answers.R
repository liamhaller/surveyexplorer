
#' Structure of answers
#'
#' @param dataframe placeholder
#' @param category_threshold The number of unique answers to a question above which it is considered unstructured
#' @importFrom dplyr %>%
#' @return a dataframe indicating how many questions are an integer, numeric, logical, unstructured, or categorical
#'
#' @export
structure_answers <- function(dataframe, category_threshold = 20){

  #calculate number of variables that have each structure
  integer_count <- NCOL(dataframe[sapply(dataframe, class) == "integer"])
  numeric_count <- NCOL(dataframe[sapply(dataframe, class) == "numeric"])
  logical_count <- NCOL(dataframe[sapply(dataframe, class) == "logical"])

  df_char <- dataframe[,sapply(dataframe, class) == 'character']

  #decompose class == character into unstructured and categorical
  n_unique_response <- sapply(df_char, function(x) length(unique(x)))

  qual_columns <- which(unname(n_unique_response) > category_threshold)
  if(length(qual_columns) > 0){
    df_qual <- df_char[,qual_columns]
    df_cat <- df_char[,-qual_columns]
    } else {
    #if no cols have > category_threshold unique answers set all to be df_cat
    df_cat <- df_char
    df_qual <- df_char[,qual_columns]
  }




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
#'
#' @export
structure_categories <- function(dataframe, category_threshold = 20){

  df_char <- dataframe[,sapply(dataframe, class) == 'character']
  #decompose class == character into unstructured and categorical
  n_unique_response <- sapply(df_char, function(x) length(unique(x)))

  #Remove qual columns that have greater than category_threshold unique answers
  #since they are likely unstructured data
  qual_columns <- which(unname(n_unique_response) > category_threshold)
  if(length(qual_columns) > 0){
    df_cat <- df_char[,-qual_columns]
  } else {
    #if no cols have > category_threshold unique answers set all to be df_cat
    df_cat <- df_char
  }

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


  return(categorical_variables)


}


#' Get structure of answer levels
#'
#' @param dataframe .
#'
#' @return .
#'
#' @export
struct_level <- function(dataframe){

  categorical_variables <- structure_categories(dataframe)

  final_list <- list()
  for(i in 1:length(categorical_variables)){

    final_list[[i]] <-  generate_unique_level_list(dataframe, categorical_variables[[i]])

  }

  return(final_list)


}




















