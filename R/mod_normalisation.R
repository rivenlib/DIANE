# FIXME silent melt in reshape2

# TODO markdown dea, coseq, glm


#' normalisation UI Function
#'
#' @description A shiny Module for data filtering and normalisation.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @importFrom shinyWidgets actionBttn dropdownButton switchInput
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_normalisation_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinybusy::add_busy_spinner(
      spin = "self-building-square",
      position = 'top-left',
      margins = c(70, 1000)
    ),
    
    tags$head(tags$style(HTML('
      .awesome-radio {
        padding-left: 20px !important;
      }'
    ))),
    
    shiny::h1("Data filtering and normalisation"),
    shiny::hr(),
    
    
    #   ____________________________________________________________________________
    #   Normalization settings                                                  ####
    
    shiny::fluidRow(
      shinydashboardPlus::box(
        title = "Settings",
        solidHeader = FALSE,
        status = "success",
        collapsible = TRUE,
        closable = FALSE,
        width = 3,
        
        col_8(shiny::h2("Normalization")),
        
        
        col_4(shinyWidgets::dropdownButton(
          size = 'xs',
          shiny::includeMarkdown(
            system.file("extdata", "normalisation.md", package = "DIANE")
          ),
          circle = TRUE,
          status = "success",
          icon = shiny::icon("question"),
          width = "600px",
          tooltip = shinyWidgets::tooltipOptions(title = "More details")
        )),
        
        
        shiny::fluidRow(col_12(
          shinyWidgets::switchInput(
            inputId = ns("prior_removal"),
            label = "Prior removal of differentially expressed genes:",
            value = FALSE,
            onLabel = "ON",
            offLabel = "OFF",
            inline = TRUE,
            onStatus = "success"
          )
        )),
        
        
        
        
        shiny::uiOutput(ns("norm_choice"))
        ,
        shiny::fluidRow(  
          
            col_8(shinyWidgets::actionBttn(
              ns("normalize_btn"),
              label = "Normalize", 
              style = "material-flat",
              color = "success"
            
          ))
        ),
        
        shiny::hr(),
        shiny::uiOutput(ns("norm_summary")),
        shiny::hr(),
        
        
        #   ____________________________________________________________________________
        #   filtering settings                                                      ####
        
        
        shiny::h2("Low counts filtering"),
        
        shinyWidgets::dropdownButton(
          size = 'xs',
          shiny::includeMarkdown(system.file("extdata", "filtering.md", package = "DIANE")),
          circle = TRUE,
          status = "success",
          icon = shiny::icon("question"),
          width = "600px",
          tooltip = shinyWidgets::tooltipOptions(title = "More details")
        ),
        
        
        shiny::h5("Minimal gene count sum accross conditions : "),
        col_8(shiny::uiOutput(ns(
          "filter_proposition"
        ))),
        col_4(
          shinyWidgets::actionBttn(
            ns("use_SumFilter"),
            label = "Filter", 
            style = "material-flat",
            color = "success"
          )
        ),
        
        
        shiny::hr(),
        
        shiny::hr(),
        shiny::hr(),
        shiny::uiOutput(ns("filtering_summary")),
        shiny::hr(),
        
        shiny::br(),
        
        shiny::uiOutput(ns("dl_bttns"))
      ),
    
    
    #   ____________________________________________________________________________
    #   plot results ui                                                         ####
    
      shinydashboard::tabBox(
        title = "Data exploration",
        width = 9,
        height = "1000px",
        
        shiny::tabPanel(
          title = "Samples distributions",
          col_4(
            shinyWidgets::switchInput(
              inputId = ns("preview_norm_distr"),
              value = TRUE,
              onLabel = "normalized",
              offLabel = "raw",
              onStatus = "success",
              offStatus = "danger"
            )
          ),
          col_4(
            shinyWidgets::switchInput(
              inputId = ns("violin_preview"),
              value = TRUE,
              onLabel = "Boxplots",
              offLabel = "Distributions",
              onStatus = "success"
            )
          ),
          shiny::plotOutput(ns('heatmap_preview_norm'), height = "900px")
        ),
         
        shiny::tabPanel(title = "Summary",
                        shiny::verbatimTextOutput(ns("tcc_summary")))
      )
      
    ),
    shiny::br()
    )
}

