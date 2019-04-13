# Script to clean consolidated data
library(data.table)
library(magrittr)

df = data.table(read.csv('data/consolidated.csv'))
resp_final = data.table(read.csv('data/EMAIL_Responses-1.csv'))
resp_init = data.table(read.csv('responses_cleaned.csv'))

df = df %>%
    # get emails
    .[, email := sapply(id, function(x) resp_final[ID == x, Email.Address])] %>%
    
    # drop 'S' in id
    .[, id := sapply(id, function(x) substr(as.character(x), 2, 4))] %>%
    
    # convert time to hours
    .[, hours := sapply(time, function(x) {
        s = unlist(strsplit(as.character(x), ':'))
        as.numeric(s[[1]]) + as.numeric(s[[2]])/60
    })] %>%
    
    # drop hours less than 1
    .[hours > 1, ] %>%
    
    # convert treat to -1, 0, 1 (-1 feels more conventional)
    .[treat == 2, treat := -1]

# join with cleaned initial responses
df = df[resp_init, on = 'email']

# remove NAs from people who did not particpate
df = df[!is.na(id), ]

write.csv(df, 'data/cleaned.csv', row.names = F)