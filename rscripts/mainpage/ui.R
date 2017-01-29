library(shiny)

genecode = list("Yeast mitochondrial code" = 3,
                "Mold mitochondrial Code" = 4,
                "Protozoan mitochondrial Code" = 4,
                "Coelenterate mitochondrial Code" = 4,
                "Mycoplasma/Spiroplasma code" = 4,
                "Echinoderm mitochondrial code" = 9,
                "Flatworm mitochondrial code" = 9,
                "The bacterial, archaeal code" = 11,
                "Ascidian mitochondrial code" = 13,
                "Chlorophycean mitochondrial code" = 16,
                "Trematode mitochondrial code" = 21,
                "Scenedesmus obliquus Mitochondrial Code" = 22,
                "Thraustochytrium Mitochondrial Code" = 23)

buscodblist = list("## Choose a proper database for BUSCO" = NA,
                   "actinobacteria_odb9" = "actinobacteria_odb9",
                   "bacillales_odb9" = "bacillales_odb9",
                   "bacteria_odb9" = "bacteria_odb9",
                   "bacteroidetes_odb9" = "bacteroidetes_odb9",
                   "betaproteobacteria_odb9" = "betaproteobacteria_odb9",
                   "clostridia_odb9" = "clostridia_odb9",
                   "cyanobacteria_odb9" = "cyanobacteria_odb9",
                   "deltaepsilonsub_odb9" = "deltaepsilonsub_odb9",
                   "enterobacteriales_odb9" = "enterobacteriales_odb9",
                   "firmicutes_odb9" = "firmicutes_odb9",
                   "gammaproteobacteria_odb9" = "gammaproteobacteria_odb9",
                   "lactobacillales_odb9" = "lactobacillales_odb9",
                   "proteobacteria_odb9" = "proteobacteria_odb9",
                   "rhizobiales_odb9" = "rhizobiales_odb9",
                   "spirochaetes_odb9" = "spirochaetes_odb9",
                   "tenericutes_odb9" = "tenericutes_odb9"
                   )

shinyUI(navbarPage("P-CAPS", 
                    position = "static-top", windowTitle = "P-CAPS(Prokaryotic Contig Annotation Pipeline Server)",

## Annotation part

  tabPanel("ANNOTATION",
           fluidRow(
              br(),br(),
              column(5, offset = 1, 
                     fluidRow(
                       column(11, 
                              wellPanel(
                                tags$legend("Submit annotation information for P-CAPS"),
                                textInput('pname', label = 'Project name (Write it less than 10 characters.)', placeholder = 'Do not enter project name with whitespace or dot'),
                                br(),
                                fileInput('sfile', label = 'Sequence file (Upload sequence file)', multiple = FALSE),
                                hr(),
                                radioButtons('kingdom', label = 'Super kingdom (Choose proper one to query sequence)',
                                             choices = list("Bacteria" = 'bac', "Archaea" = 'arc'), inline = TRUE,
                                             selected = 'bac'),
                                br(),
                                radioButtons('metagenome', label = 'Is it metagenome data? ',
                                             choices = list("Yes" = 1, "No" = 0), inline = TRUE,
                                             selected = 0),
                                br(),
                                selectInput('gcode', label = 'Genetic code (Choose proper one to query sequence)', choices = genecode, selected = 11),
                                br(),
                                selectInput('buscodb', label = 'BUSCO Database (Choose proper one to query sequence)', choices = buscodblist, selected = 0),
                                hr(),
                                textInput('emailaddr', label = 'E-mail address (Please write your email address for alerting)', placeholder = "Please fill in the blank!"),
                                br(),
                                br(),
                                actionButton('submit1', label = 'Submit', class = "btn btn-info", width = '80px', onclick = "window.open('http://yourservername/pcaps/validatepage/', '_self')")
                              ))
                     )),
              column(5,
                     column(10,
                            wellPanel(
                              tags$legend(h4("Lookup annotation job")),
                              textInput('jobid', label = "Enter your job ID : ", placeholder = 'ex)i9g3n1a3a1'),
                              br(),
                              actionButton('findjob', label = 'Searching it', width = '120px', onclick = "window.open('http://yourservername/pcaps/processpage/', '_self')")
                            )),
                     column(10,
                            wellPanel(
                              tags$legend(h4("Contact us")),
                              actionLink('csbl', label = 'Computational and Synthetic Biology Lab @ KU', onclick = "window.open('http://compbio.korea.ac.kr/', '_blank')"),
                              br(),
                              br(),
                              br()
                            ))
                     )
              )
            )

)
)
