library(shiny)
library(shinydashboard)
library(tidyverse)



ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Informações gerais", tabName = "info"),
      menuItem("Bilheteria", tabName = "bilheteria"),
      menuItem("Filmes", tabName = "filmes")
    )
  ),
  dashboardBody(
    tabItems(
      # aba 1: informacoes gerais
      tabItem(
        tabName = "info",
        h1("Informações gerais dos filmes"),
        br(),
        fluidRow(
          infoBoxOutput(
            outputId = "num_filmes",
            width = 4
          ),
          infoBoxOutput(
            outputId = "num_diretores",
            width = 4
          ),
          infoBoxOutput(
            outputId = "num_atores",
            width = 4
          )
        ),
        h3("Top 10 lucros"),
        br(),
        fluidRow(
          column(
            width = 12,
            reactable::reactableOutput("tabela_infos_gerais")
          )
        )
      ),
      # aba 2: bilheteria
      tabItem(
        tabName = "bilheteria",
        h1("Analisando os orçamentos"),
        br(),
        fluidRow(
          box(
            width = 12,
            uiOutput("ui_genero")
          )
        ),
        fluidRow(
          box(
            width = 6,
            title = "Série do orçamento",
            solidHeader = TRUE,
            status = "primary",
            plotOutput("serie_orcamento")
          ),
          box(
            width = 6,
            title = "Série da receita",
            solidHeader = TRUE,
            status = "primary",
            plotly::plotlyOutput("serie_receita")
          )
        )
      )
      # aba 3: filmes
    )
  )
)

server <- function (input, output, session) {

  imdb <- read_rds("imdb.rds")

  # infoboxes ----
  output$num_filmes <- renderInfoBox({
    infoBox(
      title = "Número de filmes",
      value = nrow(imdb),
      icon = icon("film"),
      fill = TRUE
    )
  })

  output$num_diretores <- renderInfoBox({
    infoBox(
      title = "Número de filmes",
      value = n_distinct(imdb$diretor),
      icon = icon("hand-point-right"),
      fill = TRUE
    )
  })

  output$num_atores <- renderInfoBox({

    num_atores <- imdb %>%
      select(starts_with("ator")) %>%
      pivot_longer(cols = ator_1:ator_3) %>%
      distinct(value) %>%
      nrow()

    infoBox(
      title = "Número de atores",
      value = num_atores,
      icon = icon("user-friends"),
      fill = TRUE
    )
  })

  output$tabela_infos_gerais <- reactable::renderReactable({
    imdb %>%
      mutate(lucro = receita - orcamento) %>%
      top_n(200, lucro) %>%
      select(titulo, diretor, ano, lucro) %>%
      arrange(desc(lucro)) %>%
      ## isso aqui é ruim pois transforma em texto
      # mutate(lucro = scales::dollar(lucro)) %>%
      reactable::reactable(
        columns = list(
          lucro = reactable::colDef(
            "Lucro", format = reactable::colFormat(
              prefix = "",
              locales = "pt-BR",
              separators = TRUE,
              currency = "BRL"
            )
          ),
          diretor = reactable::colDef(
            "Diretor",
            align = "center"
          )
        ),
        striped = TRUE,
        highlight = TRUE,
        defaultPageSize = 20
      )
  })

  output$ui_genero <- renderUI({

    generos <- imdb$generos %>%
      paste(collapse = "|") %>%
      str_split("\\|") %>%
      unlist() %>%
      as.character() %>%
      unique() %>%
      sort()

    selectInput(
      inputId = "genero_orcamento",
      label = "Selecione um gênero",
      choices = generos,
      width = "25%"
    )

  })

  output$serie_orcamento <- renderPlot({

    req(input$genero_orcamento)

    imdb %>%
      filter(str_detect(generos, input$genero_orcamento)) %>%
      group_by(ano) %>%
      summarise(orcamento_medio = mean(orcamento, na.rm = TRUE)) %>%
      filter(!is.na(orcamento_medio)) %>%
      ggplot(aes(x = ano, y = orcamento_medio)) +
      geom_line()

  })

  output$serie_receita <- plotly::renderPlotly({

    req(input$genero_orcamento)

    p <- imdb %>%
      filter(str_detect(generos, input$genero_orcamento)) %>%
      group_by(ano) %>%
      summarise(receita_medio = mean(receita, na.rm = TRUE)) %>%
      filter(!is.na(receita_medio)) %>%
      ggplot(aes(x = ano, y = receita_medio)) +
      geom_line()

    plotly::ggplotly(p)

  })



}

auth0::shinyAppAuth0(ui, server)

# shinyApp(ui, server)

