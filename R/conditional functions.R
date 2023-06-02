#' Calculate conditional means
#'
#' `conditional_mean()` calculates the mean of `mean_var` conditional on the levels of `category_var`
#'
#' @param data Dataframe that contains both `mean_var` and `category_var`
#' @param mean_var Data that will be used in the calculation of means
#' @param category_var The categories across which the function will compute means
#'
#' @return a dataframe with the means of `mean_var` for each level of `category_var`
#' @export
#'
conditional_mean <- function(data, mean_var, category_var){

  #Which column in the dataset corresponds to the name provided
  #this makes refrenceing the vector easier
  category_column <- match(category_var, colnames(data))

  #column number of the variable we of which we'll take the mean
  mean_column <- match(mean_var, colnames(data))

  if(is.na(category_column)){
    stop(paste(substitute(mean_var), " was not found in dataset:", substitute(data)))
  }

  if(is.na(mean_column)){
    stop(paste(substitute(category_var), " was not found in dataset:", substitute(data)))
  }


  #All of the cateogires across which we will take the mean
  categories <- unique(data[,category_column])

  #sum list of TRUE/FALSE of whether each category is NA
  #will use to see if we should add NA as a category
  contains_na <- sum(is.na(unique(data[,category_column])))

  #redefine category without NA, so regular mean/sum function will work
  categories <- categories[!is.na(categories)]

  mean_function <- function(x){
    mean <-mean(data[data[,category_column] == x, mean_var], na.rm = T)
    return(mean)
  }

  sum_function <- function(x){
    sum <- sum(data[,category_column]== x, na.rm = T)
    return(sum)
  }

  output <- sapply(categories, mean_function)
  sum <- sapply(categories, sum_function)
  df <- data.frame(categories, output, sum)
  colnames(df) <- c(category_var, paste0(mean_var, " mean"), "total")

  #If category variable contains NA, we want to include it as a category
  if(contains_na > 0){
    #calculate mean of NA group
    na_mean <- mean(ukr[is.na(ukr[,category_column]),][,mean_column], na.rm = TRUE)
    #calculate sum of NA group (how many NA are in the categorical variable)
    na_sum <- sum(is.na(data[,category_column]))

    #add NA category metrics to the dataframe
    na_catagory_row <- c("NA", na_mean, na_sum)
    df <- rbind(df, na_catagory_row)

    ##calculated NA that are in both category and the mean variable, that cannot be included
    na_both <- sum(is.na(ukr[is.na(ukr[,category_column]),][,mean_column]))
    na_both_row <- c("NA", "NA", na_both)
    df <- rbind(df, na_both_row)

  }

  ###clean up dataframe
  #remove column names
  rownames(df) <- NULL

  ###round mean output
  #change column to numeric
  df[,2] <- suppressWarnings(as.numeric(df[,2]))
  df[,2] <- round(df[,2], 3)

  #total column should be numeric
  df[,3] <- as.numeric(df[,3])

  #sort by first column
  df <- df[order(df[,1]),]

  return(df)
  #return(output)
}





#' Calculate conditional medians
#'
#' @param median_var data that will be used in the calculation of medians
#' @param category_var The categories across which the function will compute medians
#' @param data Dataframe that contains both `median_var` and `category_var`
#' @importFrom stats median
#' @return a  dataframe with the means of `median_var` for each level of `category_var`
#' @export
#'

conditional_median<- function(data, median_var, category_var){

  #Which column in the dataset corresponds to the name provided
  #this makes refrenceing the vector easier
  category_column <- match(category_var, colnames(data))

  #column number of the variable we of which we'll take the mean
  median_column <- match(median_var, colnames(data))

  if(is.na(category_column)){
    stop(paste(substitute(median_var), " was not found in dataset:", substitute(data)))
  }

  if(is.na(median_column)){
    stop(paste(substitute(category_var), " was not found in dataset:", substitute(data)))
  }


  #All of the cateogires across which we will take the mean
  categories <- unique(data[,category_column])

  #sum list of TRUE/FALSE of whether each category is NA
  #will use to see if we should add NA as a category
  contains_na <- sum(is.na(unique(data[,category_column])))

  #redefine category without NA, so regular mean/sum function will work
  categories <- categories[!is.na(categories)]

  mean_function <- function(x){
    median <-median(data[data[,category_column] == x, median_var], na.rm = TRUE)
    return(median)
  }

  sum_function <- function(x){
    sum <- sum(data[,category_column]== x, na.rm = T)
    return(sum)
  }

  output <- sapply(categories, mean_function)
  sum <- sapply(categories, sum_function)
  df <- data.frame(categories, output, sum)
  colnames(df) <- c(category_var, paste0(median_var, " median"), "total")

  #If category variable contains NA, we want to include it as a category
  if(contains_na > 0){
    #calculate mean of NA group
    na_median <- median(ukr[is.na(ukr[,category_column]),][,median_column], na.rm = TRUE)
    #calculate sum of NA group (how many NA are in the categorical variable)
    na_sum <- sum(is.na(data[,category_column]))

    #add NA category metrics to the dataframe
    na_catagory_row <- c("NA", na_median, na_sum)
    df <- rbind(df, na_catagory_row)

    ##calculated NA that are in both category and the mean variable, that cannot be included
    na_both <- sum(is.na(ukr[is.na(ukr[,category_column]),][,median_column]))
    na_both_row <- c("NA", "NA", na_both)
    df <- rbind(df, na_both_row)

  }

  ###clean up dataframe
  #remove column names
  rownames(df) <- NULL

  ###round mean output
  #change column to numeric
  df[,2] <- suppressWarnings(as.numeric(df[,2]))
  df[,2] <- round(df[,2], 3)

  #total column should be numeric
  df[,3] <- as.numeric(df[,3])


  #sort by first column
  df <- df[order(df[,1]),]

  return(df)
  #return(output)
}







