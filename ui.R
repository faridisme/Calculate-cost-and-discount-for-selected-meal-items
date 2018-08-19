library(shiny)

dfml <- read.csv("Masterlist.csv")
items <- as.character(unique(dfml$Item))
items <- c("Nil",items[order(items)])


# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Calculate cost of meal items"),

  tabsetPanel(
    tabPanel("Background",
             h3("AIM OF SHINY APPLICATION"),
             h4("In this cafe, customer picks up items first and the receipt comprising charge, discount and final price is calculated at checkout counter"),
             h4("Item code is input to the app for calculation of discount if eligible"),
             h3("DESCRIPTION AND INSTRUCTIONS FOR USE"),
             h4("1. The left-most panel lists the different menu items"),
             h4("2. Once menu items are selected, scan items by entering the item code into the scan forms in the middle panel."),
             h4("- Item codes within a scan form should be delimited by comma ',' (or semicolon ';' or plus symbol '+')"),
             h4("- For accurate subsidy calculation, scan set items (e.g. Nasi Lemak) based on meal sets, i.e. same Nasi Lemak set within same scan and different Nasi Lemak sets in different scans"),
             h4("3. Receipt and breakdown is updated in the right-most column"),
             h4("For more details see https://github.com/faridisme/Calculate-cost-and-discount-for-selected-meal-items. Thank you for your feedback")
             ),
    tabPanel("Application",
             # Sidebar with a slider input for number of bins
             splitLayout(cellWidths=c("25%","20%","55%"),
                         tagList(
                           h3("ITEMS MENU"),
                           tableOutput("menuout")
                         ),
                         tagList(
                           h3("CHECKOUT COUNTER"),
                           numericInput("sublevel","Enter eligible discount level:",50,0,100,10),
                           h3("Scan meal item codes:"),
                           h5("To enjoy intended discounts for Nasi Lemak, "),
                           h5("ensure Nasi Lemak items are grouped"),
                           h5("based on meal sets e.g. N1,N4,N7"),
                           
                           textInput("item1", "Scan 1:", ""),
                           textInput("item2", "Scan 2:", ""),
                           textInput("item3", "Scan 3:", ""),
                           textInput("item4", "Scan 4:", ""),
                           textInput("item5", "Scan 5:", ""),
                           textInput("item6", "Scan 6:", ""),
                           textInput("item7", "Scan 7:", ""),
                           textInput("item8", "Scan 8:", ""),
                           textInput("item9", "Scan 9:", ""),
                           textInput("item10", "Scan 10:", "")
                         ),
                         # Show a plot of the generated distribution
                         tagList(
                           h3("RECEIPT"),
                           htmlOutput("textout"),
                           h3("Breakdown:"),
                           tableOutput("tableout"),
                           h4("Thank you for shopping with us. Enjoy your meal!")
                         )
             )
             ),
    tabPanel("Food eligible for discounts",
      h4("As there can be a wide variation in costs for the same food type, only items below the reasonable cost for that food type is eligible for discounts. For example, Mee Siam comes in Economy ($3), Standard ($4) and Premium ($5). Only Economy and Standard is eligible for discount."),
      tableOutput("reasonablecostout")
    )
  )
  
  
))
