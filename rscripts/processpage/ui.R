
library(shiny)

shinyUI(fluidPage(
  title = "Check process! @ P-CAPS",
  
  fluidRow(
    column(4,
           h2(uiOutput('pagename'), align = "center"),
           h4(strong(textOutput('phase', inline = TRUE)), align = "center", style = "color:black; margin-top:20px"),
           h5(strong(textOutput('ctime')), align = "center", style = "color:darkgrey; margin-top:25px"),
           h5(uiOutput('sen'), align = "center"),
           h5(strong(uiOutput('reporting')), align = "center", style = "color:MediumSlateBlue"),
           h6(actionButton(inputId = 'backtohome', label = 'Go back to home!', width = '150px', onclick = "window.open('http://yourservername/pcaps/mainpage/', '_self')"), align = "center", style = "margin-top:200px")
    ),
    column(8,
    column(12, style = "margin-top : 100px", tags$legend("See log files.")),
    h4(align = "center", style = "margin-top:10px",
       actionButton(inputId = 'rm', label = "rRNA prediction", class = 'label label-default'),
       actionButton(inputId = 'tr', label = "tRNA prediction", class = 'label label-default'),
       actionButton(inputId = 'pr', label = "Gene prediction 1", class = 'label label-default'),
       actionButton(inputId = 'ge', label = "Gene prediction 2", class = 'label label-default'),
       actionButton(inputId = 'fc', label = "Filtering CDS", class = 'label label-default'),
       actionButton(inputId = 'bl', label = "Gene annotation", class = 'label label-default'),
       br(),
       actionButton(inputId = 'ke', label = "KEGG Ortholog analysis", class = 'label label-default'),
       actionButton(inputId = 'is', label = "Protein domain analysis", class = 'label label-default'),
       actionButton(inputId = 'ga', label = "Make annotation file", class = 'label label-default'),
       actionButton(inputId = 'bu', label = "Genome completeness test", class = 'label label-default'),
       actionButton(inputId = 'inf', label = "Annotation reporting", class = 'label label-default'),
       actionButton(inputId = 'jb', label = "Genome visualization", class = 'label label-default')
    ),
    column(12, style = "margin-top:10px",
           wellPanel(
             style = c("overflow-y:scroll; max-height: 300px"),
             h6(verbatimTextOutput('log'), align = 'center')
           )
    )
  )
  ),
  column(8, offset = 2, uiOutput('downloadfiles'))
))
