#!/usr/local/bin/rscript
library("R.matlab")
library('ROCR')
# parse input commands
args <- commandArgs(TRUE)
mat_filename <- args[1]
# Import Data
imported_mat_data <- readMat(mat_filename)
decorrArr <- imported_mat_data[1]
labelArr <- imported_mat_data[2]
# logistic regression
#myModel <- glm(labelArr ~ decorrArr, data = imported_mat_data, family= binomial)
#decorrPredict <- predict(myModel, type = 'response')
# ROC creation
#ROCDecorr <- prediction(decorrPredict, imported_mat_data$labelArr)
ROCDecorr <- prediction(imported_mat_data$decorrArr, imported_mat_data$labelArr)
ROCPerformance <- performance(ROCDecorr, 'tpr','fpr')
auc.perf = performance(ROCDecorr, measure = "auc")
# plot
png('rocPlot2.png',width=3.25,height=3.25,units="in",res=500)
plot(ROCPerformance)
aucVal <- unlist(auc.perf@y.values)
dev.off()
writeMat("ROCOutput.mat", aucVal = aucVal, ROC_fpr = unlist(ROCPerformance@x.values),ROC_tpr = unlist(ROCPerformance@y.values ), ROC_cutoff = unlist(ROCPerformance@alpha.values) )
