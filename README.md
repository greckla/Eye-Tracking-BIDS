
# BIDS and asc Preprocessing in EyeTracking

## Eyetracking BIDS Data Preprocessing
## Eyelink data - Preprocessing asc files

Task: Freeviewing task with happy/sad/neutral faces

Question/ Comments:
- Kalibrierung in BIDS: bezieht sich auf die Kalibrierungen während der experimentalen Session 
  (Durchschnitt von allen berechnet) -- ich denke, es ist besser als die erste Kalibrierung zu berichten,
  die nur für die Übung durchgeführt wird
- Fixationen, die nicht komplett in dem Trial sind (sondern auch kurz davor oder kurz danach): Dauer verkürzt,
  sodass nur die fixation duration berücksichtigt wird, wo die faces auch präsentiert wurden
- matchen mit den stimulus characteristics ist sehr langsam, da die strings gesplittet und zugeordnet werden        müssen. Andere Idee?
