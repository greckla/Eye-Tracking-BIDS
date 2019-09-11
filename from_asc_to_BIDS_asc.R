
#TODO
# check question performance
# Calibrartion: which to present? now only the first ... probably not the best 
#       -> KG: optimally match to the message, for which block was the calibration done or match to the time...? 
#       -> KG: in the present task different kinds of calibration used HV9 and HV13 and both eyes recorded..
#       -> KG: script changed --> one will get an extra dataframe with all calibrations for both eyes
#           and in the general info file, the summarized data from all calibrations are reported       

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
  id = strsplit(input_file_names[i],split=".asc")[[1]] [1]
  vp = strsplit(id,split="_")[[1]] [1]
  aq = strsplit(id,split="_")[[1]] [2]
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
  tmp_file_cal = strsplit(tmp_file[grepl("!CAL VALIDATION",tmp_file)&!grepl("ABORTED", tmp_file)],split = " ")
  
  #possibly you need to specify the correct value as the order of variables can variate
  for (cal_nr in 1:length(tmp_file_cal)){
    if (cal_nr ==1){
      calibration = tmp_file_cal[[1]][4]
      eye = tmp_file_cal[[cal_nr]][6]
      error_max = tmp_file_cal[[cal_nr]][12]
      error_avg = tmp_file_cal[[cal_nr]][10]
      time_cal = as.numeric(strsplit(tmp_file_cal[[cal_nr]], split="\t")[[1]][2], split=" ")
    }
    else if(tmp_file_cal[[cal_nr]][6]=="RIGHT"){
      calibration[cal_nr] = tmp_file_cal[[cal_nr]][4]
      eye[cal_nr] = tmp_file_cal[[cal_nr]][6]
      error_max[cal_nr] = tmp_file_cal[[cal_nr]][11]
      error_avg[cal_nr] = tmp_file_cal[[cal_nr]][9]
      time_cal[cal_nr] = as.numeric(strsplit(tmp_file_cal[[cal_nr]], split="\t")[[1]][2], split=" ")
    }
    else{
      calibration[cal_nr] = tmp_file_cal[[cal_nr]][4]
      eye[cal_nr] = tmp_file_cal[[cal_nr]][6]
      error_max[cal_nr] = tmp_file_cal[[cal_nr]][12]
      error_avg[cal_nr] = tmp_file_cal[[cal_nr]][10]
      time_cal[cal_nr] = as.numeric(strsplit(tmp_file_cal[[cal_nr]], split="\t")[[1]][2], split=" ")
  }
  }
  
  cal_df = data.frame(calibration, eye, error_max, error_avg, time_cal)
   
  sampl_freq = round(as.numeric(strsplit(tmp_file[grepl("SAMPLES\tGAZE\tLEFT\tRIGHT\tRATE",tmp_file)],split = "\t")[[1]][6],0))
  
  cal_df$error_max=as.numeric(as.character(cal_df$error_max))
  cal_df$error_avg=as.numeric(as.character(cal_df$error_avg))
 
  
  #get stim info for events file
  tmp_file_sub_all = tmp_file[grepl("FACESTART|ENDPRESENTATION",tmp_file)]
  #tmp_file_sub_all = tmp_file_sub_all[!grepl('_ue',tmp_file_sub_all)] # irrelevant here - no msg´s in the training part
  tmp_file_sub = tmp_file_sub_all[grepl("FACESTART",tmp_file_sub_all)]
  
  
  for (ii in 1:length(tmp_file_sub)){
    
    #info needs to be adjusted according to individual structure of messages!
    time = as.numeric(strsplit(strsplit(tmp_file_sub[ii], split="\t")[[1]][2], split=" ")[[1]][1])
    info_trial = as.numeric(strsplit(strsplit(tmp_file_sub[ii], split="\t")[[1]][4], split=" ")[[1]][2])
    info_blocktrial = as.numeric(strsplit(strsplit(tmp_file_sub[ii], split="\t")[[1]][3], split=" ")[[1]][2])
    info_faces = strsplit(tmp_file_sub[ii], split="\t")[[1]][6]
    index = match(tmp_file_sub[ii],tmp_file_sub_all)
    t_end = as.numeric(strsplit(strsplit(tmp_file_sub_all[index+1], split="\t")[[1]][2], split=" ")[[1]][1])
    
    if (ii == 1){
      exp_start_time = time
      
      start_time = time-exp_start_time
      time_raw = time
      duration = t_end-time
      trial = info_trial
      blocktrial = info_blocktrial
      faces = info_faces
      #target_word = info[[1]][3]
      #color = info[[1]][4]
      #mask = info[[1]][5]
      #underlining = info[[1]][6]
      #stimulus_pos_first_letter = info[[1]][7]
      
      #if(grepl("KEYPRESS",tmp_file_sub_all[index+2])){
      #  keypress = strsplit(strsplit(strsplit(tmp_file_sub_all[index+2], split="\t")[[1]][2], split=" ")[[1]][3],split="_")[[1]][1]
      #}else{
      #  keypress = "n/a"  
      #}
      
    }else{
      start_time[ii] = time-exp_start_time
      time_raw[ii] = time
      duration[ii] = t_end-time
      trial[ii] = info_trial
      blocktrial[ii] = info_blocktrial
      faces[ii] = info_faces
      #target_word[ii] = info[[1]][3]
      #color[ii] = info[[1]][4]
      #mask[ii] = info[[1]][5]
      #underlining[ii] = info[[1]][6]
      #stimulus_pos_first_letter[ii] = info[[1]][7]
      
      #if(grepl("KEYPRESS",tmp_file_sub_all[index+2])){
      #  keypress[ii] = strsplit(strsplit(strsplit(tmp_file_sub_all[index+2], split="\t")[[1]][2], split=" ")[[1]][3],split="_")[[1]][1]
      #}else{
      #  keypress[ii] = "n/a"  
      #}
    }
  }
  event_df = data.frame(start_time,duration,time_raw,trial, blocktrial, faces)
  event_df$start_time = event_df$start_time/1000
  event_df$duration = event_df$duration/1000
  #event_df$color = as.character(event_df$color)
  #event_df$color[event_df$color=="K"]="Black"
  #event_df$color[event_df$color=="E"]="Blue"
  #event_df$mask = as.character(event_df$mask)
  #event_df$mask[event_df$mask=="DEG"]="Degraded"
  #event_df$mask[event_df$mask=="LET"]="Un-degraded"
  #event_df$underlining = as.character(event_df$underlining)
  #event_df$underlining[event_df$underlining=="U"]="Underlined"
  #event_df$underlining[event_df$underlining=="N"]="Not underlined"
  
  #optionally merge with design matrix including stimulus information
  stim_info=read.csv("./final_matrix_freeviewing_task.csv", header=TRUE)
  event_df$faces_stim = stim_info$index
  event_df$faces=NULL
  
  write.table(event_df,row.names = F, file = paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_events.tsv",sep=""))
  
  #add exp time to the cal_df and export
  cal_df$time_cal = (cal_df$time-exp_start_time)/1000
  write.table(cal_df,row.names = F, file = paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_cal.tsv",sep=""))
  
  #export file with general characteristics
  cal_exp = which(cal_df$time_cal > 0)[1] - 2
 
  
  for(nr in 1:nlevels(factor(cal_df$calibration[cal_exp:nrow(cal_df)]))){
    if(nr==1){
      cal_tmp=levels(factor(cal_df$calibration[cal_exp:nrow(cal_df)]))[nr]
      calibration=cal_tmp}
    else{cal_tmp=levels(factor(cal_df$calibration[cal_exp:nrow(cal_df)]))[nr]
    calibration=paste(calibration,cal_tmp, sep=", ")}}
  
  for(nr in 1:nlevels(factor(cal_df$eye[cal_exp:nrow(cal_df)]))){
    if(nr==1){
      eye_tmp=levels(factor(cal_df$eye[cal_exp:nrow(cal_df)]))[nr]
      eye=eye_tmp}
    else{eye_tmp=levels(factor(cal_df$eye[cal_exp:nrow(cal_df)]))[nr]
    eye=paste(eye,eye_tmp, sep=", ")}}
  
  write(paste('{\n\t"SamplingFrequency": ',sampl_freq,',\n\t"StartMessage": "FACESTART",\n\t"EndMessage": "ENDPRESENTATION",\n\t"EventIdentifier": "EFIX",\n\t'
              ,'"Manifacturer": "SR-Research",\n\t"ManufacturersModelName": "EYELINK II CL v4.56 Aug 18 2010",\n\t"SoftwareVersions": "SREB2.2.61 WIN32 LID:5F0D424B Mod:2019.07.10 14:33 MESZ",\n\t'
              ,'"TaskDescription": "Free viewing of a 4x4 matrices including faces with positive, negative and neutral emotional expression",\n\t"Instructions":"Natural viewing of matrices, no special task",\n\t'
              ,'"InstitutionName": "Goethe-University of Frankfurt; Department of Psychology",\n\t"InstitutionAddress": "Theodor-W.-Adorno-Platz 6 60323 Frankfurt am Main; Germany",\n\t'
              ,'"Calibration type": "',calibration,'",\n\t"Recorded eye": "',eye,'",\n\t"Maximal calibration error (accross all calibrations excluding training)": ',max(cal_df$error_max[cal_exp:nrow(cal_df)])
              ,',\n\t"Average calibration error (mean accross all calibrations excluding training)": ', mean(cal_df$error_avg[cal_exp:nrow(cal_df)])
              ,"\n}",sep = "")
              , file = paste(indi_folder_path,"/sub-",vp,"_acq-",aq,"_task-hyperlink_eyetrack.json",sep=""))
}


