
library(shiny)
library(stringr)

fasta_test = function(fasta){
  if(length(fasta)==0)
  {paste0('[INPUT ERROR] ', "Please upload FASTA format('*.fa', *.fna', '*.fasta') file!")}
  else
  {NULL}
}

proj_length = function(input){
  if(str_length(input)>10)
  {"[INPUT ERROR] Project name should be less than 10 characters!"}
  else if(str_length(input)==0)
  {"[INPUT ERROR] Please write your project name!"}
  else
  {NULL}
}

choose_db = function(input){
  if(is.na(input)){
    "[INPUT ERROR] Please select proper databas e for running BUSCO!"
  } else {}
}

mail_test = function(input){
  if(length(input)==0){
    paste0('[INPUT ERROR] ', "Please write your address!")
  } else if (str_detect(input, "@")==FALSE){
    paste0("[INPUT_ERROR] ", "Your email address is not valid")
  }
}

shinyServer(function(input, output, session){
  
  pdate = format(Sys.time(), "%y%m%d")
  val = system2('cat', '/home/pCAPS/log/validation.log', stdout = TRUE)
  pname = val[1]
  sfile = val[2]
  buscodb = val[3]
  emailadr = val[4]
  system2('ls', c('-t', '/home/pCAPS', '>', '/home/pCAPS/log/plist.txt'))
  namelist = system2('head', c('-n', '2', '/home/pCAPS/log/plist.txt'), stdout = TRUE)
  name = namelist[1]
  wholepath = paste0('/home/pCAPS/', name)

  output$pid = renderText({
    
    len_proj = nchar(pname)
    len_sfile = nchar(sfile)
    len_emailadr = nchar(emailadr)
    
    if(is.na(pname)){
      paste0("Please check error message and modify your annotation information!")
    } else if(is.na(sfile)){
      paste0("Please check error message and modify your annotation information!")
    } else if(is.na(emailadr)){
      paste0("Please check error message and modify your annotation information!")
    } else if(is.na(buscodb)){
      paste0("Please check error message and modify your annotation information!")
    } else {
      paste0("Your project ID is ", name, " !")
    }
  })
  
  output$deletefolder = renderUI({
    len_proj = nchar(pname)
    len_sfile = nchar(sfile)
    len_emailadr = nchar(emailadr)
    
    if(is.na(pname)){
      system2('rm', c('-r', wholepath))
    } else if(is.na(sfile)){
      system2('rm', c('-r', wholepath))
    } else if(is.na(emailadr)){
      system2('rm', c('-r', wholepath))
    } else if(is.na(buscodb)){
      system2('rm', c('-r', wholepath))
    } else {}
    
  })  
  
  output$vali = renderText({
    validate(
      proj_length(pname),
      fasta_test(sfile),
      choose_db(buscodb),
      mail_test(emailadr)
    )
    
    paste0(
      "\n",
      "It's ready for running annotation process successfully!!", "\n",
      "-----------------------------------------------------------", "\n",
      "Project name : ", pname, "\n",
      "FASTA file : ", sfile, "\n",
      "Email address : ", emailadr, "\n",
      "Annotation job ID : ", name, "\n",
      "\n", "\n"
    )
    
  })
  
  output$ctime = renderText({
    invalidateLater(1000, session)
    paste0("Current time : ", Sys.time())
  })
  
  output$buttons = renderUI({
    
    len_proj = nchar(pname)
    len_sfile = nchar(sfile)
    len_emailadr = nchar(emailadr)
    
    if(len_proj == 0 || len_sfile == 0 || len_emailadr == 0 || buscodb == 0){
      h6(actionButton(inputId = 'backtohome', label = 'Go back to home!', width = '150px', onclick = "window.open('http://yourservername/pcaps/mainpage/', '_self')"), 
         align = "center", style = "margin-top:10px")
    } else if(str_detect(emailadr, "@") == FALSE){
      h6(actionButton(inputId = 'backtohome', label = 'Go back to home!', width = '150px', onclick = "window.open('http://yourservername/pcaps/mainpage/', '_self')"), 
         align = "center", style = "margin-top:10px")
    } else {
    h6(actionButton(inputId = 'run', label = 'Run P-CAPS!', width = '160px', onclick = "window.open('http://yourservername/pcaps/runpage/', '_self')"), 
       actionButton(inputId = 'backtohome', label = 'Go back to home!', width = '150px', onclick = "window.open('http://yourservername/pcaps/mainpage/', '_self')"), 
       align = "center", style = "margin-top:10px")
    }
  })
  

})
