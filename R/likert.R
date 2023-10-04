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

  #transform data to numeric and replace NA with 0
  out[,-1] <- sapply(out[-1], function(x) as.numeric(x))
  out[is.na(out)] <- 0


  return(out)
}


#When likert graph prep gets added,
#make sure to add checks for the structure of the data




#' Quickly plot likert data (3,5,7,9 levels)
#'
#' @param data Summerized likert data (first column must be names)
#' @param levels example text
#' @param colors example text
#'
#' @return example return
#' @export
#'
likert_graph <- function(data, labels = c("Strongly disagree", 'Disagree','Neutral','Agree','Strongly agre'),
                         colors =  c("#d73027","#E36A64","#FEEBD7", "#8ECF8C", "#66bd63")){


  #TODO
  #check if number of colors is same as number of levels

  numlabels <- length(labels)

  colnames(data) <- c('Item', labels)

  #Split the middle column in half in the graph
  #dentify the center column, incluidng the first column
  numcenter<-ceiling(NCOL(data)/2)+1

  #Replace middle column with values split in half and name columns
  namecenter <- colnames(data[numcenter])

  data <- data %>%
    mutate(midhigh = data[, numcenter] / 2, .after = all_of(namecenter)) %>%
    mutate(midlow = data[, numcenter] / 2, .after = all_of(namecenter)) %>%
    select(-all_of(namecenter))


  ##computer lower and upper bound of x axis on graph
  midlow <- match('midlow', colnames(data))
  lower_bound <- ceiling(max(rowSums(data[,2:midlow]))) *-100
  upper_bound <- ceiling(max(rowSums(data[,midlow:NCOL(data)])))*100


  #Prep data for graphing format
  data <- data %>%
    pivot_longer(2:NCOL(.), names_to = 'level')

  #multiply 'negitive' leveles by -1
  negitive_levels <- c(labels[1:ceiling(numlabels/2)], "midlow")
  data$value <- ifelse(data$level %in% negitive_levels,
                       data$value*-100, data$value*100 )


  ##Create fill column for the graph (must double middle color)
  colorcenter <- colors[numcenter-1]   #subtract one since color palette dosn't include extra label column
  doublemiddle_colors <- colors %>% as_tibble() %>%
    #insert before since numcenter includes quesetion column
    add_row(value = colorcenter, .before = numcenter) %>%
    pull(1)
  #add colum to dataframe
  data$colorslabel <- rep(doublemiddle_colors,
                          NROW(data)/length(doublemiddle_colors))


  #set order for x axis
  row_order <- data %>%
    filter(level ==  labels[length(labels)]) %>%
    arrange(-value) %>%
    pull(1) %>%
    as.character %>%
    rev

  graph.likert <- ggplot() +
    geom_bar(data=data, aes(x = factor(Item, levels = row_order), y=value, fill = colorslabel),
             position="stack", stat="identity") +
    geom_hline(yintercept = 0, linewidth = 2, color =c("white")) +
    scale_fill_manual(values = colors, labels = labels, breaks = colors) +
    scale_y_continuous(breaks=seq(lower_bound ,upper_bound,25),
                       limits=c(lower_bound,upper_bound),
                       labels = abs(seq(lower_bound, upper_bound, 25))) +
    scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 40)) +
    coord_flip() +
    labs(title = "",
         subtitle = "",
         x = "",
         y = "",
         fill = "")

  return(graph.likert)

}



