library(shiny)

dfml <- read.csv("Masterlist.csv")
items <- as.character(unique(dfml$Item))
items <- c("Nil",items[order(items)])


# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Calculate cost of meal items"),

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
))
