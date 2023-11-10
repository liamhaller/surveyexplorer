



#' Quickly plot likert data (3,5,7,9 levels)
#'
#' @inheritParams multichoice_summary
#' @return example return
#' @export
#'
likert_graph <- function(dataset,
                         question,
                         labels = c('Strongly disagree', 'Disagree','Neutral','Agree','Strongly agree'),
                         colors =  c("#d73027","#E36A64","#FEEBD7", "#8ECF8C", "#66bd63"),
                         weights = NULL){



  #try(group_by <- rlang::ensym(group_by), silent = TRUE) # try function is here since if is null, then it will fail
  try(weights <- rlang::ensym(weights), silent = TRUE) # try function is here since if is null, then it will fail
  group_by <- NULL
  subgroups_to_exclude <-  NULL

  data.table <- multichoice_summary(dataset = dataset,
                                    question =  all_of(question),
                                    group_by =   if(!is.null(group_by)){group_by},
                                    subgroups_to_exclude =  subgroups_to_exclude,
                                    weights =   if(!is.null(weights)){weights})

  data.table <- data.table %>%
    dplyr::select(-n) %>%
    tidyr::pivot_wider(names_from=c(response),
                       values_from=c(freq),
                       names_prefix = 'l_')



  #TODO
  #check if number of colors is same as number of levels

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
  doublemiddle_labels <- labels %>% tibble::as_tibble() %>%
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




















