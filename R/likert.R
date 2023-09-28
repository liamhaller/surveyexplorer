#' Likert Summary
#' Summarize likert data
#'
#' @param data either a dataframe or a vector of likert data
#' @param low_is_agree Set true if 1 is agree/strongly agree so order will be disagree to agree
#' @param order_rows If true rows will be ordered by decreasing strongly agree values
#'
#' @return A dataframe of percentages corresponding to the share of each category
#' @importFrom purrr map_df
#' @importFrom tibble rownames_to_column
#'
#' @export
#'

likert_summary <- function(data, low_is_agree = FALSE, order_rows = FALSE){


  if(is.null(data)){
    stop("Data entered is NULL, please check it is a valid vector or dataframe")
  }
  #maybe add values to exclude
  if(!is.data.frame(data)){
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

  #order the columns of out according to name
  #!! no issue if they're numbers, (1-n), but could
  #produce unintended consequences if the name of variables
  #in that case will need to match to function
  #see https://stackoverflow.com/questions/7334644/sort-columns-of-a-dataframe-by-column-name
  out <- out[ , order(names(out))]

  #Reverse order of columns if lower numbers mean strongly agree
  if(low_is_agree == TRUE){
    out <- rev(out)
  }

  #Reorder rows based on the last column
  if(order_rows == TRUE){
    max_col <- ncol(out)
    out <- out[order(out[,max_col], decreasing = TRUE),]
  }
  #Round output and add rownames
  out <- round(out, 2)

  #data is in class = table, transform to numeric
  out <- tibble::rownames_to_column(out, "Item")

  out[,-1] <- sapply(out[-1], function(x) as.numeric(x))

  return(out)
}


#When likert graph prep gets added,
#make sure to add checks for the structure of the data






