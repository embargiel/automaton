Monit.Event = Steak.Model.extend({
  attributes: {
    eventType: Steak.String,
    unitType:  Steak.String,
    unitCount: Steak.Float,
    createdAt: Steak.Date
  }
})