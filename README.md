# Productive_Analysis_based_on_employee_web_usage

## Objective
  Determining the user productive performance based on the Employee Browser data.

## Assumption

1. Organization having the wide range of branch and more than lakhs people.
2. All people are having the access to the all websites.
3. Web history has been captured by the 3rd Party software and given input to the Flume agent. 
4. Flume agent is not designing in this phase and input files are stored in static part in hadoop system

## Hadoop & Report

1. Internet Log & Timesheet data are gernerated once, ,  Flume Seek  will get the logs and place for pig
2. Pig will Convert unstructured URL to required fields
3. Hive will transform  to reporting required data format

## ML Learning

As part of this phase, Generating a model to dicide weather content is technical or non technicall

## Required Libararies 

``` 
require(ggplot2)
require(dplyr)
require(e1071)
require(RTextTools)
require(tm) # Text mining: Corpus and Document Term Matrix
require(class) # KNN model
require(SnowballC) # Stemming words
require(ElemStatLearn)
``` 

## License

[MIT](https://choosealicense.com/licenses/mit/)
