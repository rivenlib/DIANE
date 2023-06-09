#' network_inference UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_network_inference_ui <- function(id){
  ns <- NS(id)
  tagList(
    #shinyalert::useShinyalert(),
    
    shinybusy::add_busy_spinner(
      spin = "self-building-square",
      position = 'top-left',
      margins = c(70, 1200)
    ),
    
    
    shiny::h1("Network inference"),
    shiny::hr(),
    
    shiny::fluidRow(
      
      
#   ____________________________________________________________________________
#   inference settings                                                      ####

    shinydashboardPlus::box(
        title = "Inference Settings",
        solidHeader = FALSE,
        status = "success",
        collapsible = TRUE,
        closable = FALSE,
        width = 4,
        
        col_10(shiny::h4("GENIE3 Gene regulatory network inference")),
        
        col_2(shinyWidgets::dropdownButton(
          size = 'xs',
          shiny::includeMarkdown(system.file("extdata", "genie3.md", package = "DIANE")),
          circle = TRUE,
          status = "success",
          icon = shiny::icon("question"),
          width = "600px",
          tooltip = shinyWidgets::tooltipOptions(title = "More details")
        )),
        
        
        shiny::br(),
        
        shiny::fluidRow(col_12(shiny::uiOutput(ns("input_genes_net")))),
        
        shiny::hr(),
        
#   ____________________________________________________________________________
#   regulators input                                                        ####

        shiny::uiOutput(ns("reuglators_organism_summary")),
        
        shiny::h5("Or choose your own :"),
        col_2(shinyWidgets::dropdownButton(
          size = 'xs',
          shiny::includeMarkdown(system.file("extdata", "regulatorsFile.md", package = "DIANE")),
          circle = TRUE,
          status = "success",
          icon = shiny::icon("question"),
          width = "600px",
          tooltip = shinyWidgets::tooltipOptions(title = "More details")
        )),
       
        shiny::fileInput(
          ns('TFs_list_input'),
          'Upload custom CSV/TXT regulators list',
          accept = c(
            'text/csv',
            'text/comma-separated-values,text/plain',
            '.csv',
            '.txt'
          )
        ),
      
        
        shiny::fluidRow(col_4(shiny::uiOutput(ns("input_summary"))),
        col_8(shiny::uiOutput(ns("regulators_intersect_summary")))),

        shiny::hr(),
        


#   ____________________________________________________________________________
#   tf grouping                                                             ####


      shinyWidgets::dropdownButton(
        size = 'xs',
        shiny::includeMarkdown(system.file("extdata", "tf_grouping.md", package = "DIANE")),
        circle = TRUE,
        status = "success",
        icon = shiny::icon("question"),
        width = "600px",
        tooltip = shinyWidgets::tooltipOptions(title = "More details")
      ),

shiny::fluidRow(
      col_8(shiny::numericInput(ns("cor_thr"), 
                    label = "Recommended : group regulators correlated over ( %)", 
                    min = 70, max = 100, value = 90)),
      
      col_4(
        shinyWidgets::switchInput(
          inputId = ns("grouping"),
          value = TRUE,
          onLabel = "ON",
          offLabel = "OFF",
          inline = TRUE,
          onStatus = "success"
        )
      )
      ),

shiny::hr(),

#   ____________________________________________________________________________
#   genie3 launch                                                           ####

        shiny::uiOutput(ns("n_cores_choice")),
       
        shiny::numericInput(ns("n_trees"), 
                            label = "Number of trees for 
                            GENIE3 Random Forests :", 
                            min = 200, value = 1000),
        
        shiny::fluidRow(
          col_6(shinyWidgets::switchInput(ns("importance_metric"),
                                          label = "Importance metric in random forests",
                                          onLabel = "MSE increase on OOB",
                                          offLabel = "Node impurity", value = FALSE, 
                                          size = "normal", onStatus = "success", 
                                          offStatus = "primary", width = "100%")),
          col_6(shinyWidgets::actionBttn(
            ns("launch_genie_btn"),
            label = "Launch Network Inference",
            style = "material-flat",
            color = "success"
          ))),
        
        
        shiny::hr()
        #shiny::uiOutput(ns("GENIE3_summary"))
        
    ),


#   ____________________________________________________________________________
#   thresholding options                                                    ####

   shinydashboardPlus::box(
      title = "Thresholding settings",
      solidHeader = FALSE,
      status = "success",
      collapsible = TRUE,
      closable = FALSE,
      width = 8,
      
      shiny::fluidRow(
                      col_2(shiny::uiOutput(ns("inference_summary"))),
                      col_2(shinyWidgets::dropdownButton(
                        size = 'xs',
                        shiny::includeMarkdown(system.file("extdata", "threshold.md", package = "DIANE")),
                        circle = TRUE,
                        status = "success",
                        icon = shiny::icon("question"),
                        width = "600px",
                        tooltip = shinyWidgets::tooltipOptions(title = "More details")
                      )),
                      col_8(shiny::h5("Without thresholding, we would obtain a fully 
                      connected weighted graph from GENIE3, with far too many links to be 
                      interpretable. In order build a meaningfull network, this weighted 
                      adjacency matrix betwen regulators and targets has to be sparsified, 
                                      and we have to determine the N higher regulatory weights that 
                                      we consider significant.")),
      ),
      
      
      
      shiny::hr(),
      
      shiny::h5("As biological networks are known for their pronounced sparsity, 
                considering all possible regulator-target pairs would be of very little interest. 
                Studies found that the typical values of density (ratio between the number of edges, 
                and the number of edges of the complete graph) in state of the art biological networks 
                lie approximately between 0.1 and 0.001. We therefore propose to create a first graph, 
                topologically consistent with biological network standards, which will be further refined 
                by statistical testing. During the testing phase, the null ditributions of regulatory weights 
                are estimated by the permutations, thus providing an empricial p-value 
                for the observed importance."),
      
      shiny::hr(),
      
      
      
      shiny::fluidRow(col_8(shiny::sliderInput(ns("density"), max = 0.1,round = -3, step = 0.001,
                                                min = 0, label = "Network's conectivity density" , value = 0.02)
                             ),
                      col_2(shiny::uiOutput(ns("n_edges_choice")))),
      
      shiny::fluidRow(col_4(shinyWidgets::switchInput(ns("test_edges"),
                                label = "Edges statistical testing",
                                onLabel = "ON (more computation)",
                                offLabel = "OFF (density-based hard thresholding)", value = FALSE, 
                                size = "normal", onStatus = "success", 
                                offStatus = "primary", width = "100%")),
                      col_4(shiny::uiOutput(ns("btn_thr_label"))),
                      col_4(shiny::uiOutput(ns("estimation_summary")))),

       
      
      shiny::hr(),
      
      shiny::uiOutput(ns("thr_summary")),
      shiny::uiOutput(ns("dl_bttns")),
      
      visNetwork::visNetworkOutput(ns("net_preview"), height = "650px")
      
    )
  )
)
}
    
#' network_inference Server Function
#'
#' @noRd 
mod_network_inference_server <- function(input, output, session, r){
  ns <- session$ns
  
  coseq_membership <- shiny::reactive({
    shiny::req(r$clusterings, r$current_comparison, input$input_deg_genes_net)
    shiny::req(input$input_deg_genes_net == r$current_comparison)
    req(r$clusterings[[r$current_comparison]])
    r$clusterings[[r$current_comparison]]$membership
  })
  
  
  
#   ____________________________________________________________________________
#   deg input select                                                        ####

  output$input_genes_net <- shiny::renderUI({
    shiny::req(r$DEGs)
    
    if(length(r$DEGs) > 0){
      tagList(
          shinyWidgets::pickerInput(
            inputId = ns('input_deg_genes_net'),
            label = "Input genes for network inference:",
            choices = names(r$DEGs),
            choicesOpt = list(subtext = paste(lengths(r$DEGs), "genes"))
          ),
          col_6(shiny::uiOutput(ns("input_conditions_choice_net"))),
          col_6(shiny::uiOutput(ns("input_cluster_genes")))
          
          
      )
    }
    else{
      shinydashboardPlus::descriptionBlock(
        number = "Please perform one or more differential 
        expression analysis before network inference",
        numberColor = "orange",
        rightBorder = FALSE
      )
    }
    
  })
  
  output$input_cluster_genes <- shiny::renderUI({
    shinyWidgets::checkboxGroupButtons(
        inputId = ns('input_cluster_genes_net'),
        label = "Use only specific clusters (from previous clustering tab) :",
        choices = unique(coseq_membership()), direction = "vertical",
        justified = TRUE,
        selected = unique(coseq_membership()),
        checkIcon = list(yes = shiny::icon("ok",
                                           lib = "glyphicon"))
      )
  })
  
  
  #   ____________________________________________________________________________
  #   input genes reactive                                                    ####
  
  
  input_net <- shiny::reactive({
    shiny::req(input$input_deg_genes_net)
    if(is.null(r$current_comparison))
      r$DEGs[[input$input_deg_genes_net]]
    else{
      if(input$input_deg_genes_net != r$current_comparison)
        r$DEGs[[input$input_deg_genes_net]]
      else
        names(coseq_membership()[coseq_membership() %in% input$input_cluster_genes_net])
    }
  })
#   ____________________________________________________________________________
#   conditions selection                                                    ####

  
  output$input_conditions_choice_net <- shiny::renderUI({
    shiny::req(r$conditions)
    
    shinyWidgets::checkboxGroupButtons(
      inputId = ns('input_conditions_net'),
      label = "Conditions used to infer network edges :",
      choices = unique(r$conditions),
      justified = TRUE, direction =  "vertical",
      checkIcon = list(yes = shiny::icon("ok",
                                         lib = "glyphicon")),
      selected = unique(r$conditions)
    )
  })
  
  
#   ____________________________________________________________________________
#   regulators setting                                                      ####
  
  regulators <- shiny::reactive({
    shiny::req(r$raw_counts, r$organism)
    d <- NULL
    if (r$organism != "Other") {
      data("regulators_per_organism", package = "DIANE")
      d <- regulators_per_organism[[r$organism]]
    }
    
    if(!is.null(input$TFs_list_input)){
      path = input$TFs_list_input$datapath
      
      d <-
        read.csv(
          path,
          header = FALSE,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      d <- as.vector(d[,1])
    }

    if(r$splicing_aware){
      r$aggregated_normalized_counts <- 
        aggregate_splice_variants(data.frame(r$normalized_counts, 
                                             check.names = FALSE))
    }
      else {
        if(!is.null(d)){
          
        if (sum(d %in% row.names(r$raw_counts)) == 0){
        
        shinyalert::shinyalert(
          "Something is wrong with the chosen regulators",
          "No regulators were found in the rownames of the expression data",
          type = "error"
        )
        d = NULL
      }
      }
    }
    as.character(d)
    })
  
  #   ____________________________________________________________________________
  #   summaries                                                               ####
  
  
  output$input_summary <- shiny::renderUI({
    shiny::req(input$input_deg_genes_net, r$DEGs, input_net())
    if (is.null(input_net())) {
      numberColor = "orange"
      number = "Please input genes"
      header = ""
      numberIcon = shiny::icon('times')
    }
    else{
      numberColor = "olive"
      number = length(input_net())
      numberIcon = shiny::icon('check')
      header = "input genes"
    }
    shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      text = header,
      rightBorder = TRUE
    )
  })
  
  
  output$reuglators_organism_summary <- shiny::renderUI({

    r$regulators <- regulators()
    
    if(is.null(r$regulators)){
      numberColor = "orange"
      number = "Please provide a regulators list"
      numberIcon = shiny::icon('check')
      header = ""
    }
    else{
      if (r$organism != "Other"){
        numberColor = "teal"
        number = length(r$regulators)
        numberIcon = shiny::icon('check')
        header = paste("regulators provided for", r$organism)
      }
      else{
        numberColor = "teal"
        number = length(r$regulators)
        numberIcon = shiny::icon('check')
        header = "Custom regulators provided"
      }
      
    }
    tagList(shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      text = header,
      rightBorder = FALSE
    ))
    
  })
  
  output$regulators_intersect_summary <- shiny::renderUI({
    shiny::req(input$input_deg_genes_net, r$regulators, r$DEGs,
               r$networks, input_net())
    shiny::req(r$regulators)
    
    if(r$splicing_aware) 
      genes <- get_locus(r$DEGs[[input$input_deg_genes_net]])
    else
      genes <- input_net()
      
    tfs <- intersect(genes, r$regulators)

    shinydashboardPlus::descriptionBlock(
      number = length(tfs),
      numberColor = "blue",
      text = "Regulators among the input genes",
      rightBorder = FALSE
    )
  })
  
  output$inference_summary <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net, input_net())
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(input$input_deg_genes_net, r$regulators, r$DEGs)

    if (is.null(r$networks[[input$input_deg_genes_net]]$mat)) {
      numberColor = "orange"
      number = "Inference not performed yet"
      header = ""
      numberIcon = shiny::icon('times')
    }
    else{
      numberColor = "olive"
      number = "Inference successfully completed"
      numberIcon = shiny::icon('check')
      header = "You can now proceed to thresholding"
    }
    shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      text = header,
      rightBorder = TRUE
    )
  })
  
  output$thr_summary <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net, input_net())
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$graph)
    shiny::req(r$networks[[input$input_deg_genes_net]]$nodes)
    shiny::req(r$networks[[input$input_deg_genes_net]]$edges)
    
    numberColor = "olive"
    number = "Your network is ready"
    numberIcon = shiny::icon('check')
    header = "You can explore it in the next tab"
    
    shinydashboardPlus::descriptionBlock(
      number = number,
      numberColor = numberColor,
      text = header,
      rightBorder = TRUE
    )
  })
  
  
  
