#' module_levels UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_module_levels_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    shiny::h1("Explore normalized gene expression"),
    
    shiny::hr(),
    
    #shinyalert::useShinyalert(),
    
    shinybusy::add_busy_spinner(
      spin = "self-building-square",
      position = 'top-left',
      margins = c(70, 1200)
    ),
    
    
    shiny::fluidRow(
      shinydashboard::tabBox(
        title = "Explore normalized data",
        width = 12,
        height = "900px",
        
        shiny::tabPanel(title = "PCA",
                        shiny::uiOutput(ns("pca_ui")),
                        shiny::fluidRow(shiny::column(12,
                        shiny::includeMarkdown(system.file(
                          "extdata", "pca.md", package = "DIANE"))))),
        # shiny::tabPanel(title = "MDS",
        #                 shiny::plotOutput(ns('mds_plot'), height = "800px")),
        shiny::tabPanel(title = "Visualize gene expression levels",
                        shiny::fluidRow(
                        shinydashboardPlus::box(
                          title = "Genes and conditions choice",
                          solidHeader = FALSE,
                          status = "success",
                          collapsible = TRUE,
                          closable = FALSE,
                          width = 12,
                          
                          
                          shiny::uiOutput(ns("gene_choice")),
                          
                          
                          shiny::uiOutput(ns("condition_choice"))
                          
                        ),
                        shinydashboardPlus::box(solidHeader = FALSE,
                                                status = "success",
                                                collapsible = TRUE,
                                                closable = FALSE,
                                                width = 12,
                                                shiny::plotOutput(ns("expression_plot"), height = "700px"))
                        )  
        ))
    )
  )
}

#' module_levels Server Function
#'
#' @noRd 
mod_module_levels_server <- function(input, output, session, r){
  ns <- session$ns
  
  output$pca_ui <- shiny::renderUI({
    if(is.null(r$normalized_counts)) {
      shinydashboardPlus::descriptionBlock(
        number = "Please normalize and filter raw data in previous tab",
        numberColor = "orange",
        rightBorder = FALSE
      )
    }
    else shiny::plotOutput(ns('pca_plot'), height = "800px")
  })
  
  output$condition_choice <- shiny::renderUI({
    shiny::req(r$normalized_counts, r$conditions)
    
    shinyWidgets::checkboxGroupButtons(
      inputId = ns('input_conditions'),
      label = "Conditions to include to the expression levels plot:",
      choices = unique(r$conditions),
      justified = TRUE,
      checkIcon = list(yes = shiny::icon("ok",
                                         lib = "glyphicon")),
      selected = unique(r$conditions)
    )
  })
  
  output$gene_choice <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    
    shiny::textInput(ns("genes"), 
                     label = "Genes to plot, as identified in the Gene 
                     column of expression data. For several genes, they must be comma separated, without space, as in the example:", 
                     width = '100%',
                     value = paste0(sample(rownames(r$normalized_counts), 4), collapse = ','))
  })
  
  #   ____________________________________________________________________________
  #   profiles                                                                ####
  
  output$expression_plot <- shiny::renderPlot({
    
    shiny::req(r$normalized_counts_pre_filter, r$conditions, input$genes)
    
    genes <- unlist(strsplit(input$genes, ','))
    shiny::req(length(genes) > 0)
    shiny::req(length(genes) < 10)
    
    shiny::req(sum(genes %in% rownames(r$normalized_counts_pre_filter)) > 0)
    
  
  draw_expression_levels(as.data.frame(r$normalized_counts_pre_filter),
                           conds = input$input_conditions,
                           genes = genes, gene.name.size = 22)
  })
  
  
  # #   ____________________________________________________________________________
  # #   mds                                                                     ####
  # 
  # 
  # output$mds_plot <- shiny::renderPlot({
  #   shiny::req(r$normalized_counts)
  #   draw_MDS(r$normalized_counts)
  # })
  
  
  #   ____________________________________________________________________________
  #   pca                                                                     ####
  
  output$pca_plot <- shiny::renderPlot({
    shiny::req(r$normalized_counts)
    draw_PCA(r$normalized_counts)
  })
  
 
}
    
## To be copied in the UI
# mod_module_levels_ui("module_levels_ui_1")
    
## To be copied in the server
# callModule(mod_module_levels_server, "module_levels_ui_1")
 
