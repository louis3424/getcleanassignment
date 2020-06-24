library(dplyr)

# read feature names

feature_info <- read.table('UCI_HAR_Dataset/features.txt', 
                          sep="", 
                          strip.white=TRUE, 
                          header=FALSE, 
                          quote="\"", 
                          col.names = c('index', 'feature_names'),
                          row.names = 'index')

# read activity mappings

activity_mappings <- read.table('UCI_HAR_Dataset/activity_labels.txt', 
                          sep="", 
                          strip.white=TRUE, 
                          header=FALSE, 
                          quote="\"", 
                          col.names = c('index', 'activity_name'),
                          row.names = 'index')

# reformat feature names so they can be used as dataframe colnames
feature_info$feature_names <- gsub("\\(\\)", "", feature_info$feature_names)
feature_info$feature_names <- gsub("\\,", ".", feature_info$feature_names)
feature_info$feature_names <- gsub("\\(", "_from_", feature_info$feature_names)
feature_info$feature_names <- gsub("\\)", "", feature_info$feature_names)


## Read data

# read subjects

subject_test <- read.table('UCI_HAR_Dataset/test/subject_test.txt', 
                          sep="", 
                          strip.white=TRUE, 
                          header=FALSE, 
                          quote="\"",
                          col.names='subject')

subject_train <- read.table('UCI_HAR_Dataset/train/subject_train.txt', 
                          sep="", 
                          strip.white=TRUE, 
                          header=FALSE, 
                          quote="\"",
                          col.names='subject')


# read labels
y_test <- read.table('UCI_HAR_Dataset/test/y_test.txt', 
                    sep="", 
                    strip.white=TRUE, 
                    header=FALSE, 
                    quote="\"",
                    col.names='activity')


y_train <- read.table('UCI_HAR_Dataset/train/y_train.txt', 
                     sep="", 
                     strip.white=TRUE, 
                     header=FALSE, 
                     quote="\"",
                     col.names='activity')

# read features, add activity and subject as new columns, also add new column that contains information whether sample comes 
# crom training or test set
x_train <- read.table('UCI_HAR_Dataset/train/X_train.txt', 
                     sep="", 
                     strip.white=TRUE, 
                     header=FALSE, 
                     quote="\"", 
                     col.names = feature_info$feature_names)
x_train$activity <- y_train$activity
x_train$subject <- subject_train$subject
x_train$train_sample <- TRUE

x_test <- read.table('UCI_HAR_Dataset/test/X_test.txt', 
                    sep="", 
                    strip.white=TRUE, 
                    header=FALSE, 
                    quote="\"",
                    col.names = feature_info$feature_names)
x_test$activity <- y_test$activity
x_test$subject <- subject_test$subject
x_test$train_sample <- FALSE

# Merge tables(concatenate)

merged_dataset <- rbind(x_train, x_test)

# Select only mean and std measures

mean_std_dataset <- select(merged_dataset, contains(c('.mean','.std', 'activity','subject')))

# Add descriptive activity names

mean_std_dataset <- mutate(mean_std_dataset, activity = activity_mappings[activity,1])

# Summarize

mean_by_sub_activity_data <- mean_std_dataset %>% 
  group_by(subject, activity) %>% 
  summarise_at(vars(-group_cols()), mean)

write.table(mean_by_sub_activity_data, "tidy.txt", sep="\t", row.name=FALSE)