#   ____________________________________________________________________________
#   cores choice                                                            ####

  output$n_cores_choice <- shiny::renderUI({
    
    # assigns either one core if detection fails,
    # either the total number of cores minus one as max
    
    cpus <- parallel::detectCores()
    if(is.na(cpus)){cpus <- 1}
    
    # for server version, one quarter of total cpus are allocated
    
    if(golem::get_golem_options("server_version")){
      cpus <- max(1,cpus/4)
    }

    shinyWidgets::sliderTextInput(
      inputId = ns("n_cores"),
      label = "Number of cores for 
                            multithreaded inference :",
      choices = seq(1, cpus),
      grid = TRUE,
      selected = max(1,cpus-1))
    
  })
  
  
  time_estimation <- shiny::reactiveValues(
    estimation = NULL
  )
  
  shiny::observeEvent(input$n_cores, {
    time_estimation$estimation <- NULL
  })

  
#   ____________________________________________________________________________
#   button threshold                                                        ####

  
  output$btn_thr_label <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net)
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$mat)

    if(input$test_edges){
      if(is.null(time_estimation$estimation))
        label = "Estimate running time"
      else
        label = "Threshold and test network"
    }
      
    else
      label = "Threshold network"
    col_4(shinyWidgets::actionBttn(
      ns("thr_btn"),
      label = label, 
      style = "material-flat",
      color = "success"
    ))
  })
  
  
  #   ____________________________________________________________________________
  #   estimation display                                                      ####
  
  
  output$estimation_summary <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net, input_net())
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$mat)
    shiny::req(time_estimation$estimation)
    
    shinydashboardPlus::descriptionBlock(
      number = "Estimated time for edges statistical testing :",
      numberColor = "orange",
      rightBorder = FALSE,
      header = paste("Aproximatively", round(time_estimation$estimation/60, 0), "minutes")
    )
    
  })
  
