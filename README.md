# SocialiseVRR
Code for analysing feasibility study of the Socialise app

Overview: To investigate the feasibility of collecting smartphone sensor data for mental health research, we tested the Socialise app that was developed at the Black Dog Institute in a group of people with a lived experience of mental health challenges (n=32). Bluetooth, GPS and battery status data were collected at regular intervals (3, 4, 5 or 8 minutes) for 4 weeks. In addition, survey data was collected using the app to investigate the views of participants on user experience and the acceptability of passive data collection for mental health research. No mental health data was collected as part of the feasibility study.

Data availability: The data used in this study is available at Zenodo: http://doi.org/10.5281/zenodo.1238226. One participant did not consent to have their data made publicly available. We did not share GPS data as this would allow re-identification of participants. 

Code: This repository contains the Matlab script to analyse the data and generate the results reported in: https://dx.doi.org/10.2196%2F10131. The following scripts are provided:

dataCompleteness.m: Computes the number of Bluetooth data points that were recorded for each participant and compares it to the number of scheduled scans. Scanning rate is plotted as percentage of scheduled scans.

analyseBluetooth.m: Analyses the pattern of devices detected using Bluetooth following the procedure described in Do TMT, Gatica-Perez D. Human interaction discovery in smartphone proximity networks. Pers Ubiquit Comput. 2013 Mar;17(3):413-31. Plots the number of Bluetooth devices that were detected as function of participants (panel A) or time of day (panel B).

analyseGPS.m: Estimates clusters and circadian movement from GPS data following the procedures described in Saeb S, Zhang M, Karr CJ, Schueller SM, Corden ME, Kording KP, et al. Mobile phone sensor correlates of depressive symptom severity in daily-life behavior: An exploratory study. Journal of Medical Internet Research. 2015 Jul 15;17(7):e175. Plots the GPS location of all participants on the map, the extracted clusters for a representative participant and the circadian movement for all participants during each of the four weeks of the study.

analyseBattery.m: Uses robust linear regression to estimate the average change in battery life across scanning rates. Scanning rates were varied across different weeks. For each scanning rate, select data points were phone was discharging and the actual inter-scan interval was close to the intended scanning rate. Plots the battery consumption for the four different scanning rates (every 3, 4, 5 or 8 minutes) for individual participants and the estimated regression line across participants.

analyseBatteryRatings.m: Plots the responses of participants indicating how much they thought the app impacted the battery life of their smartphone.

function plotEthicsResults: Plots the responses of participants to questions on their views about the acceptability of passive data collection for mental health research.
