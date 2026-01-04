# ======================================================
# TOP RATED PAGE (UI + SERVER)
# ======================================================

top_rated_ui <- function() {
  div(
    class = "top-rated-page",
    
    div(
      class = "top-rated-header",
      h3("⭐ Top Rated Content")
    ),
    
    div(
      class = "top-rated-controls-wrapper",
      
      div(
        class = "top-rated-controls",
        
        textInput(
          "top_search",
          NULL,
          placeholder = "🔍 Search top rated titles...",
          width = "100%"
        ),
        
        pickerInput(
          "top_type",
          NULL,
          choices = c("All", "Movie", "TV Show"),
          selected = "All",
          width = "200px"
        ),
        
        pickerInput(
          "top_sort",
          NULL,
          choices = c(
            "Highest → Lowest" = "rating_desc",
            "Lowest → Highest" = "rating_asc"
          ),
          selected = "rating_desc",
          width = "200px"
        )
      )
    ),
    
    div(
      class = "top-rated-table-wrapper",
      tableOutput("top_rated_table")
    )
  )
}


top_rated_server <- function(input, output, session, load_movies) {
  
  top_rated_data <- reactive({
    df <- load_movies()
    if (nrow(df) == 0) return(df)
    
    # ✅ Only finished & rated
    df <- df[df$finished == 1 & !is.na(df$rating), , drop = FALSE]
    
    # 🔍 Search
    if (nzchar(input$top_search)) {
      df <- df[
        grepl(input$top_search, df$title, ignore.case = TRUE),
        ,
        drop = FALSE
      ]
    }
    
    # 🎬 Type filter
    if (input$top_type != "All") {
      df <- df[df$type == input$top_type, , drop = FALSE]
    }
    
    # ⭐ Sort
    if (input$top_sort == "rating_desc") {
      df <- df[order(df$rating, decreasing = TRUE), , drop = FALSE]
    }
    
    if (input$top_sort == "rating_asc") {
      df <- df[order(df$rating, decreasing = FALSE), , drop = FALSE]
    }
    
    df
  })
  
  
  output$top_rated_table <- renderTable({
    df <- top_rated_data()
    if (nrow(df) == 0) {
      return(data.frame(Message = "No rated titles yet"))
    }
    
    data.frame(
      `#` = seq_len(nrow(df)),
      Poster = sprintf(
        "<img src='%s' style='height:80px;border-radius:6px;'/>",
        df$poster_path
      ),
      Title = df$title,
      Rating = paste0(df$rating, " / 10"),
      check.names = FALSE
    )
  }, sanitize.text.function = function(x) x)
}