#   ____________________________________________________________________________
#   thresholding settings                                                   ####
  
  
  output$n_edges_choice <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net)
    shiny::req(r$DEGs[[input$input_deg_genes_net]], input_net())
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$mat)
    #proposition = 1.5*length(r$DEGs[[input$input_deg_genes_net]])
    mat <- r$networks[[input$input_deg_genes_net]]$mat
    proposition = get_nEdges(density = input$density, 
                             nGenes = dim(mat)[2],
                             nRegulators = dim(mat)[1])
    
    time_estimation$estimation <- NULL
    
    shiny::numericInput(ns("n_edges"), 
                        label = "Number of edges :", 
                        min = 1, value = proposition)
    
  })
  
  
  

#   ____________________________________________________________________________
#   bttn reactives                                                          ####

  
  shiny::observeEvent((input$launch_genie_btn), {
    shiny::req(r$normalized_counts, input$input_deg_genes_net, 
               r$regulators, r$DEGs, input_net(),input$input_conditions_net)
    
    if(r$splicing_aware) {
      all_genes <- get_locus(r$DEGs[[input$input_deg_genes_net]])
      targets <- get_locus(input_net())
      data <- r$aggregated_normalized_counts
    }
    else {
      all_genes <- r$DEGs[[input$input_deg_genes_net]]
      targets <- input_net()
      data <- r$normalized_counts
    }
    
    # only desired conditions
    conditions <- colnames(data)[
      stringr::str_split_fixed(colnames(data), '_',2)[,1] %in% 
        input$input_conditions_net]
    
    data <- data[,conditions]
    
    # even if only clusters were chosen, we take regulators 
    #from all deg list
    regressors = intersect(all_genes, r$regulators)
    
    if(input$grouping){
      
      results <- group_regressors(data, genes = targets, regressors = regressors,
                                  corr_thr = input$cor_thr/100.0)
      
      
      r$grouped_normalized_counts = results$counts
      r$grouped_genes = results$grouped_genes
      r$grouped_regressors = results$grouped_regressors
      r$cor_network <- results$correlated_regressors_graph
      
      
      data <- r$grouped_normalized_counts
      targets <- r$grouped_genes
      regressors <- r$grouped_regressors
    }

    
    if(length(regressors) < 2 ){
      shinyalert::shinyalert(
        "Not enough regulators provided",
        "GENIE3 requires a minimum of 2 regulators among the input genes to run.
        You coud maybe proceed to a less stringeant differential expression
        analysis to increase the number of input genes. Maybe something
        also went wrong in the grouping if eneabled.",
        type = "error"
      )
    }
    
    shiny::req(length(regressors) >= 2)
    
    if(input$importance_metric)
      importance = "MSEincrease_oob"
    else
      importance = "node_purity"
    

    set.seed(r$seed)
    mat <- network_inference(normalized.count = data, targets = targets, 
                             conds = input$input_conditions_net,
                      regressors = regressors,
                      nTrees = input$n_trees,
                      nCores = input$n_cores, 
                      importance_metric = importance)
    
    time_estimation$estimation <- NULL
    
    if(sum(is.na(mat)) > 0){
      shinyalert::shinyalert(
        paste("NA importance values were produced :", sum(is.na(mat)), 
              "Nan over", length(c(mat))),
        "It may be caused by too few samples. You can run the
      network inference again with the node purity importance metric
      instead of OOB MSE increase, to avoid this issue.",
        type = "warning"
      )
    }
    
    r$networks[[input$input_deg_genes_net]]$mat <- mat
    
    # resets old network if one was already created
    r$networks[[input$input_deg_genes_net]]$graph <- NULL
    if(golem::get_golem_options("server_version"))
      loggit::loggit(custom_log_lvl = TRUE,
                   log_lvl = r$session_id,
                   log_msg = "network inference")
    
  })

  
  #   ____________________________________________________________________________
  #   bttn reactive thr                                                       ####
  
  

  
  #shiny::observeEvent((input$thr_btn), {
  shiny::observeEvent((input$thr_btn), {
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs, input$input_conditions_net)
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$mat)
    
    
    if (!input$test_edges){
      r$networks[[input$input_deg_genes_net]]$graph <- network_thresholding(
        r$networks[[input$input_deg_genes_net]]$mat, n_edges = input$n_edges)
      
      data <- network_data(r$networks[[input$input_deg_genes_net]]$graph, 
                           r$regulators, r$gene_info)
      
      membership <- data$nodes$community
      names(membership) <- data$nodes$id
      
      r$networks[[input$input_deg_genes_net]]$membership <- membership
      
      r$networks[[input$input_deg_genes_net]]$nodes <- data$nodes
      r$networks[[input$input_deg_genes_net]]$edges <- data$edges
      
      r$networks[[input$input_deg_genes_net]]$conditions <- 
        input$input_conditions_net
      
      r$current_network <- input$input_deg_genes_net
    }
    else{
      
      ######## time estimation 
      
      if (is.null(time_estimation$estimation)){
        if(input$grouping)
          data = r$grouped_normalized_counts
        else
          data = r$normalized_counts
        
        # only desired conditions
        conditions <- colnames(data)[
          stringr::str_split_fixed(colnames(data), '_',2)[,1] %in% 
            input$input_conditions_net]
        
        data <- data[,conditions]

        mat <- r$networks[[input$input_deg_genes_net]]$mat
        
        time_estimation$estimation <- estimate_test_edges_time(mat,
                                   normalized_counts = data, density = input$density,
                                   nGenes = dim(mat)[2],
                                   nRegulators = dim(mat)[1], 
                                   nTrees = input$n_trees, 
                                   verbose = TRUE,
                                   nCores = input$n_cores)
        
      }
      
      ######## Actual testing
      
      else{
        if (input$grouping)
          data = r$grouped_normalized_counts
        else
          data = r$normalized_counts
        
        # only desired conditions
        conditions <- colnames(data)[
          stringr::str_split_fixed(colnames(data), '_',2)[,1] %in% 
            input$input_conditions_net]
        
        data <- data[,conditions]
        
        mat <- r$networks[[input$input_deg_genes_net]]$mat
        
        future::plan(future::multisession)
        
        # blocking function! ew!
        
        # r$edge_tests <- test_edges(mat,
        #                            normalized_counts = data, density = input$density,
        #                            nGenes = dim(mat)[2],
        #                            nRegulators = dim(mat)[1], 
        #                            nTrees = input$n_trees, 
        #                            verbose = TRUE,
        #                            nCores = input$n_cores)
        
        nTrees = input$n_trees
        nCores = input$n_cores
        density = input$density
        
        # async version :)
        set.seed(r$seed)
        tictoc::tic()
        promise <- future::future({test_edges(
                   mat,
                   normalized_counts = data, 
                   density = density,
                   nGenes = dim(mat)[2],
                   nRegulators = dim(mat)[1], 
                   nTrees = nTrees, 
                   verbose = TRUE,
                   nCores = nCores)}, seed = r$seed)
        
        
        
        promises::then(promise, function(value) {
                     
            r$edge_tests <- value
            time <- tictoc::toc(quiet = TRUE)
            elapsed <- time$toc - time$tic
            
            if(golem::get_golem_options("server_version"))
              loggit::loggit(custom_log_lvl = TRUE,
                           log_lvl = r$session_id,
                           log_msg = "edges testing")
            
            
            shiny::showModal(shiny::modalDialog(
              title = "Edge testing procedure complete",
              size = 'l',
              shiny::h5(paste("Running time :", round(elapsed/60, 0), "minutes")),
              shiny::h5("Now every edge of the pre-buit network is
                  associated to an adjusted pvalue. The only remaining 
                  choice is the fdr threshold to apply to keep significant 
                  edges. Usual values are 0.01, 0.05, or 0.1, and can be interpreted
                  as the proportion of wrond edges tolerated in the final network.
                  The curves above can give you some insights about 
                  the pvalues distributions and the number of edges
                  the network will have depending on the chosen fdr threshold."),
              
              shiny::plotOutput(ns("fdr_choice"), height = "600px"),
              
              shiny::hr(),
              
              shiny::numericInput(ns("fdr"), value = 0.05, min = 0, max = 1,
                                  label = "FDR threshold :"),
              
              footer = list(
                shiny::actionButton(ns("fdr_chosen"), "OK"))
              
            ))
          })

      }
      
      
      
    }
    
    
  })
  
  
