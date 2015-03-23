Monit.EventsController = Ember.Controller.extend({
  dronesCount: [],

  init: function(){
    controller = this
    fetchAndPaintEvents = function(){
      $.ajax("/events").then(function(data){
        controller.set("dronesCount", [])
        data.events.forEach(function(event){
          if(event.unit_type === "Drone"){
            monitEvent = Monit.Event.createNew(event)
            controller.get("dronesCount").pushObject(monitEvent)
          }
        })
      })


      console.log("updated events")
    }
    fetchAndPaintEvents()
    setInterval(fetchAndPaintEvents, 1000)
    console.log("init")
  }
})
