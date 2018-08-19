#
# Masterlist.csv is uploaded to identify the food or ingrdient used and its price.
# Foodgroupings.csv is uploaded to specify the reasonable cost cut-off for each food.
#
#    http://shiny.rstudio.com/
#

dfml <- read.csv("Masterlist.csv", stringsAsFactors = FALSE)
dffg <- read.csv("Foodgroupings.csv", stringsAsFactors = FALSE)

#Expand combinations or part there-of;
genNewRow <- function(x){
  y<-dim(x)[1]
  if(grepl(", ",x[y, c("Ingredient")])){
    #t <- list(); #initialist t as a list;
    t<- strsplit(x[y, c("Ingredient")],", ");
    t <- t[[1]][order(t[[1]])]# Re-arrange ingredients in alphabetical order;
    for (i in 1:length(t)){
      combi <- combn(t,i);
      for (j in 1:dim(combi)[2]){
        newcombi <- paste(combi[order(combi[,j]),j],collapse=", ")
        if(exists("savecombi")){
          savecombi <- c(savecombi, newcombi)
        } else { savecombi <- newcombi
        }
      }
    }
    newrow<- data.frame(Food=x[y,c("Food")],
                        Ingredient=savecombi,
                        Reasonable.Cost.cut.off=x[y,c("Reasonable.Cost.cut.off")]);
    rm(savecombi)
    return(newrow)
  } else {
    return(x)
  }
}
for (i in 1:nrow(dffg)){
  new_dffg_rows <- genNewRow(dffg[i,]);
  if(i!=1){
    dffgx <- rbind(dffgx, new_dffg_rows);
  } else {
    dffgx <- new_dffg_rows
  }
}

library(shiny)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  df <- reactive({
    itemlist <- list(input$item1, input$item2,input$item3, input$item4, input$item5,
                   input$item6, input$item7, input$item8, input$item9, input$item10)  #collate items into table;

    #Repeat for each itemlist;
    for (i in 1:length(itemlist)){
      if(itemlist[[i]][1]=="Nil"|itemlist[[i]][1]==""){next}; #Skip if no inputs;
      a<-strsplit(itemlist[[i]][1], split="[,;+]+"); #Split based on , or ;
      df<-data.frame(Code=gsub(" ","",toupper(a[[1]]))); #Remove any white spaces;
      df$Code <- as.character(df$Code)
      df <- subset(df,df$Code!="Nil"); #remove 'Nil' items;
      
      df$sn <- 1:nrow(df);
      df$Code <- as.character(df$Code);
      df <- merge(df, dfml, by="Code", all.x=TRUE) #merge with masterlist;
      df$Item[is.na(df$Item)] <- df$Code[is.na(df$Item)];
      df$Code<- NULL
      df$Ingredient[is.na(df$Ingredient)] <- "";
      df$Food[is.na(df$Food)] <- "Other item not on master list";
      df$Cost[is.na(df$Cost)] <- 0;
      
      #Separate items which are not ingredients;
      dfsave <- subset(df, df$Ingredient=="");
      df <- subset(df, df$Ingredient !="");
      
      if(nrow(df)>0){
        #aggregate data frame by combinations when there are repeated ingredients, separate them[in progress]
        df <- data.frame(df %>% 
                           summarise(sn=min(sn,na.rm=TRUE),
                                     Item=paste(Item[order(Ingredient)], collapse=", "),
                                     Ingredient=paste(unique(Ingredient[order(Ingredient)]), collapse=", "),
                                     Cost=sum(Cost, na.rm=TRUE)))
      }
      #merge with food groupings;
      df <- merge(df,dffgx, by="Ingredient", all.x=TRUE);
      df$Reasonable.Cost.cut.off[is.na(df$Reasonable.Cost.cut.off)] <- 0;
      df$Foodprevious <- NULL;
      
      #Rejoin with items which are not ingredients;
      dfsave$Ingredient <- NULL
      dfsave <- merge(dfsave,dffgx,by="Food",all.x=TRUE)
      dfsave$Ingredient[is.na(dfsave$Ingredient)] <- "";
      dfsave$Reasonable.Cost.cut.off[is.na(dfsave$Reasonable.Cost.cut.off)] <- 0;
      
      df <- rbind(dfsave, df);
      rm(dfsave)
      
      #Apply subsidy if under reasonable cost cut-off;
      df$Subsidy <- ifelse(df$Cost<=df$Reasonable.Cost.cut.off,input$sublevel/100*df$Cost,0)
      df$Price <- df$Cost - df$Subsidy
      
      #If multiple matches keep row with minimum price
      if(nrow(df)>0){
        df <- data.frame(df %>% group_by(sn,Item,Ingredient) %>%
                           slice(which.min(Price)))
      }
      
      df<-df[,c("sn","Item","Ingredient","Food","Cost","Subsidy","Price")]
      
      if(!exists("dftotal")){
        dftotal<- df;
      } else{
        dftotal<- rbind(dftotal,df)
      }
    }
    if(!exists("dftotal")){
      dftotal<-data.frame(sn=integer(),Item=character(),Food=character(),Cost=double(), Subsidy=double(), Price=double())
    } else {
      dftotal$sn <- 1:nrow(dftotal); #Rename serial numbers in ascending order;
    }
    dftotal
    
  });

  output$menuout <- renderTable({
    temp <- dfml
    temp$Cost <- paste0("$",formatC(temp$Cost, big.mark=",",format='f', digits=2))
    temp[,c("Code","Item","Cost")]
  })
  
  output$tableout <- renderTable({
    dftotal<-df();
    if(nrow(dftotal)>0){
      # Convert numbers to currency format;
      dftotal$Cost <- paste0("$",formatC(dftotal$Cost, big.mark=",",format='f', digits=2)); 
      dftotal$Subsidy <- paste0("$",formatC(dftotal$Subsidy, big.mark=",",format='f', digits=2));
      dftotal$Price <- paste0("$",formatC(dftotal$Price, big.mark=",",format='f', digits=2));
    }
    names(dftotal)[names(dftotal)=="Subsidy"]<- "Discount"
    dftotal;
  })

  #Summarise in text;
  output$textout <- renderUI({
    tab <- df()
    
    
    str1 <- paste0("- Total charge is $",formatC(sum(tab$Cost, na.rm=TRUE), format="f",digits=2, big.mark=","));
    str2 <- paste0("Customer is eligible for ",formatC(input$sublevel, format="f",digits=0, big.mark=","),"% discount");
    str3 <- paste0("- Total discount is $",formatC(sum(tab$Subsidy, na.rm=TRUE), format="f",digits=2, big.mark=","));
    str4 <- paste0("- Total price is $",formatC(sum(tab$Price, na.rm=TRUE), format="f",digits=2, big.mark=","));
    str <- paste(str1, str2, str3, str4, sep="<br/>");
    HTML(str)
  })

})