#   ____________________________________________________________________________
#   event reactive close modal                                              ####

  
  shiny::observeEvent(input$fdr_chosen, {
    shiny::removeModal()
    
    r$networks[[input$input_deg_genes_net]]$graph <- 
      network_from_tests(r$edge_tests$links, fdr = input$fdr)
    
    data <- network_data(r$networks[[input$input_deg_genes_net]]$graph, 
                         r$regulators, r$gene_info)
    
    membership <- data$nodes$community
    names(membership) <- data$nodes$id
    
    r$networks[[input$input_deg_genes_net]]$membership <- membership
    
    r$networks[[input$input_deg_genes_net]]$nodes <- data$nodes
    r$networks[[input$input_deg_genes_net]]$edges <- data$edges
    
    r$networks[[input$input_deg_genes_net]]$conditions <- 
      input$input_conditions_net
    
    r$current_network <- input$input_deg_genes_net
  })
  
#   ____________________________________________________________________________
#   fdr_graphics                                                            ####

    output$fdr_choice <- shiny::renderPlot({
      shiny::req(r$edge_tests)
      
      gridExtra::grid.arrange(r$edge_tests$pvalues_distributions + ggplot2::xlim(0,0.1),
                              r$edge_tests$fdr_nEdges_curve, ncol = 1)
    })
  
  
