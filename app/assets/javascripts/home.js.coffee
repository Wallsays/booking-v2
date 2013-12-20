$ ->
  
  $("button#login").click ->
    $(".screenfade").show()
    $(".model-login").show()
    $(".screenfade").animate(
      opacity: 0.5
    , 1000).delay 1000
    $(".model-login").animate(
      opacity: 1.0
    , 1000).delay 1000

  $('#datepicker').datepicker()
  $('#datepicker2').datepicker()
  
  # $('#timepicker').timepicker()
  $('#timepicker').timepicker(
    minuteStep: 15,
    showInputs: false,
    disableFocus: true
  )
  $('#timepicker2').timepicker(
    minuteStep: 15,
    showInputs: false,
    disableFocus: true
  )

