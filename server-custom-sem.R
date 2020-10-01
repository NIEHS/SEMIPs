



  
  observeEvent(input$dist, {
    updateTablePanel("params", selected = input$dist)
  }) 
  
  sample <- reactive({
    switch(input$dist,
           normal = rnorm(input$n, input$mean, input$sd),
           uniform = runif(input$n, input$min, input$max),
           exponential = rexp(input$n, input$rate)
    )
  })
  
  output$hist <- renderPlot(hist(sample()), res = 96)