#   ____________________________________________________________________________
#   preview                                                                 ####

  
  output$net_preview <- visNetwork::renderVisNetwork({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net)
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$graph)
    shiny::req(r$networks[[input$input_deg_genes_net]]$nodes)
    shiny::req(r$networks[[input$input_deg_genes_net]]$edges)
    
    if(!input$test_edges)
      draw_network(nodes = r$networks[[input$input_deg_genes_net]]$nodes,
                   edges = r$networks[[input$input_deg_genes_net]]$edges)
    else{
      shiny::req(r$edge_tests$links)
      draw_discarded_edges(r$edge_tests$links, 
                           list(nodes = r$networks[[input$input_deg_genes_net]]$nodes,
                                edges = r$networks[[input$input_deg_genes_net]]$edges))
    }
  })
  
  #   ____________________________________________________________________________
  #   dl button                                                               ####
  
  
  output$dl_bttns <- shiny::renderUI({
    shiny::req(r$normalized_counts)
    shiny::req(r$DEGs)
    shiny::req(input$input_deg_genes_net)
    shiny::req(r$DEGs[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]])
    shiny::req(r$networks[[input$input_deg_genes_net]]$graph)
    shiny::req(r$networks[[input$input_deg_genes_net]]$nodes)
    shiny::req(r$networks[[input$input_deg_genes_net]]$edges)
    tagList(
      shinyWidgets::downloadBttn(
        ns("report"), "Generate html report",
        style = "material-flat", color = "default")
    
    )
  })
  
  
  
  
  #   ____________________________________________________________________________
  #   report                                                                  ####
   
  output$report <- shiny::downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "network_inference_report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "inference_report.Rmd")
      tempImage <- file.path(tempdir(), "favicon.ico")
      file.copy(system.file("extdata", "inference_report.Rmd", package = "DIANE"),
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
# mod_network_inference_ui("network_inference_ui_1")
    
## To be copied in the server
# callModule(mod_network_inference_server, "network_inference_ui_1")
