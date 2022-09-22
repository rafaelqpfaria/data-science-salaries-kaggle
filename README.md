
# data-science-salaries-kaggle

Using the dataset Data Science Fields Categorization,
found at https://www.kaggle.com/datasets/whenamancodes/data-science-fields-salary-categorization.
It was developed a machine learning model to predict future salaries.

This dataset contains information over 600 Data Science Workers,
such as their designated position, the experience they have at roles,
where the company and the person is located and many others.

Based on all of those variables I built a model using xgboost engine
to predict future salaries on similar roles. 
The model performed with a R-Squared Error of 47.7%. 

There is also an app made with Shiny available
to calculate those predictions using the file app.R 
which you can test to use the model for yourself.

Here is a picture on how the app looks like.

![datasciencepred](https://user-images.githubusercontent.com/65754601/191826838-d26b366d-6b78-4c6a-ad1c-ece2a0e601fe.png)
