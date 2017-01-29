library(shiny)
library(stringr)

options(shiny.maxRequestSize=30*1024^2) #1MB = 1*1024^2

generate_pid = function(input, output){
  
  num = sample(1:99999, 1)
  pid_num = strsplit(as.character(num), '*')[[1]]
  
  char = strsplit(input, '*')[[1]]

  for(a in 1:5){
    if(is.na(char[a])==TRUE){
      char[a] = 'x'
    } else {}
  }
  
  pid_char = sample(char[1:5], 5)
  
  pid_f = NULL
  a = 1
  
  for(i in 1:5){
    pid_f[a] = pid_char[i]
    a = a + 1
    pid_f[a] = pid_num[i]
    a = a + 1
  }
  final_pid = NULL
  
  for(i2 in 1:10){
    final_pid = paste0(final_pid, pid_f[i2])
  }
  output = final_pid
}

shinyServer(function(input, output){
  
  observeEvent(input$submit1,{

  pdate = format(Sys.time(), "%y%m%d")  
  seqfile = input$sfile
  seqfilename = seqfile$name
  jobid = generate_pid(input$pname)
  
  write(input$pname, file = '/home/pCAPS/log/validation.log', sep = '\n')
  write(seqfilename, file = '/home/pCAPS/log/validation.log', append = TRUE, sep = '\n')
  write(input$buscodb, file = '/home/pCAPS/log/validation.log', append = TRUE, sep = '\n')
  write(input$emailaddr, file = '/home/pCAPS/log/validation.log', append = TRUE, sep = '\n')

  # generate project folder&log file  
  
  system2('mkdir', paste0('/home/pCAPS/', jobid))
  system2('mkdir', paste0('/home/pCAPS/', jobid, '/temp'))
  project_path = paste0('/home/pCAPS/', jobid)
  
  write(jobid, file = paste0(project_path, '/temp/', jobid, '.log'), sep = '')
  
  # read an input file and write sequence file

  file.copy(seqfile$datapath, paste0(project_path, '/', seqfile$name))
  write(input$gcode, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(seqfile$name, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(input$kingdom, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(input$metagenome, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(input$pname, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(input$buscodb, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  write(input$emailaddr, file = paste0(project_path, '/temp/', jobid, '.log'), append = TRUE, sep = '\n')
  })
  
  observeEvent(input$findjob,{
    jobid2 = isolate(input$jobid)
    project_path = paste0('/home/pCAPS/', jobid2)
    write(jobid2, file = '/home/pCAPS/log/search.log', append = FALSE)
  })
  
}
  
)
