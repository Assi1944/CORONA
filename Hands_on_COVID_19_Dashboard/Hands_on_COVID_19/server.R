#Shiny-Server

#Input and output objects are connected in the Server function. 
#Note that, the input arguments are stored in a list-like object and each 
#input argument is identified under its unique name, for example the 
#sliderInput is named after “date”.

server <- function(input, output){
    
    
    # reading data
    # I have created an EXCEl-table and read this data
    citydaten <- read.csv("M:/CORONA/Hands_on_COVID_19_Dashboard/citydaten.csv",header =TRUE)
  
    daten <- read.csv("https://raw.githubusercontent.com/datasets/covid-19/master/data/key-countries-pivoted.csv")
 #daten1 <- read.csv("https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv")
 #browser()
    #Assign output$distPlot with renderLeaflet object
    output$distPlot <- renderLeaflet({
        
        # row index of the selected date (from input$date)
        rowindex = which(as.Date(as.character(daten$Date), 
                                 "%d.%m.%Y") ==input$date)
       
        # initialise the leaflet object
        basemap= leaflet()  %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(noWrap = TRUE)) 
        
        # assign the chart colors for each country, where those 
        # countries with more than 500,000 cases are marked 
        # as red, otherwise black
        chartcolors = rep("black",7)
        stresscountries = which(as.numeric(daten[rowindex,c(2:8)])>50000)
        chartcolors[stresscountries] = rep("red", length(stresscountries))
        
       
        
        # add chart for each country according to the number of 
        # confirmed cases to selected date 
        # and the above assigned colors
        basemap %>%
            addMinicharts(
                citydaten$long, citydaten$Lat,
                chartdata = as.numeric(daten[rowindex,c(2:8)]),
                showLabels = TRUE,
                fillColor = chartcolors,
                labelMinSize = 5,
                width = 45,
                transitionTime = 1
            ) 
        
        
    })
    
   
    
    #Assign output$Plotcountry with renderPlot object
    output$Plotcountry <- renderPlot({
        
        #the selected country 
        chosencountry = input$selectedcountry
        
        #assign actual date
        today = as.Date("2020/04/18")
        
        #size of the selected historic window
        chosenwindow = input$selectedhistoricwindow
        if (chosenwindow == "the past 10 days")
        {pastdays = 10}
        if (chosenwindow  == "the past 20 days")
        {pastdays = 20}
        
        #assign the dates of the selected historic window
        startday = today-pastdays-1
        daten$Date=as.Date(as.character(daten$Date),"%d.%m.%Y")
       # daten$Date=as.Date(as.character(daten$Date),"%Y.%m.%d")
        selecteddata = daten[(daten$Date>startday)&(daten$Date<(today+1)), 
                c("Date",chosencountry)]
        
        #assign the upperbound of the y-aches (maximum+100)
        upperboundylim = max(selecteddata[,2])+100
        
        #the case if the daily new confirmed cases are also
        #plotted
        if (input$dailynew == TRUE){
            
            plot(selecteddata$Date, selecteddata[,2], type = "b", 
                 col = "blue", xlab = "Date", 
                 ylab = "number of infected people", lwd = 3, 
                 ylim = c(0, upperboundylim))
            par(new = TRUE)
            plot(selecteddata$Date, c(0, diff(selecteddata[,2])), 
                 type = "b", col = "red", xlab = "", ylab = 
                     "", lwd = 3,ylim = c(0,upperboundylim))
            
            #add legend
            legend(selecteddata$Date[1], upperboundylim*0.95, 
                   legend=c("Daily new", "Total number"), 
                   col=c("red", "blue"), lty = c(1,1), cex=1)
        }
        
        #the case if the daily new confirmed cases are 
        #not plotted
        if (input$dailynew == FALSE){
            
            plot(selecteddata$Date, selecteddata[,2], type = "b", 
                 col = "blue", xlab = "Date", 
                 ylab = "number of infected people", lwd = 3,
                 ylim = c(0, upperboundylim))
            par(new = TRUE)
            
            #add legend
            legend(selecteddata$Date[1], upperboundylim*0.95, 
                   legend=c("Total number"), col=c("blue"), 
                   lty = c(1), cex=1)
        }
        
    })
    
}



#shinyApp(ui = ui, server = server)

