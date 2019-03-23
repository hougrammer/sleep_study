# randomizes participants into two groups

df = read.csv('responses.csv', header = T)
N = nrow(df)
df$screen_time = sample(c(
    rep(1, ceiling(N/2)), 
    rep(0, floor(N/2))
    ))
write.csv(df, 'mar23_29_responses.csv', row.names = F)
