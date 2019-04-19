# Script to clean consolidated data
library(data.table)
library(magrittr)

df = data.table(read.csv('data/consolidated.csv', stringsAsFactors = F))
resp_final = data.table(read.csv('data/EMAIL_Responses-1.csv'))
resp_init = data.table(read.csv('responses_cleaned.csv'))

df = df %>%
    # get emails
    .[, email := sapply(id, function(x) resp_final[ID == x, Email.Address])] %>%
    
    # indicator for whether subject received screen time first 
    .[, screen_first := sapply(id, function(x) resp_final[ID == x, Week1...screen_time])] %>%
    
    # drop 'S' in id
    .[, id := sapply(id, function(x) substr(as.character(x), 2, 4))] %>%
    
    # convert times to hours
    .[, hours := sapply(time, function(x) {
        s = unlist(strsplit(as.character(x), ':'))
        as.numeric(s[[1]]) + as.numeric(s[[2]])/60
    })] %>%
    
    # convert bed and rise times to hours since midnight
    .[, bed_time := sapply(start, function(x) {
        s1 = unlist(strsplit(x, ' '))[2]
        if (is.na(s1)) return(NA)
        s2 = unlist(strsplit(s1, ':'))
        
        h = as.numeric(s2[[1]])
        if (h > 12) h = h - 24
        m = as.numeric(s2[[2]])
        h*60 + m
    })] %>%
    .[, rise_time := sapply(end, function(x) {
        s1 = unlist(strsplit(x, ' '))[2]
        if (is.na(s1)) return(NA)
        s2 = unlist(strsplit(s1, ':'))
        as.numeric(s2[[1]])*60 + as.numeric(s2[[2]])
    })] %>%
    
    # convert start and end to dates
    # need to do this because some lines have times and some don't
    # by the way, for 
    .[, start_date := as.Date(
        sapply(start, function(x) unlist(strsplit(as.character(x), ' '))[1]),
        format = '%m/%d/%Y'
    )] %>%
    .[, end_date := as.Date(
        sapply(end, function(x) unlist(strsplit(as.character(x), ' '))[1]),
        format = '%m/%d/%Y'
    )] %>%
    
    # drop hours less than 1
    .[hours > 1, ] %>%
    
    # convert treat to -1, 0, 1 (-1 feels more conventional)
    .[treat == 2, treat := -1]

# join with cleaned initial responses
df = df[resp_init, on = 'email']

# write out csv with all subjects (even those who did not participate)
write.csv(df, 'data/all_subjects.csv', row.names = F)

# remove NAs from people who did not particpate
df = df[!is.na(id), ]

# write out cleaned csv
write.csv(df, 'data/cleaned.csv', row.names = F)