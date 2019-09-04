
#TODO
# check question performance
# Calibrartion: which to present? now only the first ... probably not the best

input_folder = "./hyperlinks_raw_data/"
output_folder = "./hyperlinks_raw_data_BIDS/"


input_file_names = list.files(input_folder, pattern= "*.asc$")

cb_cd = function(path){
  if(dir.exists(path)){
    print(paste("Folder existis: ",path,sep=""))
  }else{
    dir.create(path)
    print(paste("Create: ",path,sep=""))
  }
}


for (i in 1:length(input_file_names)){
  vp = strsplit(input_file_names[i],split="_")[[1]] [1]
  aq = strsplit(input_file_names[i],split="_")[[1]] [2]
  #print(vp)
  #print(aq)
  
  indi_folder_path = paste(output_folder,"sub-",vp,sep="")
  cb_cd(indi_folder_path)
  indi_folder_path = paste(output_folder,"sub-",vp,"/eyetrack",sep="")
  cb_cd(indi_folder_path)
  
  file.copy(paste(input_folder,input_file_names[i],sep="")
            , paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_eyetrack.asc",sep="")
            )
  
  #get cal info
  tmp_file = readLines(paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_eyetrack.asc",sep=""))
  tmp_file_cal = strsplit(tmp_file[grepl("!CAL VALIDATION",tmp_file)],split = " ")
  calibration = tmp_file_cal[[1]][4]
  eye = tmp_file_cal[[1]][6]
  error_max = tmp_file_cal[[1]][9]
  error_avg = tmp_file_cal[[1]][11]
  
  sampl_freq = round(as.numeric(strsplit(tmp_file[grepl("SAMPLES	GAZE	RIGHT	RATE",tmp_file)],split = "\t")[[1]][5],0))
  
  write(paste('{\n\t"SamplingFrequency": ',sampl_freq,',\n\t"StartMessage": "MASKSCREEN_START",\n\t"EndMessage": "TRIAL_RESULT",\n\t"EventIdentifier": "EFIX",\n\t'
              ,'"Manifacturer": "SR-Research",\n\t"ManufacturersModelName": "EYELINK II CL v4.51 Mar 13 2010",\n\t"SoftwareVersions": "SREB1.10.165 WIN32 LID:5C0F381A Mod:2013.11.08 08:51 MEZ",\n\t'
              ,'"TaskDescription": "Silent reading with catch trials including a invisible boundary manipulation",\n\t"Instructions":"Read the following sentences as if you were reading a book or a newspaper.",\n\t'
              ,'"InstitutionName": "University of Salzburg; Department of Psychology",\n\t"InstitutionAddress": "Hellbrunnerstrasse 34; 5020 Salzburg; Austria",\n\t'
              ,'"Calibration type": "',calibration,'",\n\t"Recorded eye": "',eye,'",\n\t"Maximal calibration error": ',error_max,',\n\t"Average calibration error": ',error_avg
              ,"\n}",sep = "")
        , file = paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_eyetrack.json",sep=""))
  
  
  #get stim info for events file
  tmp_file_sub_all = tmp_file[grepl("MASKSCREEN_START|TRIAL_RESULT|KEYPRESS",tmp_file)]
  tmp_file_sub_all = tmp_file_sub_all[!grepl('_ue',tmp_file_sub_all)]
  tmp_file_sub = tmp_file_sub_all[grepl("MASKSCREEN_START",tmp_file_sub_all)]
  
  for (ii in 1:length(tmp_file_sub)){
    
    time = as.numeric(strsplit(strsplit(tmp_file_sub[ii], split="\t")[[1]][2], split=" ")[[1]][1])
    info = strsplit(strsplit(tmp_file_sub[ii], split="\t")[[1]][2], split=" ")[[1]][3]
    info = strsplit(info, split="_")
    index = match(tmp_file_sub[ii],tmp_file_sub_all)
    t_end = as.numeric(strsplit(strsplit(tmp_file_sub_all[index+1], split="\t")[[1]][2], split=" ")[[1]][1])
    
    if (ii == 1){
      exp_start_time = time
      
      start_time = time-exp_start_time
      duration = t_end-time
      target_word = info[[1]][3]
      color = info[[1]][4]
      mask = info[[1]][5]
      underlining = info[[1]][6]
      stimulus_pos_first_letter = info[[1]][7]
      
      if(grepl("KEYPRESS",tmp_file_sub_all[index+2])){
        keypress = strsplit(strsplit(strsplit(tmp_file_sub_all[index+2], split="\t")[[1]][2], split=" ")[[1]][3],split="_")[[1]][1]
      }else{
        keypress = "n/a"  
      }
      
    }else{
      start_time[ii] = time-exp_start_time
      duration[ii] = t_end-time
      
      target_word[ii] = info[[1]][3]
      color[ii] = info[[1]][4]
      mask[ii] = info[[1]][5]
      underlining[ii] = info[[1]][6]
      stimulus_pos_first_letter[ii] = info[[1]][7]
      
      if(grepl("KEYPRESS",tmp_file_sub_all[index+2])){
        keypress[ii] = strsplit(strsplit(strsplit(tmp_file_sub_all[index+2], split="\t")[[1]][2], split=" ")[[1]][3],split="_")[[1]][1]
      }else{
        keypress[ii] = "n/a"  
      }
    }
  }
  event_df = data.frame(start_time,duration,target_word,color,mask,underlining,stimulus_pos_first_letter,keypress)
  event_df$start_time = event_df$start_time/1000
  event_df$duration = event_df$duration/1000
  event_df$color = as.character(event_df$color)
  event_df$color[event_df$color=="K"]="Black"
  event_df$color[event_df$color=="E"]="Blue"
  event_df$mask = as.character(event_df$mask)
  event_df$mask[event_df$mask=="DEG"]="Degraded"
  event_df$mask[event_df$mask=="LET"]="Un-degraded"
  event_df$underlining = as.character(event_df$underlining)
  event_df$underlining[event_df$underlining=="U"]="Underlined"
  event_df$underlining[event_df$underlining=="N"]="Not underlined"
  
  write.table(event_df,row.names = F, file = paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_events.tsv",sep=""))
  

}


