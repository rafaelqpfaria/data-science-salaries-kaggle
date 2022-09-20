library(tidyverse)
library(tidymodels)
library(janitor)



dt_science <- read.csv("Data_Science_Fields_Salary_Categorization.csv")

table(is.na(dt_science))

dt_science %>% 
  str()

dt_science$Is_Living_Away <- dt_science$Company_Location == dt_science$Employee_Location

dt_science$Salary_In_Rupees <- gsub(",","",dt_science$Salary_In_Rupees)
dt_science$Salary_In_Rupees <- as.numeric(dt_science$Salary_In_Rupees)



dt_science <-
  dt_science %>% 
  mutate(Salary_In_Dollars = Salary_In_Rupees/80) %>% 
  select(-X,-Salary_In_Rupees)


dt_science %>% 
  tabyl(Designation) %>% 
  arrange(desc(n))
  

dt_science %>% 
  tabyl(Employee_Location) %>% 
  arrange(desc(n))

dt_science %>% 
  tabyl(Company_Location) %>% 
  arrange(desc(n))
  


## Especification -------------------------------------------------------

rec_dt_science <-
  recipe(Salary_In_Dollars ~., data = dt_science) %>% 
    #step_other(Designation, threshold = 0.018, other = "other des") %>% 
    #step_other(Employee_Location, threshold = 0.01 , other = " other Eloc") %>% 
    #step_other(Company_Location, threshold = 0.01 , other = "other Cloc") %>% 
    step_mutate(Working_Year, fn = as.factor(Working_Year)) %>%
    step_mutate(Designation,fn = as.factor(Designation)) %>%
    step_mutate(Experience,fn = as.factor(Experience)) %>%
    step_mutate(Employment_Status,fn = as.factor(Employment_Status)) %>%
    step_mutate(Employee_Location,fn = as.factor(Employee_Location)) %>%
    step_mutate(Company_Location,fn = as.factor(Company_Location)) %>%
    step_mutate(Company_Size,fn = as.factor(Company_Size)) %>%
    step_mutate(Is_Living_Away,fn = as.factor(Is_Living_Away))

    
  
## Preparing the data -----------------------------------------------------

prep_dt_science <- prep(rec_dt_science, retain = TRUE)

## Application ------------------------------------------------------------

split_dt_science <- bake(prep_dt_science, new_data = NULL)


# Data Spliting -----------------------------------------------------------

split_data <- initial_split(split_dt_science, prop = 3/4, strata = Salary_In_Dollars)

train_dt_science <- training(split_data)
test_dt_science <- testing(split_data)

set.seed(123)

resample_dt_science <- bootstraps(train_dt_science, strata = Salary_In_Dollars)


# Modeling ----------------------------------------------------------------

mdl_xgboost_dt_science <- 
  boost_tree() %>% 
  set_mode("regression") %>% 
  set_engine("xgboost") %>% 
  set_args(trees = 300,
           tree_depth = tune(),
           min_n = tune(),
           loss_reduction = tune(),
           sample_size = tune(),
           mtry = tune(),
           learn_rate = tune())


# Workflow ----------------------------------------------------------------

wkfl_dt_science <-
  workflow() %>% 
  add_recipe(rec_dt_science) %>% 
  add_model(mdl_xgboost_dt_science , formula = Salary_In_Dollars ~.)

wkfl_dt_science

# Tuning ------------------------------------------------------------------

grid_xgboost_dt_science <- 
  grid_latin_hypercube(
    tree_depth(),
    min_n(),
    loss_reduction(),
    sample_size = sample_prop(),
    finalize(mtry(),train_dt_science),
    learn_rate(),
    size = 10
    )

tune_xgboost_dt_science <-
  tune_grid(object = wkfl_dt_science,
            resamples = resample_dt_science,
            grid = grid_xgboost_dt_science,
            control = control_grid(save_pred = TRUE))
  
  
  tune_xgboost_dt_science %>% show_best(metric = "rmse")
    #collect_metrics()

?collect_metrics
  
best_grid_dt_science <- tune_xgboost_dt_science %>% select_best(metric = "rmse")
best_grid_dt_science


# Predictions -------------------------------------------------------------

final_wkfl_dt_science <-
  finalize_workflow(wkfl_dt_science,best_grid_dt_science)

final_wkfl_dt_science

final_pred_xgb_dt_science <-
  last_fit(final_wkfl_dt_science, split = split_data)


final_pred_xgb_dt_science %>% collect_metrics()

final_mdl_fit_dt_science <-
  final_wkfl_dt_science %>% 
  fit(data = split_dt_science)


dt_science_sallary <-
  predict(final_mdl_fit_dt_science,
          new_data = test_dt_science)

dt_science_sallary_compare <- cbind(dt_science_sallary,test_dt_science$Salary_In_Dollars)
  
saveRDS(final_mdl_fit_dt_science, "C:\\Users\\usuario\\Documents\\R\\Data Science Salaries\\data-science-salaries-kaggle\\model-dt-science.rds")
