library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  header = dashboardHeader(
    title = "Meu app!!!"
  ),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("Informações gerais", tabName = "info"),
      menuItem("Orçamentos", tabName = "orcamentos")
    )
  ),
  body = dashboardBody(
    tabItems(
      tabItem(
        tabName = "info",
        fluidRow(
          column(
            width = 12,
            h1("Informações gerais dos filmes"),
            selectInput("variavel", label = "Selecione variável", choices = names(mtcars))
          )
        )
      ),
      tabItem(
        tabName = "orcamentos",
        h1("Analisando os orçamentos")
      )
    )
  ),
  title = "Meu app"
)

server <- function(input, output, session) {

}

shinyApp(ui, server)