#' normalisation Server Function
#' @importFrom TCC getNormalizedData
#' @importFrom utils write.csv
#' @noRd
mod_normalisation_server <- function(input, output, session, r) {
  ns <- session$ns
  
  
  #   ____________________________________________________________________________
  #   norm choice                                                             ####
  
  output$norm_choice <-  shiny::renderUI({
    shiny::req(!is.null(r$use_demo))
    if(!r$use_demo) sel <- 'tmm'
    else sel <- 'none'
    
    col_12(
      shinyWidgets::awesomeRadio(
        inputId = ns("norm_method"),
        label = "Normalisation method:",
        choices = c("tmm", "deseq2", "none"),
        inline = TRUE,
        selected = sel,
        status = "success"
      )
    )
  })
  
  
  output$filter_proposition <- shiny::renderUI({
    shiny::numericInput(
      ns("low_counts_filter"),
      min = 0,
      value = 10 * length(r$conditions),
      label = NULL
    )
  })
  
  
  shiny::observe({
    shiny::req(input$norm_method)
    if(input$norm_method == "none"){
      shinyWidgets::updateSwitchInput(session, ns("prior_removal"),
                        value = FALSE)
      
    }
  })
  
  shiny::observeEvent(input$norm_method,{
  
    r$normalized_counts_pre_filter <- NULL
      
    
  })
  
  #   ____________________________________________________________________________
  #   buttn reactives                                                         ####
  
  shiny::observeEvent(input$normalize_btn, {
    shiny::req(r$raw_counts)
    shiny::req(input$norm_method)
    
    r$norm_method <- input$norm_method
    if(input$norm_method != "none"){
      r$tcc <-
        normalize(
          r$raw_counts,
          r$conditions,
          norm_method = input$norm_method,
          iteration = input$prior_removal
        )
      r$normalized_counts_pre_filter <- TCC::getNormalizedData(r$tcc)
      # the filtering needs to be done again if previously made, so :
      r$normalized_counts <- NULL
    }
    else{
      r$normalized_counts_pre_filter <- r$raw_counts
      r$normalized_counts <- NULL
    }
  })
  
  shiny::observeEvent((input$use_SumFilter), {
    shiny::req(r$normalized_counts_pre_filter)
    if(input$norm_method != "none"){
      r$tcc <- filter_low_counts(r$tcc, thr = input$low_counts_filter)
      r$normalized_counts <- TCC::getNormalizedData(r$tcc)
    }
    else{
      r$normalized_counts <- r$normalized_counts_pre_filter[
        rowSums(r$normalized_counts_pre_filter) > input$low_counts_filter,]
      r$tcc <- list(counts = r$normalized_counts)
    }
    
    if(nrow(r$normalized_counts)==0){
      r$normalized_counts <- NULL
      shinyalert::shinyalert(
        "Low-expression filtering error",
        "The filtering threshold seems too high : no genes remaining. 
        Please set another threshold to continue.",
        type = "error"
      )
    }
      
    
    if(golem::get_golem_options("server_version"))
      loggit::loggit(custom_log_lvl = TRUE,
                   log_lvl = r$session_id,
                   log_msg = "normalisation")
  })
  
  
  #   ____________________________________________________________________________
  #   summaries                                                               ####
  
  output$norm_summary <- shiny::renderUI({
    if (is.null(r$normalized_counts_pre_filter)) {
      numberColor = "orange"
      number = "Normalisation needed"
      header = ""
      numberIcon = shiny::icon('times')
    }
    else{
      numberColor = "olive"
      number = "Done"
      numberIcon =icon('check')
      header =  paste(dim(r$normalized_counts_pre_filter)[1],
                      " genes before filtering")
    }
    shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      numberIcon = numberIcon,
      header = header,
      rightBorder = FALSE
    )
  })
  
  output$tcc_summary <- shiny::renderPrint({
    if(input$norm_method != 'none') print(r$tcc)
    else print("No normalization was performed, all normalization factors equal 1.")
  })
  
 # toDownload <- shiny::reactiveVal()
  
  
  output$filtering_summary <- shiny::renderUI({
    if (is.null(r$normalized_counts_pre_filter)) {
      numberColor = "red"
      number = "Normalisation needed"
      header = ""
      numberIcon = shiny::icon('times')
    }
    else{
      if (is.null(r$normalized_counts)) {
        numberColor = "orange"
        number = "Filtering needed"
        header = ""
        numberIcon = shiny::icon('times')
      }
      else{
        numberColor = "olive"
        number = "Done"
        numberIcon =icon('check')
        header = paste(dim(r$normalized_counts)[1],
                       " genes after filtering")
        #toDownload <<- round(r$normalized_counts, 2)
      }
    }
    shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      numberIcon = numberIcon,
      header = header,
      rightBorder = FALSE
    )
  })
  
  
  #   ____________________________________________________________________________
  #   distribution plots                                                      ####
  
  # IDEA also implement PCA, maybe 3D, in data exploration
  output$heatmap_preview_norm <- shiny::renderPlot({
    shiny::req(r$raw_counts)
    
    if (!input$preview_norm_distr |
        is.null(r$normalized_counts_pre_filter)) {
      d <- r$raw_counts
    }
    else{
      if (is.null(r$normalized_counts)) {
        d <- r$normalized_counts_pre_filter
      }
      else{
        d <- r$normalized_counts
      }
    }
    draw_distributions(d, boxplot = input$violin_preview)+ 
      ggplot2::ggtitle("Per-condition expression ditributions")
  })
  
  
  #   ____________________________________________________________________________
  #   download buttons                                                        ####
  
  output$dl_bttns <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    tagList(
    shiny::fluidRow(col_12(
      shinyWidgets::downloadBttn(
        ns("download_normalized_counts_csv"),
        label = "Download normalized counts as .csv",
        style = "material-flat",
        color = "success"
      ),
      
      shiny::hr(),
      
      shinyWidgets::downloadBttn(
        ns("download_normalized_counts_RData"),
        label = "Download normalized counts as .RData",
        style = "material-flat",
        color = "success"
      ),
      shiny::hr(),
      shinyWidgets::downloadBttn(
        ns("report"), "Generate html report",
        style = "material-flat", color = "default")
    ))
    )
    
  })
  
  output$download_normalized_counts_RData <- shiny::downloadHandler(
    filename = function() {
      paste("normalized_counts.RData")
    },
    content = function(file) {
      tosave <- round(r$normalized_counts, 2)
      save(tosave, file = file)
    }
  )
  
  output$download_normalized_counts_csv <- shiny::downloadHandler(
    filename = function() {
      paste("normalized_counts.csv")
    },
    content = function(file) {
      write.csv(round(r$normalized_counts, 2), file = file, quote = FALSE)
    }
  )
  
  
#   ____________________________________________________________________________
#   report                                                                  ####

  output$report <- shiny::downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "normalisation_report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "normalisation_report.Rmd")
      tempImage <- file.path(tempdir(), "favicon.ico")
      file.copy(system.file("extdata", "normalisation_report.Rmd", package = "DIANE"),
                tempReport, overwrite = TRUE)
      file.copy(system.file("extdata", "favicon.ico", package = "DIANE"),
                tempImage, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(r = r, input = input)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
}

## To be copied in the UI
# mod_normalisation_ui("normalisation_ui_1")

## To be copied in the server
# callModule(mod_normalisation_server, "normalisation_ui_1")
