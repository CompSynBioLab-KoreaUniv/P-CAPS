
library(shiny)
library(seqinr)
library(stringr)

genesize = function(input, output){
  s = read.fasta(input, seqtype = 'DNA', as.string = TRUE)
  length_contig = as.numeric(str_length(s))
  num_contig = as.numeric(length(length_contig))
  allbase = 0
  
  if(num_contig == 1){
    output = length_contig
  } else {
    for(i in 1:num_contig){
      allbase = allbase + length_contig[i]
    }
    output = allbase
  }
}

shinyServer(function(input, output, session){ 

  pnamelist = system2('head', c('-n', '2', '/home/pCAPS/log/plist.txt'), stdout = TRUE)
  pname = pnamelist[1]
  inputinfo = system2('head', c('-n', '8', paste0('/home/pCAPS/', pname, '/temp/', pname, '.log')), stdout = TRUE)
  folder_path = paste0('/home/pCAPS/', inputinfo[1])
  g_code = inputinfo[2]
  file_f = inputinfo[3]
  kingdom = inputinfo[4]
  folder_name = pname
  metagenome = inputinfo[5]
  g_size = genesize(paste0('/home/pCAPS/', inputinfo[1], '/', file_f))
  proj_name = inputinfo[6]
  busco_db = inputinfo[7]
  mail_addr = inputinfo[8]
  
  system2('/home/pCAPS/scripts/execute.sh', c(folder_path, file_f, g_code, g_size, kingdom, folder_name, metagenome, proj_name, busco_db, mail_addr))

})
