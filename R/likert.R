
#' Plot Likert-scale responses using ggplot2.
#'
#' The function produces a visually appealing diverging stacked bar chart,
#' allowing for easy interpretation of the distribution of responses to a
#' specific Likert-scale question. The function supports customization of
#' labels, colors, and weights, providing flexibility in data representation.
#'
#' @inheritParams multi_summary
#' @param labels Optional vector specifying labels for each response category. If not provided,
#' it extracts labels from the original dataset.
#' @param colors Optional vector specifying colors for each response category. Default colors are provided
#' for 3 and 5 categories. If not specified, the function expects a vector of color codes.
#'
#' @return A ggplot2 object representing a diverging stacked bar chart displaying the distribution of
#' Likert-scale responses. The chart is customized based on the provided or extracted labels and colors.
#' @export
#'
#' @family matrix questions
#'
matrix_likert <- function(dataset,
                         question,
                         labels = NULL,
                         colors = NULL,
                         weights = NULL,
                         na.rm = TRUE)
                         {



  #try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  group_by <- NULL
  subgroups_to_exclude <-  NULL
  doublemiddle_label <- Item <- value <- level <- . <- freq <- response <- NULL #created useing NSE, necessary to avoid visible binding note
  data.table <- multi_summary(dataset = dataset,
                                    question =  all_of(question),
                                    weights =   if(!is.null(weights)){weights},
                                    na.rm = na.rm)



  ### Preprocessing ###
  #Default is yes or else it would be an additional category
  # if(na.rm == TRUE){
  #   data.table <- data.table %>%
  #     filter(!is.na(response))
  # }

  #Number of categories present in the data
  no_categories <- length(unique(data.table$response))

  #if there is an even number of categories passed
  if((no_categories %% 2) == 0) {
    stop('Only an odd number of categories accepted. Try `matrixgraph_freq` instead')
  }

  #Default colors for 3,5 categories
  if(is.null(colors)){

    if(no_categories == 3){
      colors <-  c("#E36A64","#FEEBD7", "#8ECF8C")
    } else if(no_categories == 5){
      colors <- c("#d73027","#E36A64","#FEEBD7", "#8ECF8C", "#66bd63")
    } else {
      stop('Please specify a vector of colors')
    }
  }

  # if no labels are passed, create labels from original data
  if(is.null(labels)){
    #what class of data was originally passed (data.table. only returns character b/c count function)
    data.question <- tidyselect::eval_select(
        expr = rlang::enquo(question),
        data = dataset)

    original_class <- dataset %>%
      dplyr::select(all_of(data.question)) %>%
      purrr::map(class) %>%
      unique() %>%
      unlist()

   if(original_class == "numeric"){

     labels <- data.table %>%
       dplyr::pull(response) %>%
       unique() %>%
       as.numeric() %>%
       sort()

   } else if(original_class == "factor"){

     labels <- dataset %>%
       dplyr::select(all_of(data.question)) %>%
       purrr::map(levels) %>%
       unique() %>%
       unlist()

   } else if(original_class == 'character') {
      stop('Must specify labels argument if data is class "character"')
    }
  #labels argument is provided
  } else {
    #Check to make sure number of labels passed matches number of categories
    if(no_categories != length(labels)){
      stop('The number of labels provided does not mach the number of categories')
    }
  }


  ## Transforom data ##
  #summerize each category by frequency
  data.table <- data.table %>%
    dplyr::select(-n) %>%
    tidyr::pivot_wider(names_from=c(response),
                       values_from=c(freq),
                       names_prefix = 'l_')


  ## Build Graph ##

  numlabels <- length(labels)
  colnames(data.table) <- c('Item', labels)

  #Split the middle column in half in the graph
  #dentify the center column, incluidng the first column
  numcenter<-ceiling(NCOL(data.table)/2)+1

  #Replace middle column with values split in half and name columns
  namecenter <- colnames(data.table[numcenter])

  data.table <- data.table %>%
    dplyr::mutate(midhigh = .data[[namecenter]]/ 2, .after = all_of(namecenter)) %>%
    dplyr::mutate(midlow = .data[[namecenter]]/ 2, .after = all_of(namecenter)) %>%
    dplyr::select(-all_of(namecenter))


  ##computer lower and upper bound of x axis on graph
  midlow <- match('midlow', colnames(data.table))
  lower_bound <- ceiling(max(rowSums(data.table[,2:midlow]))) *-100
  upper_bound <- ceiling(max(rowSums(data.table[,midlow:NCOL(data.table)])))*100


  #Prep data for graphing format
  data.table <- data.table %>%
    tidyr::pivot_longer(2:NCOL(.), names_to = 'level')

  #multiply 'negitive' leveles by -1
  negitive_levels <- c(labels[1:ceiling(numlabels/2)], "midlow")
  positive_levels <- c(labels[numcenter:length(labels)], "midhigh")

  data.table$value <- ifelse(data.table$level %in% negitive_levels,
                       data.table$value*-100, data.table$value*100 )


  ##Create fill column for the graph (must double middle color)
  labelcenter <- labels[numcenter-1]   #subtract one since color palette dosn't include extra label column
  doublemiddle_labels <- labels %>% dplyr::as_tibble() %>%
    #insert before since numcenter includes quesetion column
    dplyr::add_row(value = labelcenter, .before = numcenter) %>%
    dplyr::pull(1)
  #add colum to dataframe
  data.table$doublemiddle_label <- rep(doublemiddle_labels,
                                 NROW(data.table)/length(doublemiddle_labels))


  #set order for x axis
  row_order <- data.table %>%
    dplyr::filter(level ==  labels[length(labels)]) %>%
    dplyr::arrange(-value) %>%
    dplyr::pull(1) %>%
    as.character %>%
    rev

  data.low <- data.table %>% dplyr::filter(level %in% negitive_levels)
  data.high <- data.table %>% dplyr::filter(level %in% positive_levels)

  graph.likert <- ggplot2::ggplot() +
    ggplot2::geom_bar(data=data.low, aes(x = factor(Item, levels = row_order), y=value, fill = factor(doublemiddle_label, levels = labels))
                      ,stat="identity", position = ggplot2::position_stack(reverse = FALSE)) +
    ggplot2::geom_bar(data=data.high , aes(x = factor(Item, levels = row_order), y=value, fill = factor(doublemiddle_label, levels = labels))
                      ,stat="identity", position = ggplot2::position_stack(reverse = TRUE)) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 2, color =c("white")) +
    #scale_fill_identity("",  labels = labels, breaks = colors, guide = "legend") +
    ggplot2::scale_fill_manual(values = colors, labels = labels, breaks = labels) +
    ggplot2::scale_y_continuous(breaks=seq(lower_bound ,upper_bound,25),
                                limits=c(lower_bound,upper_bound),
                                labels = abs(seq(lower_bound, upper_bound, 25))) +
    ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 40)) +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "",
                  subtitle = "",
                  x = "",
                  y = "",
                  fill = "")

  return(graph.likert)

}




















