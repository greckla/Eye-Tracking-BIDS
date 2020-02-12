
# BIDS Eyelink v1.0

Task: Freeviewing task with happy/sad/neutral faces

implemented based on proposal https://docs.google.com/document/d/1eggzTCzSHG3AEKhtnEDbcdk-2avXN6I94X8aUPEBVsw/edit#

- the converter is implemented for data from Eyelink eyetrackers; for other data, adjustions will be needed
- please, fill the read out file (readout_file.txt) with all relevent information which will be used mainly for the json files.
-- do not use ':' in yours entries as this is a separator for the dataframe
- you can add discriptive data of your dataset which will be matched with the *_participant.tsv file
- please adjust the part of your code where you add specific variables to the event.tsv file. You can also use an extern file to add important variables.