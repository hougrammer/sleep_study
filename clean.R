# Script to clean consolidated data
library(data.table)
library(magrittr)

df = data.table(read.csv('data/consolidated.csv'))
resp_final = data.table(read.csv('data/EMAIL_Responses-1.csv'))
resp_init = data.table(read.csv('responses_cleaned.csv'))

df = df %>%
    # get emails
    .[, email := sapply(id, function(x) resp_final[ID == x, Email.Address])] %>%
    
    # # get names
    # .[, name := sapply(email, function(x) resp_init[Email.Address == x, Full.Name])] %>% 
    
    # drop 'S' in id and change to numeric
    .[, id := sapply(id, function(x) as.numeric(substr(as.character(x), 2, 4)))] %>%
    
    # convert time to hours
    .[, hours := sapply(time, function(x) {
        s = unlist(strsplit(as.character(x), ':'))
        as.numeric(s[[1]]) + as.numeric(s[[2]])/60
    })] %>%
    
    # drop hours less than 1
    .[hours > 1, ]

# join with cleaned initial responses
df = df[resp_init, on = 'email']
