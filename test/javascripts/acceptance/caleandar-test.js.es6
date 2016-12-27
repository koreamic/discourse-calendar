import { acceptance } from "helpers/qunit-helpers";
acceptance("Calendar", {
  settings: { calendar_enabled: true },
});

test("viewing", () => {
  visit("/");
  andThen(() => {
    ok(exists(".discourse-calendar-container"), "The calendar was rendered");
    equal(find(".calendar-container").is(":visible"), false, "it hides the calendar.");
  });

  visit("/c/bug");
  andThen(() => {
    ok(exists(".discourse-calendar-container"), "The calendar was rendered in a category");
    equal(find(".calendar-container").is(":visible"), false, "it hides the calendar in a category.");
  });

});
