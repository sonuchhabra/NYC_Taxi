# NYC_Taxi
Taxi service is one of the cornerstones of how NYC operates, and to ensure its continued survival it is imperative that the industry break down the data it collects to improve service and optimize costs. One of the most impactful analysis is the prediction of trip duration.
The data points captured by the taxi company are vendor, date, pickup and drop-off locations, store flag and passenger count. Our first step was to conduct exploratory data analysis and data cleaning.

Next, we derived multiple variables from the existing data to compliment the model, such as pickup day, pickup time, day of the week, weekend/weekday, hour of the day, city quadrant for pickup and drop-off, distance, holiday and holiday week. 
After developing the new variables from existing data, we proceeded to read and clean the data. We identified outliers and incorrect data point that consisted in less than 1% of the total data and imputed the resulting inconsistencies.

Once our data was complete and clean we proceeded to run our variable selection methods. For linear models we ran a forward and backward selection for an R2 stopping rule, and for a p-value stopping rule. Additionally, we ran a mixed selection for p-value and a forward selection for Max K-fold R2stopping rule. For neural networks, we attempted a PCA variable reduction. Finally, we let the trees do their automatic variable selection.

Next, we ran our models, making trip duration the dependent variable and all the combinations we extracted from variable selection as our independent variables. Taking into consideration all possible combinations of useful variables and model types, we concluded a simple decision tree would perform best in predicting trip duration.

To assess our model, we used cross validation with 10 folds. Our most successful model resulted in test R2=.76, RMSE=318.499 seconds, and a cross validation R2= .7692
Since our winning model is a decision tree, the model consists of a series of conditions that will end up with a prediction based on the branches. We can objectively say that distance, pickup time and pickup day are the most significant variables when predicting the trip duration of a taxi ride.
