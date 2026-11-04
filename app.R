library(shiny)
library(foreach)
library(ggplot2)
library(curl)
library(parallel)
library(scales)
library(ggpmisc)

exp_data <- read.csv(curl("https://raw.githubusercontent.com/samclin/lithic_exp_reduction/main/Experimental_reduction_sets_Sam%20C%20Lin.csv"))

exp_data <- exp_data[exp_data$EVENT %in% c(3,4),]  # Use Events 3–4 only because these reduction sets contain a broader range of flake counts. Earlier events generally contain few flakes and hence provide little variation in the number of artefacts added per simulated assemblage formation event.

exp_data$EVENT_ID=paste(exp_data$CORE.ID,"-",exp_data$EVENT, sep="")

exp_data$retouch_n <- 0



n.cores <- 1 #parallel::detectCores() - 1

my.cluster <- parallel::makeCluster(
  n.cores, 
  type = "PSOCK"
)

doParallel::registerDoParallel(cl = my.cluster)




assemblage_simulator <- function (exp_data, iteration=10000, max.n, prob_retouch, select_strength, select_variable, retouch_method, n_retouch) {
  
  
  sim_output <- data.frame("n"=numeric(), "p_retouch"=numeric(), "time"=numeric(), "median_retouch_size"=numeric(), "median_nonretouch_size"=numeric(), "median_retouch_intensity"=numeric())  
  
  assem = exp_data[0,]

  
  for (i in 1:iteration) {
    
    
    to_add <- exp_data[exp_data$EVENT_ID %in% unique(exp_data$EVENT_ID)[sample(1:length(unique(exp_data$EVENT_ID)), 1, replace=TRUE)],]
    to_add$retouched <- 'N'
    assem <- rbind(assem, to_add)
    
    usable_flakes <- assem[assem$DATACLASS!='CORE' ,]
    
    selection_measure <-
      usable_flakes[[select_variable]]
    
    if (select_strength <= 0) {
      select_prob <- rep(1, nrow(usable_flakes))
    } else {
      select_prob <-  selection_measure^select_strength
    }
    
    if (retouch_method == "proportion") {
      n_selected <- round(prob_retouch * (nrow(to_add)) )
    }
    
    if (retouch_method == "number") {
      n_selected <- min(n_retouch, nrow(to_add))
    }
    
    if (n_selected >0) {
    retouched_flakes <- usable_flakes[sample(1:nrow(usable_flakes), n_selected, replace=FALSE, prob = select_prob),]
    
    retouched_flakes$retouched <- 'Y'
    retouched_flakes$retouch_n <- retouched_flakes$retouch_n +1 
    
    assem[rownames(assem) %in% rownames(retouched_flakes),] <- retouched_flakes
    }
    
    n <- nrow(assem)
    
    p_retouch <- nrow(assem[assem$retouched=="Y",]) / n
    
    time <- i
    
    median_selected_retouched <- median(assem[[select_variable]][assem$retouched=="Y"], na.rm=TRUE)
    
    median_selected_nonretouched <- median(assem[[select_variable]][assem$retouched=="N"], na.rm=TRUE)
    
    median_retouch_intensity <- median(assem$retouch_n[assem$retouched=="Y"], na.rm=T)

    sim_output <- rbind(sim_output, data.frame(n=n, p_retouch=p_retouch, time=i, median_retouch_size=median_selected_retouched, median_nonretouch_size=median_selected_nonretouched, median_retouch_intensity=median_retouch_intensity))  
    
    
    if (nrow(assem) >= max.n) {
      break
    }
    
  }
  
  size_intervals <- seq(0, 10000, 250)
  
  for (k in 1:(length(size_intervals)-1)) {
    
    min_size <- size_intervals[k]
    max_size <- size_intervals[k+1]
    
    sim_output$n_interval[sim_output$n > min_size & sim_output$n <= max_size] <- max_size
    
  }
  
  return(sim_output)  
  
}

