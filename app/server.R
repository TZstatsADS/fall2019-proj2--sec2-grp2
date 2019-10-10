#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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

# Define server logic required to draw a histogram
server<-function(input, output) {
    offenseColor <- colorFactor(rainbow(8), data2018$CRIME_TYPE)
    selectedData <- reactive({
        req(input$crimeType)
        req(input$month)
        data2018 %>% 
            dplyr::filter(data2018$month %in% input$month & data2018$CRIME_TYPE %in% input$crimeType
            )
    })
    # Set Data based on the input selection #        
    # render map using the leaflet fucntion #  
    output$crimeMap <- renderLeaflet({
        
        leaflet(selectedData()) %>%
            addProviderTiles("CartoDB") %>%
            setView(-73.98575,40.74856, zoom = 10)
    })
    # update map based on changed inputs #
    observe({
        leafletProxy("crimeMap", data = selectedData()) %>%
            clearMarkers() %>%
            clearControls() %>%
            addCircleMarkers(
                stroke = FALSE, fillOpacity = 0.5, radius=3, color =~offenseColor(input$crimeType),
                
                popup = ~paste("<strong>Offense:</strong>",CRIME_TYPE,
                               "<br>",
                               "<strong>Month:</strong>",month,
                               "<br>",
                               "<strong>Location:</strong>",PREM_TYP_DESC)
            )
        
        
    })
    
    
    #barplot for months
    
    weatherInput <- reactive({
        switch(input$weather,
               "Temperature"=month_change$Temperature,
               "Precipitation"=month_change$Precipitation,
               "Wind"=month_change$Wind)
    })
    
    crime_typeInput <- reactive({
        switch(input$crime_type,
               "drug_alcho_gamble"=month_change$drug_alcho_gamble,
               "fraud"=month_change$fraud,             
               "harass"=month_change$harass,            
               "kill"=month_change$kill,              
               "others"=month_change$others,           
               "robbery_crime"=month_change$robbery_crime,     
               "theft"=month_change$theft,             
               "traffic"=month_change$traffic,           
               "all"=month_change$all)
    })
    
    output$barplot<- renderPlot({
        ggplot(month_change) + 
            geom_bar(aes(Month, crime_typeInput(),fill="Number of Crimes"), stat = "identity") + 
            geom_point(aes(Month, weatherInput()*.8*min(crime_typeInput()/weatherInput())), colour="black") + 
            geom_line(aes(Month, weatherInput()*.8*min(crime_typeInput()/weatherInput()), group=1, colour="Weather")) + 
            scale_colour_manual("", values=c("Number of Total Crimes"="grey", "Weather"="black")) +  
            scale_fill_manual("",values="grey")+
            scale_y_continuous(sec.axis = sec_axis(~./.8/min(crime_typeInput()/weatherInput()))) +
            labs(title = paste(input$weather, input$crime_type, sep=" & "), y="" ) +
            theme(legend.justification=c(1,1), legend.position=c(1,1), panel.grid.major =element_blank(), 
                  panel.grid.minor = element_blank(), panel.background = element_blank())
    })
}