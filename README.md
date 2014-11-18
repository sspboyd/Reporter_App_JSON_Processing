Reporter App JSON Processing
============================

Parsing Reporter App's JSON exported data in Processing

This quick sketch illustrates the basics of loading a JSON file exported from Report App (@ReporterApp) into Processing. I've supplied a small demo file to use here. 

This sketch shows you how to parse "Yes/No" type questions and count the number of responses for each answer. I've included a small amount of error checking based on the kinds of issues I've run across in using the JSON exported data.

There is a more fulsome implementation of this code which uses the date/time of each answer to create a histogram 
showing the frequency of times you've answered yes or no to a question over the course of a 24hr period. The code
is online here:
https://github.com/sspboyd/Reporter_App_Histogram

Stephen Boyd, 2014

https://twitter.com/sspboyd | http://sspboyd.ca
