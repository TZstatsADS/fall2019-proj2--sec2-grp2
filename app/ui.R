#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



library(shiny)
library(dplyr)
library(stringr)
library(readr)
library(leaflet)
library(tidyr)
library(rsconnect)
library(ggplot2)
library(shinyWidgets)
library(shinythemes)


load('data2018.RData')
monthChoices <- list("Jan", "Feb", "Mar" ,
                     "Apr" , "May", "Jun" ,
                     "Jul" , "Aug", "Sep" ,
                     "Oct" , "Nov" , "Dec" )
#summary_ofens <- data2018 %>% group_by(data2018$OFNS_DESC) %>% summarize(count=n())
#ofens_des <- summary_ofens$`data2018$OFNS_DESC`
summary_ofens <- data2018 %>% group_by(data2018$CRIME_TYPE) %>% summarize(count=n())
ofens_des <- summary_ofens$`data2018$CRIME_TYPE`
weather<-list("Temperature","Precipitation","Wind")
#tab2
month_change <- as.data.frame.array(table(data2018$month, data2018$CRIME_TYPE))
row.names(month_change) <- c(4,8,12,2,1,7,6,3,5,11,10,9)
month_change$all <- as.array(table(data2018$month))
month_change$id<-c(4,8,12,2,1,7,6,3,5,11,10,9)
month_change<-month_change[order(month_change$id),]
month_change$Temperature <- c(21.8, 31.5, 32.1, 39.5,
                              62.4, 65.5, 72.7, 70.6,
                              64.0, 49.1, 34.9, 30.0)
month_change$Precipitation<-c(1.90, 2.71, 7.23, 3.35,
                              2.61, 2.05, 3.80, 3.71,
                              4.38, 5.15, 6.28, 3.61)
month_change$Wind <- c(19.2, 18.4, 17.3, 22.4,
                       19.6, 17.7, 17.7, 15.4,
                       15.6, 19.6, 21.2, 19.3)
month_change$Month <- factor(c("Jan", "Feb", "Mar", "Apr", 
                               "May", "Jun", "Jul", "Aug", 
                               "Sep", "Oct", "Nov", "Dec"),
                             levels = c("Jan", "Feb", "Mar", "Apr", 
                                        "May", "Jun", "Jul", "Aug", 
                                        "Sep", "Oct", "Nov", "Dec"))

# Define UI for application that draws a histogram
ui<-tagList(
    navbarPage(p(class="h","Crime"),id = "inTabset", theme = shinythemes::shinytheme("cyborg"),
               tabPanel("Introduction",
                        setBackgroundImage("https://sherlock.ambient-mixer.com/images_template/7/d/3/7d3c78599fcd0e2d970c2395ae7d5562_full.jpg"),
                        mainPanel(
                            h1("\"Since the cab was there after the",span("rain", style = "color:red"), "began,",align="center", style = "color:white"),
                            h2("and was not there at any time during the morning—",align="center",style = "color:white"),
                            h3("I have Gregson’s word for that—",align="center",style = "color:white"),
                            h4("it follows that it must have been there during the night",align="center",style = "color:white"),
                            h5(" and, therefore,",align="center",style = "color:white"),
                            h6("that it brought those two individuals to the house.\"", align="center",style = "color:white"),
                            h6("              ----Arthur Conan Doyle",align="right")
                        )
               ),
               
               tabPanel("CrimeMap",
                        titlePanel(h3("Mapping New York crime incidences for 2018")),
                        
                        #tags$h1("Mapping New York crime incidences for 2018"),
                        
                        sidebarPanel(
                            checkboxGroupInput("month", "Choose month:",
                                               monthChoices,selected = NULL),
                            
                            selectInput("crimeType","Select a type of crime",
                                        choices=ofens_des,
                                        selected=ofens_des[1])
                        ),
                        mainPanel(
                            leafletOutput("crimeMap",width="100%",height=650))
                        
                        
               ),
               
               tabPanel("Crimes VS Weather",
                        titlePanel(h3("Number of crimes in different months and monthly average weather condition for 2018")),
                        sidebarPanel(
                            radioButtons("weather","Temperature/Precipitation/Wind:",choices = weather,selected = weather[1]
                            ),
                            
                            selectInput("crime_type","Select a type of crime",
                                        choices=c(ofens_des,"all"),
                                        selected=c(ofens_des,"all")[1])),
                        mainPanel(plotOutput("barplot",height = 500))
               ),
               
               tabPanel("Contact",fluidPage(
                   sidebarLayout(
                       sidebarPanel(h3("Contact Information")),
                       mainPanel(
                           
                           
                           hr(),
                           h4(("If you are interested in our project, you can contact us.")),
                           hr(),
                           h6(("Abrams, Zack")),
                           h6((" zda2105@columbia.edu")),
                           h6(("Gao, Xin")),
                           h6(("xg2298@columbia.edu")),
                           h6(("Gao, Zun ")),
                           h6((" zg2307@columbia.edu")),
                           h6(("Meng, Yang")),
                           h6((" ym2696@columbia.edu")),
                           h6(("Ruan, Qiuyu")),
                           h6(("qr2127@columbia.edu"))))
               ))))