# randomizes participants into two groups

df = read.csv('responses.csv', header = T)
N = nrow(df)
df$no_screen_first = sample(c(
    rep(1, ceiling(N/2)), 
    rep(0, floor(N/2))
    ))
write.csv(df, 'responses.csv', row.names = F)