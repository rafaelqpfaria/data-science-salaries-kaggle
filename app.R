## app.R ##

# libraries ---------------------------------------------------------------


library(shiny)
library(shinydashboard)
library(tidyverse)
library(tidymodels)


# model -------------------------------------------------------------------

final_mdl_dt_science <- readRDS("C:/Users/rafae/Documents/R/Data Science Salaries/data-science-salaries-kaggle/model-dt-science.rds")


# UI ----------------------------------------------------------------------


ui <- dashboardPage(
  dashboardHeader(title = "Data Scientist Projected Salary"),
  dashboardSidebar(
    menuItem("Prediction", icon = icon("th"), tabName = "Prediction",
             badgeLabel = "new", badgeColor = "green")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Prediction",
              fluidRow(
                valueBoxOutput("pred_sallary", width = 6)
              ),
              fluidRow(
                
              
              box(status = "primary",
                  selectInput("desig",label = "Designation",
                              choices = c("Data Scientist",
                                          "Data Engineer",
                                          "Data Analyst",
                                          "Machine Learning Engineer",
                                          "Research Scientist",
                                          "Data Science Manager",
                                          "Data Architect",
                                          "Big Data Engineer"))),
              box(status = "primary",
                  selectInput("emp_loc",label = "Employee Location",
                              choices = c("US",
                                          "GB",
                                          "IN",
                                          "CA",
                                          "DE",
                                          "FR",
                                          "ES",
                                          "GR",
                                          "JP",
                                          "BR"))),
              box(status = "primary",
                  selectInput("comp_loc",label = "Company Location",
                              choices = c("US",
                                          "GB",
                                          "IN",
                                          "CA",
                                          "DE",
                                          "FR",
                                          "ES",
                                          "GR",
                                          "JP",
                                          "BR"))),
              box(status = "success",
                selectInput("exp",label = "Experience",
                              choices = c("EN",
                                          "MI",
                                          "SE",
                                          "EX"))),
              box(status = "info",
                  selectInput("remote",label = "Remote Work",
                              choices = c(0,
                                          50,
                                          100))),
              box(status = "warning",
                selectInput("size",label = "Company Size",
                              choices = c("S",
                                          "M",
                                          "L")))
              )       
      )
    )
  )
)

server <- function(input, output) { 
    output$pred_sallary <- renderValueBox({
      pred_dt_sallary <- predict(final_mdl_dt_science , new_data = tibble(
        "Working_Year" = 2022,
        "Designation" = input$desig,
        "Experience" = input$exp,
        "Employment_Status" = "FT",
        "Employee_Location" = input$emp_loc,
        "Company_Location" = input$comp_loc,
        "Company_Size" = input$size,
        "Remote_Working_Ratio" = as.integer(input$remote),
        "Is_Living_Away" = FALSE
      ))
      
      valueBox(value = paste0("$", format(round(pred_dt_sallary[[1]], 2), nsmall = 2)),
                subtitle = paste0("Your Sallary would be"),
                color = "green")
    })
  }

shinyApp(ui, server)