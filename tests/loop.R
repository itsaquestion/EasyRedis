er = ErInit()
er$set("SnowFor_done",FALSE)
for(i in 1:100){
  er$set("SnowFor_check_time",Sys.time())
  #print(Sys.time())
  Sys.sleep(1)
}
er$set("SnowFor_done",TRUE)



code = "AB2313AC"
#number = as.numeric(paste0(stringr::str_extract_all(code,"[\\d]")[[1]],collapse = ""))

