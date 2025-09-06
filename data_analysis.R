library(RSQLite)
library(dplyr)

sqlite_file1 <- "...political_opinion.sqlite"
sqlite_file2 <- "...weather_event_damages.sqlite"

conn1 <- dbConnect(SQLite(), sqlite_file1)
conn2 <- dbConnect(SQLite(), sqlite_file2)

political_opinion <- tbl(conn1, "political_opinion") %>% collect()
weather_event_damages <- tbl(conn2, "weather_event_damages")

grouped_table <- weather_event_damages %>%
  group_by(STATE) %>%
  summarize(grouped_total_casualties = sum(TOTAL_CASUALTIES, na.rm = TRUE)) %>%
  collect()

joined_table <- grouped_table %>%
  inner_join(political_opinion, by = c("STATE" = "GeoName"))
joined_data <- collect(joined_table)

correlation_result <- cor(joined_data$AverageOpinionTrend, joined_data$grouped_total_casualties, use = "complete.obs")

x_min <- 0
x_max <- max(joined_table$AverageOpinionTrend, na.rm = TRUE)
y_min <- min(joined_table$grouped_total_casualties, na.rm = TRUE)
y_max <- max(joined_table$grouped_total_casualties, na.rm = TRUE)


plot(
  joined_table$AverageOpinionTrend,
  joined_table$grouped_total_casualties,
  main = "Distribution of Climate Action Support and Weather Casualties Across States",
  xlab = "Avg. Support for Climate Action (% per capita) per state",
  ylab = "Total Casualties per State",
  pch = 19,
  col = "blue",
  xlim = c(x_min, x_max),
  ylim = c(y_min, y_max)
)

legend("topleft", legend = paste("Correlation:", round(correlation_result, 2)), bty = "n")


plot(
  joined_table$AverageOpinionTrend,
  joined_table$grouped_total_casualties,
  main = "No Observable Link Between Opinion Trend and Casualties",
  xlab = "Avg. Support for Climate Action (% per capita) per state",
  ylab = "Total Casualties",
  pch = 19,
  col = "blue",
)

model <- lm(grouped_total_casualties ~ AverageOpinionTrend, data = joined_table)
abline(model, col = "red", lwd = 2)

print(paste("The correlation between var1 and var2 is:", correlation_result))

dbDisconnect(conn1)
dbDisconnect(conn2)
