#' cluster_exploration UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_cluster_exploration_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinybusy::add_busy_spinner(
      spin = "self-building-square",
      position = 'top-left',
      margins = c(70, 1100)
    ),
    
    shiny::h1("Analyse the genes of a specific cluster"),
    shiny::hr(),
    shiny::uiOutput(ns("cluster_to_explore_choice")),
    shiny::hr(),
    
    #   ____________________________________________________________________________
    #   Profiles column                                                         ####
    
    col_6(
      boxPlus(
        width = 12,
        title = "Expression profiles",
        shiny::plotOutput(ns("profiles_to_explore"), height = "700px")
      )
    ),
    
    
    #   ____________________________________________________________________________
    #   Clusters characteristics                                                ####
    
    
    col_6(
      shinydashboard::tabBox(
        title = "Genes in that clusters",
        width = 12,
        shiny::tabPanel(
          title = "Genes table",
          DT::dataTableOutput(ns("genes_to_explore")),
          shiny::hr(),
          shiny::fluidRow(valueBoxOutput(ns(
            "gene_number_cluster"
          )))
        ),
        shiny::tabPanel(title = "Ontologies enrichment"),
        shiny::tabPanel(title = "GLM for factors effect")
      )
    )
    
  )
}

# TODO : faire choisir le clustering préfait (comparaison) plutot que le dernier deja fait

#' cluster_exploration Server Function
#'
#' @noRd
mod_cluster_exploration_server <-
  function(input, output, session, r) {
    ns <- session$ns
    
    
    #   ____________________________________________________________________________
    #   Reactive memberships and conds                                          ####
    
    
    membership <- shiny::reactive({
      req(r$clusterings[[r$current_comparison]])
      r$clusterings[[r$current_comparison]]$membership
    })
    
    
    conditions <- shiny::reactive({
      req(r$clusterings[[r$current_comparison]])
      r$clusterings[[r$current_comparison]]$conditions
    })
    
    
    
    #   ____________________________________________________________________________
    #   cluster to explore choice                                               ####
    
    
    output$cluster_to_explore_choice <- shiny::renderUI({
      shiny::req(membership())
      shinyWidgets::radioGroupButtons(
        inputId = ns("cluster_to_explore"),
        label = "Cluster to explore",
        choices = unique(membership()),
        justified = TRUE,
        checkIcon = list(yes = shiny::icon("ok",
                                           lib = "glyphicon"))
      )
    })
    
    
    #   ____________________________________________________________________________
    #   profiles                                                                ####
    
    
    output$profiles_to_explore <- shiny::renderPlot({
      draw_profiles(
        data = r$normalized_counts,
        membership = membership(),
        k = input$cluster_to_explore,
        conds = conditions()
      )
    })
    
    
    #   ____________________________________________________________________________
    #   table                                                                   ####
    
    
    output$genes_to_explore <- DT::renderDataTable({
      req(r$top_tags, r$current_comparison, membership())
      
      table <- r$top_tags[[r$current_comparison]]
      table[table$genes %in% get_genes_in_cluster(membership = membership(),
                                                  cluster = input$cluster_to_explore),
            c("logFC", "logCPM", "FDR")]
    })
    
    
    output$gene_number_cluster <- renderValueBox({
      valueBox(
        value = length(
          get_genes_in_cluster(
            membership = membership(),
            cluster = input$cluster_to_explore
          )
        ),
        subtitle = "genes in this cluster",
        color = "olive"
      )
    })
    
    
    
    
  }

## To be copied in the UI
# mod_cluster_exploration_ui("cluster_exploration_ui_1")

## To be copied in the server
# callModule(mod_cluster_exploration_server, "cluster_exploration_ui_1")