# Define UI ----
ui <- fluidPage(
  
  titlePanel("A Base Model of Lithic Assemblage Accumulation"),
  h4("Sam Lin, University of Wollongong (samlin@uow.edu.au)"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      h4("Model parameters"), br(),
      
      sliderInput(inputId="select_strength",
                  label = "Selection strength (k):",
                  min=0,
                  max=5,
                  value=0,
                  step=0.1
                   ),
      
      selectInput(inputId="select_variable",
                  label="Artefact selection variable :",
                  choices=list("Weight" = "WEIGHT",
                               "Max. Length" = "MAXLENGTH",
                               "Max. Width" = "MAXWIDTH",
                               "Max. Thickness" = "MAXTHICK"),
                  selected = "WEIGHT"),
      
      selectInput(inputId="retouch_method", label="Retouch allocation method:",
        choices = list("Fixed proportion" = "proportion",
                      "Fixed number" = "number"),
                      selected = "proportion"),
      
      sliderInput (inputId="prob_retouch",
                   label="Proportion of flakes retouched per event:",
                   min=0.1,
                   max=0.9,
                   value=0.2),
      
      numericInput(inputId="n_retouch", label="Number of flakes retouched per event:", value=5, min=1),
      
      numericInput(inputId="max_accumulation", 
                   label="Maximum assemblage size :",
                   value=10000),
      
      numericInput(inputId="n_assemblages", 
                   label="Number of unique assemblages :",
                   value=5),
      
      selectInput(inputId="output_type", 
                  label="Output :",
                  choices = list("Scatter plot" = 1, "Boxplot" = 2,
                                 "Scatter plot log scale" = 3), selected = 1), br(),
      
      h4("Parameter descriptions:"),
      p(span("Selection strength (k):", style="color:blue"), "Controls how strongly larger artefacts are preferentially selected for retouch. At k=0, all artefacts have an equal chance of being selected, irrespective of size. Increasing k progressively increases the probability that larger artefacts will be selected, producing stronger size-biased selection."),
      p(span("Artefact selection variable:", style="color:blue"), "The artefact attribute used to determine selection probabilities. Selection can be based on weight, maximum length, maximum width, or maximum thickness. This allows evaluation of whether the predicted relationship emerges under different assumptions about the size characteristics influencing flake selection."),
      p(span("Retouch allocation method:", style="color:blue"), "Determines how many flakes are selected for retouch during each reduction event. Under 'Fixed proportion', the number selected scales with the number of flakes produced during that event. Under 'Fixed number', a specified number of flakes is selected during each event, irrespective of event size, up to the number of flakes produced in that event."),
      p(span("Proportion of flakes retouched per event:", style="color:blue"), "Used when the 'Fixed proportion' retouch allocation method is selected. Specifies the proportion of flakes chosen for retouch during each simulated reduction event. Selected flakes remain in the assemblage after use and may be selected again during subsequent events."),
      p(span("Number of flakes retouched per event:", style="color:blue"), "Used when the 'Fixed number' retouch allocation method is selected. Specifies the number of flakes chosen for retouch during each simulated reduction event, irrespective of the number of flakes produced."),
      p(span("Maximum assemblage size:", style="color:blue"), "The total number of artefacts accumulated before the simulation stops. This represents the final assemblage size."),
      p(span("Number of unique assemblages:", style="color:blue"), "The number of independent assemblages simulated. Increasing this value produces more replicate simulations but increases computation time."),
      p(span("Output:", style="color:blue"), "Displays the relationship between assemblage size and retouch frequency as either a scatter plot, binned boxplot, or log-transformed scatter plot. The log-transformed option displays a linear regression fitted to log-transformed values.")
    ),
    
    mainPanel(
      p("This model simulates the accumulation of stone artifacts by iteratively running a simple event scenario of flake production and retouch. 
        Each event has two components:"), 
      strong("1. A set of flakes are produced from a core"),
      div("This is done by randomly selecting a complete reduction set from an experimental database (Lin et al. 2015, 2016). 
      Each reduction set consists of a number of artifacts (flakes+debris) removed from a core at varying levels of reduction intensity. These reduction sets exhibit the rightly-skewed size distribution that is typical of lithic reduction products (Lin et al. 2016).
      Note that the database only contain aritacts >= 25 mm in maximum length."),
      strong("2. Select and retouch flakes"),
      div("Following flake production, a subset of artefacts present in the accumulated assemblage is selected for retouch. Selection probabilities depend on the chosen artefact attribute (weight, length, width, or thickness) and the specified selection strength (k). Retouched artefacts remain within the assemblage and may be selected again during subsequent events. The number of flakes selected may be determined either as a fixed proportion of flakes produced during the event or as a fixed number of flakes per event."),
      
      br(),
      
      p("Basically, we can imagine each event to represent a knapper arriving at an assemblage location and proceeding to makes flakes from unrestricted supply of raw material. 
      The knapper then select out some flakes from the overall assemblage (flakes produced during this episode + what has accumulated so far) to retouch and use. These flakes are then returned back to the assemblage after task completion.
      Note that cores are not included in this simulation."),
      
      br(),
      
      h4("Assemblage size vs. % retouched artefacts"),
      
      plotOutput(outputId="myplot"), br(),
      
      h4("Median selection variable: unretouched vs. retouched"),
      
      plotOutput(outputId="retouched_size_plot"), br(),
      
      h4("Number of retouched episodes among retouched artefacts"),

      plotOutput(outputId="retouch_intensity_plot"),
      
      h6("References:"),
      h6("Lin, S. C. (2018). Flake selection and scraper retouch probability: an alternative model for explaining Middle Paleolithic assemblage retouch variability. Archaeological and Anthropological Sciences, 10, 1791-1806."),
      h6("Lin, S. C., McPherron, S. P., & Dibble, H. L. (2015). Establishing statistical confidence in Cortex Ratios within and among lithic assemblages: a case study of the Middle Paleolithic of southwestern France. Journal of Archaeological Science, 59, 89-109."),
      h6("Lin, S. C., Pop, C. M., Dibble, H. L., Archer, W., Desta, D., Weiss, M., & McPherron, S. P. (2016). A core reduction experiment finds no effect of original stone size and reduction intensity on flake debris size distribution. American Antiquity, 81(3), 562-575.")
    )
  )
)


server <- function(input, output) {
  
  
  
  
  wrap_output <- reactive ({
    
    prob_retouch <- input$prob_retouch
    select_strength <- input$select_strength
    select_variable <- input$select_variable
    max.n <- input$max_accumulation
    retouch_method <- input$retouch_method
    n_retouch <- input$n_retouch
    
    sim_output <- foreach(l=1:input$n_assemblages, 
                          .combine='rbind', 
                          .export = c("assemblage_simulator", 
                                      "exp_data")) %dopar% {
                                        
                                        assemblage_simulator(exp_data, iteration=1000, max.n, prob_retouch, select_strength, select_variable, retouch_method, n_retouch)
                                        
                                      }
    
    
  })   
  
  
  #return(sim_output[-1,])
  
  output$myplot <- renderPlot({ 
    
    if (input$output_type==1) {
      
      print(ggplot(wrap_output(), aes(n, p_retouch)) + geom_point() + geom_smooth() + 
              xlim(0, input$max_accumulation)  + theme_minimal() + scale_y_continuous(labels = scales::percent, limits=c(0,1)) +
              xlab("Number of artifacts") + ylab("% Retouched") )
    }
    
    if (input$output_type==2) {
      
      print(ggplot(wrap_output(), aes(as.factor(n_interval), p_retouch)) + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme_minimal() +  scale_y_continuous(limits = c(0.01,1), labels = scales::percent)  + 
              scale_x_discrete(na.translate = F) + theme(axis.text.x=element_text(angle = 30)) +
              xlab("Number of artifacts") + ylab("% Retouched") )
    }
    
    if (input$output_type==3) {
      
      print(ggplot(wrap_output(), aes(n, p_retouch)) + geom_point() + geom_smooth(method="lm") + 
              theme_minimal() + scale_x_continuous(trans='log10') +
              scale_x_log10(limits = c(10,input$max_accumulation)) + 
              scale_y_log10(limits = c(0.01,1), labels = scales::percent)  + 
              xlab("Number of artifacts") + ylab("% Retouched") +
              stat_poly_eq(aes(label = paste(after_stat(eq.label),
                                             after_stat(rr.label),
                                             after_stat(p.value.label),
                                             sep = "*\", \"*")), size=6))
    }
    
  })
  
  output$retouched_size_plot <- renderPlot({
    
    plot_data <- rbind(data.frame(type="Unretouched flakes", size=wrap_output()$median_nonretouch_size),
      data.frame(type="Retouched flakes", size=wrap_output()$median_retouch_size))
    
    plot_data$type <- factor(plot_data$type, levels = c("Unretouched flakes", "Retouched flakes"))
    
        ggplot(plot_data, aes(type, size)) +  geom_boxplot() +  theme_minimal() +  ylab("Median value of selection variable") +  theme(axis.title.x = element_blank())
    
  })
  
  output$retouch_intensity_plot <- renderPlot({

    print(ggplot(wrap_output(), aes(median_retouch_intensity)) + geom_histogram(width=1) +
            theme_minimal() + xlab('Number of retouch episodes') + ylab('Number of retouched artefacts') + xlim(0, 5) )

  })
  
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
