moduleFor("controller:schedule-ui-builder", "controller:schedule-ui-builder", {
  needs: ['controller:modal']
});

/*
{
title: "",
startDate: "",
startTime: "",
endDate: "",
endTime: "",
allDay:true
}
*/
test("disableInsert", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "",
    startTime: "",
    endDate: "2017-01-09",
    endTime: "",
    allDay:true
  });

  equal(controller.get("disableInsert"), true, "it should be true");

  controller.set("startDate", "2018-01-08");
  equal(controller.get("disableInsert"), true, "it should be true");

  controller.set("startDate", "20170108");
  equal(controller.get("disableInsert"), true, "it should be true");

  controller.set("startDate", "2017-01-08");
  equal(controller.get("disableInsert"), false, "it should be false");

  controller.set("allDay", false);
  equal(controller.get("disableInsert"), true, "it should be true");

  controller.set("startTime", "12:00");
  controller.set("endTime", "13:00");
  equal(controller.get("disableInsert"), false, "it should be false");
});

test("hasValidStartDate", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "2017-01-09",
    startTime: "",
    endDate: "",
    endTime: "",
    allDay:true
  });

  equal(controller.get("hasValidStartDate"), true, "it should be true");

  controller.set("startDate", "20170109");
  equal(controller.get("hasValidStartDate"), false, "it should be false");

  controller.set("startDate", "asdfqwer");
  equal(controller.get("hasValidStartDate"), false, "it should be false");
});

test("hasValidStartTime", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "",
    startTime: "13:09",
    endDate: "",
    endTime: "",
    allDay:false
  });

  equal(controller.get("hasValidStartTime"), true, "it should be true");

  controller.set("startTime", "1309");
  equal(controller.get("hasValidStartTime"), false, "it should be false");

  controller.set("startTime", "asdfqwer");
  equal(controller.get("hasValidStartTime"), false, "it should be false");
});

test("hasValidEndDate", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "",
    startTime: "",
    endDate: "2017-01-09",
    endTime: "",
    allDay:true
  });

  equal(controller.get("hasValidEndDate"), true, "it should be true");

  controller.set("endDate", "20170109");
  equal(controller.get("hasValidEndDate"), false, "it should be false");

  controller.set("endDate", "asdfqwer");
  equal(controller.get("hasValidEndDate"), false, "it should be false");
});

test("hasValidEndTime", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "",
    startTime: "",
    endDate: "",
    endTime: "13:09",
    allDay:false
  });

  equal(controller.get("hasValidEndTime"), true, "it should be true");

  controller.set("endTime", "1309");
  equal(controller.get("hasValidEndTime"), false, "it should be false");

  controller.set("endTime", "asdfqwer");
  equal(controller.get("hasValidEndTime"), false, "it should be false");
});

test("hasValidDateTime", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "",
    startDate: "2017-01-09",
    startTime: "13:00",
    endDate: "2017-01-09",
    endTime: "14:00",
    allDay:false
  });

  equal(controller.get("hasValidDateTime"), true, "it should be true");

  controller.set("endTime", "12:00");
  equal(controller.get("hasValidDateTime"), false, "it should be false");

  controller.set("allDay", true);
  controller.set("startTime", "");
  controller.set("endTime", "");
  equal(controller.get("hasValidDateTime"), true, "it should be true");

  controller.set("endDate", "2017-01-08");
  equal(controller.get("hasValidDateTime"), false, "it should be false");

});


test("regular schedule", function() {
  const controller = this.subject();

  controller.setProperties({
    title: "Javascript Test Conference",
    startDate: "2017-01-09",
    startTime: "13:00",
    endDate: "2017-01-09",
    endTime: "14:00",
    allDay:false
  });

  equal(controller.get("scheduleOutput"), "[schedule title='Javascript Test Conference' start_date_time=2017-01-09T13:00 end_date_time=2017-01-09T14:00 all_day=false]\n[/schedule]", "it should return the right ouput");

  controller.set("allDay", true);
  controller.set("startTime", "");
  controller.set("endTime", "");
  equal(controller.get("scheduleOutput"), "[schedule title='Javascript Test Conference' start_date_time=2017-01-09 end_date_time=2017-01-09 all_day=true]\n[/schedule]", "it should return the right output");
});

