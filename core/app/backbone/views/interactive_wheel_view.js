window.InteractiveWheelView = window.BaseFactWheelView.extend({
	getFactId: function() {
    if (this.model.get('fact_id')) {
      return this.model.get('fact_id');
    } else {
      return this.options.fact.id;
    }
  },

  clickOpinionType: function (opinionType, e) {
    var self = this;
		this.toggleActiveOpinionType(opinionType);

		if ( opinionType.is_user_opinion ) {
      $.ajax({
        url: "/facts/" + self.getFactId() + "/opinion/" + opinionType.type + "s.json",
        type: "POST",
        success: function(data) {
          self.updateTo(data.authority, data.opinion_types);

          mp_track("Factlink: Opinionate", {
            factlink: self.options.fact.id,
            opinion: opinionType.type
          });
        },
        error: function() {
          self.toggleActiveOpinionType(opinionType);

          alert("Something went wrong while setting your opinion on the Factlink, please try again");
        }
      });
		} else {
      $.ajax({
        type: "DELETE",
        url: "/facts/" + self.getFactId() + "/opinion.json",
        success: function(data) {
          self.updateTo(data.authority, data.opinion_types);

          mp_track("Factlink: De-opinionate", {factlink: self.options.fact.id});
        },
        error: function() {
          self.toggleActiveOpinionType(opinionType);

          alert("Something went wrong while removing your opinion on the Factlink, please try again");
        }
      });
		}
	}
});
