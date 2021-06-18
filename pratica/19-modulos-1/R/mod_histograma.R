# visão da esquerda

histograma_ui <- function(id) {
  ns <- NS(id)

  tagList(
    selectInput(
      inputId = ns("variavel"),
      label = "Selecione uma variável",
      choices = names(mtcars)
    ),
    br(),
    plotOutput(outputId = ns("grafico"))
  )
}

histograma_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$grafico <- renderPlot({
      hist(mtcars[[input$variavel]])
    })

  })
}
