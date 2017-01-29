
library(shiny)

shinyUI(fluidPage(
  title = "Validation for running! @ P-CAPS",
  h1(strong("Validation test for P-CAPS"), align = "center", style = "color:darkblue; margin-top:130px"),
  h4(strong(textOutput('ctime')), align = "center", style = "color:darkgrey; margin-top:25px"),
  h4(strong(em(textOutput('pid'))), align = "center", style="color:SlateGray; margin-top:30px"),
  h5(strong("If you want to check your project later, please remember your project ID!"), align = "center", style = "color:MediumVioletRed"),
  br(),
  br(),
  column(4, offset = 4,
    wellPanel(
      h6(verbatimTextOutput('vali'), align = "center")
    ),
    h6(uiOutput('buttons'), style = "margin-top:50px"),
    h6(uiOutput('deletefolder'))
    )
))