
library(shiny)
library(seqinr)
library(stringi)
library(rmarkdown)

shinyServer(function(input, output, session){
  qpname = system2('head', c('-n', '1', '/home/pCAPS/log/search.log'), stdout = TRUE)
  project_path = paste0('/home/pCAPS/', qpname)
  projectlog_path = paste0('/home/pCAPS/', qpname, '/temp/process.log')
  gff_path = paste0(project_path, "/fully_decorated_anno_iprscan.gff")
  gff_path2 = paste0(project_path, "/fully_decorated.gff")
  seestate = system2('tail', c('-1', projectlog_path), stdout = TRUE)
  
  output$reporting = renderUI({
    
    kegg_path = paste0("/home/pCAPS/", qpname, "/keggmap/ko_summary.txt")
    anno_path = paste0("/home/pCAPS/", qpname, "/temp/annoinfo.txt")
    html_out = paste0(project_path, "/keggmap/", qpname, ".html")
    pdf_out = paste0(project_path, "/keggmap/", qpname, ".pdf")
    word_out = paste0(project_path, "/keggmap/", qpname, ".docx")
    
    if(file.size(kegg_path) != 54 && file.exists(kegg_path) == TRUE){
      if(file.exists(anno_path) == TRUE){
        render("/home/pCAPS/docs/result.Rmd", html_document(), output_file = html_out)
        render("/home/pCAPS/docs/result.Rmd", pdf_document(), output_file = pdf_out)
        render("/home/pCAPS/docs/result.Rmd", word_document(), output_file = word_out)
      } else {}
    } else {}
    
   if(file.exists(html_out) == TRUE){
     if(file.exists(pdf_out) == TRUE){
       if(file.exists(word_out) == TRUE){
         paste0("You can download the report file in HTML/PDF/MS-WORD format.")
       } else {
         paste0("You can download the report file in HTML/PDF format.")
       }
     } else {
       if(file.exists(word_out) == TRUE){
         paste0("You can download the report file in HTML/MS-WORD format.")
       } else {
         paste0("You can download the report file in HTML format.")
       }
     }
   } else {
     if(file.exists(pdf_out) == TRUE){
       if(file.exists(word_out) == TRUE){
         paste0("You can download the report file in PDF/MS-WORD format.")
       } else {
         paste0("You can download the report file in PDF format.")
       }
     } else {
       if(file.exists(word_out) == TRUE){
         paste0("You can download the report file in MS-WORD format.")
       } else {
         if(stri_cmp_eq(seestate, "You can download result files!") == TRUE){
           paste0("There was critical errors on writting annotation reports. Check up your log files!")
         } else {}
       }
     }
   } 
  })
  
  output$pagename = renderUI({
    if(file.exists(projectlog_path) == TRUE){
      if(file.exists(paste0(project_path, '/temp/annoinfo.txt')) == FALSE){
        if(stri_cmp_eq(seestate, "You can download result files!") == FALSE){
          h2(strong("Your job is running now!"), style = "color:darkblue; margin-top:130px")
        } else {
          h2(strong("Your job is terminated."), style = "color:darkblue; margin-top:130px")
        }
      } else {
        h2(strong("Your job is terminated."), style = "color:darkblue; margin-top:130px")
      }
    } else {
      h2(strong("This project ID is wrong.", p(), "Please check your project ID."), style = "color:darkblue; margin-top:130px")
    }
  })
  
  output$phase = renderText({
    if(file.exists(projectlog_path) == TRUE){
      if(file.exists(gff_path) == TRUE){
        paste0(system2('tail', c('-1', projectlog_path), stdout = TRUE))
      } else if(file.exists(gff_path2) == TRUE){
        paste0(system2('tail', c('-1', projectlog_path), stdout = TRUE))
      } else {
        if(stri_cmp_eq(seestate, "You can download result files!") == TRUE){
          paste0("Critical error occured in P-CAPS.\n Please check log file of each phase.")
        } else {
          paste0("Process state : ", seestate)
        }
      }
    } else {
      "This project ID is incorrect.\n Please check and enter your project ID!"
    }
  })

  output$ctime = renderText({
    invalidateLater(1000, session)
    paste0("Current time : ", Sys.time())
  })

  output$sen = renderUI({
    if(file.exists(projectlog_path)==TRUE){
      if(file.exists(gff_path) == TRUE){} else if(file.exists(gff_path2) == TRUE){} else {
        if(stri_cmp_eq(seestate, "You can download result files!") == TRUE){} else{
          h5(icon("cog", lib="font-awesome", class="fa fa-refresh fa-spin"), strong("If you want to know the updated status,", p(), "please check again on the main page!"), align = "center", style = "color:Crimson; margin-top:15px")
      }}
    } else {}  
  })
  
  output$downloadfiles = renderUI({
    if(file.exists(projectlog_path)==TRUE){
      if(file.exists(gff_path)==TRUE && file.exists(gff_path2)==TRUE){
        column(12, offset = 1,
               column(12, offset = 2, tags$legend("Download annotation result files.")),
               column(3, offset = 2, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-warning",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(outputId = 'gff', label = "GFF3 file"),br(),br(),                  
                             downloadButton(outputId = 'gbff', label = "GenBank(gbff) file"),br(),br(),
                             downloadButton(outputId = 'ipr', label = "InterProScan file"))
                        ))),
               column(3, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-success",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Sequence files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(outputId = 'faa', label = "Protein sequence file"),br(),br(),
                             downloadButton(outputId = 'rrnaseq', label = "rRNA sequence file"),br(),br(),
                             downloadButton(outputId = 'trnaseq', label = "tRNA sequence file"))
                        )
                      )),
               column(4, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-info",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation reports")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center", style = "margin-top:10px",
                             downloadButton(outputId = 'reports', label = "Annotation summary report (Text)"),br(),br(),
                             downloadButton(outputId = 'reporth', label = "Annotation Report (HTML)"),br(),br(),
                             downloadButton(outputId = 'reportp', label = "Annotation Report (PDF)"),br(),br(),
                             downloadButton(outputId = 'reportw', label = "Annotation Report (MS-WORD)")),br()
                        )
                      ))
               )

      } else if(file.exists(gff_path2)==TRUE && file.exists(gff_path)==FALSE){
        column(12, offset = 1,
               column(12, offset = 2, tags$legend("Download annotation result files.")),
               column(3, offset = 2, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-warning",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(outputId = 'gff', label = "GFF3 file"),br(),br(),                  
                             downloadButton(outputId = 'gbff', label = "GenBank(gbff) file"),br(),br(),
                             downloadButton(outputId = 'ipr', label = "InterProScan file"))
                        ))),
               column(3, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-success",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Sequence files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(outputId = 'faa', label = "Protein sequence file"),br(),br(),
                             downloadButton(outputId = 'rrnaseq', label = "rRNA sequence file"),br(),br(),
                             downloadButton(outputId = 'trnaseq', label = "tRNA sequence file"))
                        )
                      )),
               column(4, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-info",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation reports")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center", style = "margin-top:10px",
                             downloadButton(outputId = 'reports', label = "Annotation summary report (Text)"),br(),br(),
                             downloadButton(outputId = 'reporth', label = "Annotation Report (HTML)"),br(),br(),
                             downloadButton(outputId = 'reportp', label = "Annotation Report (PDF)"),br(),br(),
                             downloadButton(outputId = 'reportw', label = "Annotation Report (MS-WORD)")),br()
                      ))
               )
        )
      } else if(file.exists(gff_path)==FALSE && file.exists(gff_path2)==FALSE){
        column(12, offset = 1,
               column(12, offset = 2, tags$legend("Download annotation result files.")),
               column(3, offset = 2, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-warning",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(class = "btn btn-default disabled", outputId = 'gff', label = "GFF3 file with Pfam"),br(),br(),                  
                             downloadButton(class = "btn btn-default disabled", outputId = 'gff2', label = "GFF3 file"),br(),br(),                  
                             downloadButton(class = "btn btn-default disabled", outputId = 'gbff', label = "GenBank(gbff) file"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'ipr', label = "InterProScan file"))
                        ))),
               column(3, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-success",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Sequence files")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center",
                             downloadButton(class = "btn btn-default disabled", outputId = 'faa', label = "Protein sequence file"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'rrnaseq', label = "rRNA sequence file"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'trnaseq', label = "tRNA sequence file"))
                        )
                      )),
               column(4, style = "margin-top : 5px",
                      tags$div(
                        class = "panel panel-info",
                        tags$div(
                          class = "panel-heading",
                          h3(align = "center", class = "panel-title", "Annotation reports")
                        ),
                        tags$div(
                          class = "panel-body",
                          h6(align = "center", style = "margin-top:10px",
                             downloadButton(class = "btn btn-default disabled", outputId = 'reports', label = "Annotation summary report (Text)"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'reporth', label = "Annotation Report (HTML)"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'reportp', label = "Annotation Report (PDF)"),br(),br(),
                             downloadButton(class = "btn btn-default disabled", outputId = 'reportw', label = "Annotation Report (MS-WORD)")),br()
                      ))
               )
               
        )
      }
    }
  })
  
  # Print log file 
  context = reactiveValues(logtext=paste0("You can see log files from annotation process.", "\n", "Press a process button what you want to see log file!"))
  logdefault = paste0("You can see log files from annotation process.", "\n", "Press a process button what you want to see log file!")
  logerror = paste0("This procedure is not started yet. \n You can see log file after procedure is started. \n Please wait until this procedure is started.\n")
  
  observeEvent(input$rm, {
    if(file.exists(paste0(project_path, "/annolog/rnammer.log"))){
      loglog = readLines(paste0(project_path, "/annolog/rnammer.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$tr, {
    if(file.exists(paste0(project_path, "/annolog/trnascan.log"))){
      loglog = readLines(paste0(project_path, "/annolog/trnascan.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$pr, {
    if(file.exists(paste0(project_path, "/annolog/prodigal.log"))){
      loglog = readLines(paste0(project_path, "/annolog/prodigal.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$ge, {
    if(file.exists(paste0(project_path, "/annolog/genemarks.log"))){
      loglog = readLines(paste0(project_path, "/annolog/genemarks.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$fc, {
    if(file.exists(paste0(project_path, "/annolog/filtering.log"))){
      loglog = readLines(paste0(project_path, "/annolog/filtering.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$bl, {
    if(file.exists(paste0(project_path, "/annolog/blastp.log"))){
      loglog = readLines(paste0(project_path, "/annolog/blastp.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$ke, {
    if(file.exists(paste0(project_path, "/annolog/kegg.log"))){
      loglog = readLines(paste0(project_path, "/annolog/kegg.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$is, {
    if(file.exists(paste0(project_path, "/annolog/iprscan.log"))){
      loglog = readLines(paste0(project_path, "/annolog/iprscan.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$ga, {
    if(file.exists(paste0(project_path, "/annolog/makegff.log"))){
      loglog = readLines(paste0(project_path, "/annolog/makegff.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$bu, {
    if(file.exists(paste0(project_path, "/annolog/busco.log"))){
      loglog = readLines(paste0(project_path, "/annolog/busco.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$inf, {
    if(file.exists(paste0(project_path, "/annolog/writereport.log"))){
      loglog = readLines(paste0(project_path, "/annolog/writereport.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  observeEvent(input$jb, {
    if(file.exists(paste0(project_path, "/annolog/jbrowse.log"))){
      loglog = readLines(paste0(project_path, "/annolog/jbrowse.log"))
      context$logtext = paste(loglog, collapse = "\n")
    } else {
      context$logtext = logerror
    }
  })
  
  output$log = renderText({
    
    if(is.null(context$logtext)) {return ()}
    else
    {context$logtext}
    
  })
  
  # Download file
  output$gff = downloadHandler(
    filename = function(){
      paste0(qpname, ".gff")
    },
    content = function(file){
      file.copy(paste0(project_path, "/fully_decorated.gff"), file)
    }
  )
  
  output$gbff = downloadHandler(
    filename = function(){
      paste0(qpname, ".gbff")
    },
    content = function(file){
      file.copy(paste0(project_path, "/fully_decorated.gbff"), file)
    }
  )
  
  output$ipr = downloadHandler(
    filename = function(){
      paste0(qpname, ".tsv")
    },
    content = function(file){
      file.copy(paste0(project_path, "/iprscan/iprscan_output.gff"), file)
    }
  )
  
  output$reports = downloadHandler(
    filename = function(){
      paste0(qpname, ".txt")
    },
    content = function(file){
      file.copy(paste0(project_path, "/temp/annoinfo.txt"), file)
    }
  )
  
  output$reportp = downloadHandler(
    filename = function(){
      paste0(qpname, ".pdf")
    },
    content = function(file){
      file.copy(paste0(project_path, "/annoinfo.pdf"), file)
    }
  )
  
  output$reporth = downloadHandler(
    filename = function(){
      paste0(qpname, ".html")
    },
    content = function(file){
      file.copy(paste0(project_path, "/annoinfo.html"), file)
    }
  )
  
  output$faa = downloadHandler(
    filename = function(){
      paste0(qpname, ".faa")
    },
    content = function(file){
      file.copy(paste0(project_path, "/gff/re_tagged.faa"), file)
    }
  )
  
  output$rrnaseq = downloadHandler(
    filename = function(){
      paste0(qpname, "_rrna.faa")
    },
    content = function(file){
      file.copy(paste0(project_path, "/rnammer/protein_output.fasta"), file)
    }
  )
  
  output$trnaseq = downloadHandler(
    filename = function(){
      paste0(qpname, "_trna.faa")
    },
    content = function(file){
      file.copy(paste0(project_path, "/trnascanse/protein_output.fasta"), file)
    }
  )
  
  output$ctime = renderText({
    invalidateLater(1000, session)
    paste0("Current time : ", Sys.time())
  })
  
  output$reporth = downloadHandler(
    filename = function(){
      paste0(qpname, ".html")
    },
    content = function(file){
      file.copy(paste0(project_path, "/keggmap/", qpname, ".html"), file)
    }
  )
  
  output$reportp = downloadHandler(
    filename = function(){
      paste0(qpname, ".pdf")
    },
    content = function(file){
      file.copy(paste0(project_path, "/keggmap/", qpname, ".pdf"), file)
    }
  )
  
  output$reportw = downloadHandler(
    filename = function(){
      paste0(qpname, ".docx")
    },
    content = function(file){
      file.copy(paste0(project_path, "/keggmap/", qpname, ".docx"), file)
    }
  )
  

})
