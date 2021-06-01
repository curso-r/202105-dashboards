library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  header = dashboardHeader(
    title = "Meu app!!!"
  ),
  sidebar = dashboardSidebar(),
  body = dashboardBody(),
  title = "Meu app"
)

server <- function(input, output, session) {

}

shinyApp(ui, server)
