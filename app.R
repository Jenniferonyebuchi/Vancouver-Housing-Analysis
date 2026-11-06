library(shiny)
library(dplyr)
library(plotly)
library(readr)

source("scripts/prepare_vancouver_housing_data.R")
prepare_vancouver_housing_data()

df <- read_csv("data/vancouver_housing_tidy.csv", show_col_types = FALSE)

all_groups <- c(
  "Black",
  "South Asian",
  "Chinese",
  "Filipino",
  "Arab",
  "Latin American",
  "Southeast Asian",
  "West Asian",
  "Korean",
  "Japanese",
  "Visible minority total",
  "Not a visible minority"
)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background: #eef2f7; font-family: Arial, sans-serif; }
      .well { background: white; border: 1px solid #dfe7f1; border-radius: 12px; box-shadow: none; }
      .panel-title { font-size: 28px; font-weight: 700; color: #1f2d3d; }
      .control-label { font-weight: 600; color: #27384d; }
      .shiny-input-container { margin-bottom: 8px; }
      .checkbox, .radio { margin-top: 6px; margin-bottom: 6px; }
      .plot-container { background: white; border: 1px solid #dfe7f1; border-radius: 12px; padding: 8px; }
      .footer-note { text-align: center; font-size: 12px; color: #5e6b7a; margin-top: 16px; margin-bottom: 8px; }
    "))
  ),
  div(
    style = "padding: 20px 20px 0 20px;",
    h2("Vancouver Housing Equity Dashboard", style = "margin-top: 0; margin-bottom: 20px; color: #1f2d3d; font-weight: 700;")
  ),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        inputId = "groups",
        label = "Select groups to compare",
        choices = all_groups,
        selected = c("Black", "South Asian", "Chinese", "Filipino", "West Asian", "Not a visible minority")
      ),
      selectInput(
        inputId = "year",
        label = "Choose year",
        choices = sort(unique(df$year)),
        selected = 2021
      ),
      radioButtons(
        inputId = "metric",
        label = "Choose metric",
        choices = c(
          "Average Shelter-Cost-to-Income Ratio (%)" = "avg_stir_pct",
          "Average monthly shelter cost ($)" = "avg_monthly_shelter_cost",
          "Average household income ($)" = "avg_household_income"
        ),
        selected = "avg_stir_pct"
      ),
      radioButtons(
        inputId = "tenure",
        label = "Tenure",
        choices = c("Total", "Owner", "Renter"),
        selected = "Total"
      )
    ),
    mainPanel(
      div(
        style = "background: white; border: 1px solid #dfe7f1; border-radius: 12px; padding: 8px;",
        plotlyOutput("comparisonPlot", height = "760px")
      ),
      div(class = "footer-note", "Built by Jennifer Ezinne Onyebuchi")
    )
  )
)

server <- function(input, output, session) {
  filtered_df <- reactive({
    df %>%
      filter(year == input$year) %>%
      filter(visible_minority_status %in% input$groups) %>%
      filter(tenure == input$tenure) %>%
      filter(core_housing_need_status %in% c("In core housing need", "Not in core housing need"))
  })

  output$comparisonPlot <- renderPlotly({
    req(nrow(filtered_df()) > 0)

    metric_label <- switch(
      input$metric,
      "avg_stir_pct" = "Average Shelter-Cost-to-Income Ratio (%)",
      "avg_monthly_shelter_cost" = "Average Monthly Shelter Cost ($)",
      "avg_household_income" = "Average Household Income ($)"
    )

    plot_df <- filtered_df() %>%
      mutate(
        core_housing_need_status = recode(
          core_housing_need_status,
          "In core housing need" = "In core housing need",
          "Not in core housing need" = "Not in core housing need"
        ),
        tooltip = paste0(
          "Group: ", visible_minority_status, "<br>",
          "Status: ", core_housing_need_status, "<br>",
          metric_label, ": ", round(.data[[input$metric]], 1)
        )
      )

    plot_ly(
      data = plot_df,
      x = ~visible_minority_status,
      y = ~.data[[input$metric]],
      type = "bar",
      color = ~core_housing_need_status,
      colors = c("#2E86DE", "#2A9D8F"),
      hoverinfo = "text",
      text = ~tooltip,
      marker = list(line = list(color = "rgba(0,0,0,0.15)", width = 1.5))
    ) %>%
      layout(
        barmode = "group",
        title = list(
          text = paste("Housing need by visible minority group in", input$year),
          font = list(size = 28, color = "#1f2d3d")
        ),
        annotations = list(
          list(
            text = paste("Tenure:", input$tenure),
            x = 0.5,
            y = 1.05,
            xref = "paper",
            yref = "paper",
            showarrow = FALSE,
            font = list(size = 14, color = "#46586e")
          )
        ),
        xaxis = list(
          title = list(text = "Visible minority group", font = list(size = 15, color = "#24384d")),
          tickfont = list(size = 12, color = "#24384d"),
          tickangle = -20,
          categoryorder = "array",
          categoryarray = sort(unique(plot_df$visible_minority_status)),
          automargin = TRUE
        ),
        yaxis = list(
          title = list(text = metric_label, font = list(size = 15, color = "#24384d")),
          tickfont = list(size = 12, color = "#24384d"),
          gridcolor = "#dfe7f1"
        ),
        legend = list(
          title = list(text = "Core housing need", font = list(size = 14, color = "#24384d")),
          font = list(size = 12, color = "#24384d"),
          orientation = "v",
          x = 1.02,
          y = 1
        ),
        bargap = 0.35,
        margin = list(b = 150, l = 70, r = 60, t = 90),
        paper_bgcolor = "#f3f6fb",
        plot_bgcolor = "#f3f6fb"
      )
  })
}

shinyApp(ui, server)
