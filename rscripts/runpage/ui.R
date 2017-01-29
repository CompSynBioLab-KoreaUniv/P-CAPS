
library(shiny)

shinyUI(fluidPage(
  title = "Run! @ P-CAPS",
  h1(strong("Your job is running now!"), align = "center", style = "color:darkblue; margin-top:100px"),
  h4(strong(em("You can find your project by your job ID!")), align = "center", style="color:MediumSlateBlue; margin-top:30px"),
  h6(tags$img(src = "img01.JPG", width = "800px", height = "400px"), align = "center", style="margin-top:25px"),
  h6(actionButton(inputId = 'backtohome', label = 'Go back to home!', width = '150px', onclick = "window.open('http://yourservername/pcaps/mainpage/', '_self')"), align = "center", style = "margin-top:30px")
))
