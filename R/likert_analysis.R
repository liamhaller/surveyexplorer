#' Likert Summary
#' Summarize likert data
#'
#' @param data either a dataframe or a vector of likert data
#' @param high_to_low If true, the highest numbers will appear in the first column
#' @param order_rows If true rows will be ordered by largest to smallest
#'
#' @return A dataframe of percentages corresponding to the share of each category
#' @importFrom purrr map_df
#'
#' @export
#'

likert_summary <- function(data, high_to_low = TRUE, order_rows = FALSE){


  if(is.null(data)){
    stop("Data entered is NULL, please check it is a valid vector or dataframe")
  }
  #maybe add values to exclude

  if(class(data) != "data.frame"){
    dataframe <- as.data.frame(data)
    colnames(dataframe) <- c(quote(data))

  } else {
    dataframe <- data
  }

  #These will later become the rownames to distinguish the questions
  question_names <- colnames(dataframe)

  #Save unique answers (A1,A2,A3....)
  values <- unique(as.vector(as.matrix(dataframe)))

  #Drop NA from list, if it exists
  values <- values[!is.na(values)]

  #Sort the vector from low to high or high to low
  values <- sort(values)

  #calculate percentage present for each answer
  out <- map_df(dataframe, ~ prop.table(table(.x)))

  #save reslut as a data.frame so we can add row names
  out <- as.data.frame(out)
  rownames(out) <- question_names

  #Reverse order of columns if high_to_low is true
  if(high_to_low == TRUE){
    out <- rev(out)
  }

  #Reorder rows based on the last column
  if(order_rows == TRUE){
    max_col <- ncol(out)
    out <- out[order(out[,max_col], decreasing = TRUE),]
  }
  #Round output and add rownames
  out <- round(out, 2)

  return(out)
}
