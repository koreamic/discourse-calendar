# Discourse Calendar Plugin [한글](#discourse-calendar-pluginko)

This plug-in allows users to register schedules and check it easily through calendar views.

# Screen Shots
- **Calendar view**
![calendar view](./discourse-calendar-calendar-view.jpg)

- **Modal popup for adding schedule**
![calendar view](./discourse-calendar-addschedule-modal.jpg)

- **Schedule detail view**
![calendar view](./discourse-calendar-schedule-detail.jpg)

- **If want more details, See discourse-calendar.mp4**

# Features
- Users can register schedules in any post.
- Using calendar view, Users can show schedules.
- The calendar can be viewed monthly, weekly, and daily.
- Users can register all day schedule or specific time schedule.
- Users can register one or more schedules in a post.
- Users can enter extra contents about a schedule.

# Develop with
- calendar library(https://fullcalendar.io/, https://github.com/fullcalendar/fullcalendar.git)
- card ui library(http://semantic-ui.com/, https://github.com/Semantic-Org/Semantic-UI.git)

# Installation
- clone plugin sources in discourse/plugins directory
```
$ git clone https://github.com/koreamic/discourse-calendar.git
```
- execute datebase migration
```
$ bundle exec rake db:migrate RAILS_ENV=[production or development or test]
```
- if nessesary, execute assets precompile
```
$ bundle exec rake assets:precompile RAILS_ENV=production
```
- start server and enjoy calendar plugin.

# TODO
- Add various calendar options in plugin setting.
  - header menu : year....

# License

 MIT

---

# Discourse Calendar Plugin(ko)

사용자가 일정을 등록하고 캘린더 화면에서 일정을 확인 할 수 있는 플러그-인 입니다.

# Screen Shots
- **캘린더 화면**
![calendar view](./discourse-calendar-calendar-view.jpg)

- **일정을 등록하는 modal 팝업**
![calendar view](./discourse-calendar-addschedule-modal.jpg)

- **일정 상세 화면**
![calendar view](./discourse-calendar-schedule-detail.jpg)

- **더 자세한 사항은 discourse-calendar.mp4 파일을 확인 하시기 바랍니다.**

# Features
- 사용자는 어떤 글에도 일정을 등록할 수 있습니다.
- 캘린더 화면을 통해서 사용자는 일정들을 확인 할 수 있습니다.
- 캘린더 화면은 월별,주별, 일별로 보여질 수 있습니다.
- 사용자는 종일 또는 특정 시간에 대한 일정을 등록할 수 있습니다.
- 사용자는 하나의 글에 하나 이상의 일정을 등록할 수 있습니다.
- 사용자는 일정에 대해서 추가적인 내용을 작성할 수 있습니다.

# Develop with
- calendar library(https://fullcalendar.io/, https://github.com/fullcalendar/fullcalendar.git)
- card ui library(http://semantic-ui.com/, https://github.com/Semantic-Org/Semantic-UI.git)

# Installation
- discourse/plugins 디렉토리 안에 소스를 클론받습니다. 
```
$ git clone https://github.com/koreamic/discourse-calendar.git
```
- 데이터 마이그레이션을 실행합니다..
```
$ bundle exec rake db:migrate RAILS_ENV=[production or development or test]
```
- 필요시에는 assets precompile을 진행합니다.
```
$ bundle exec rake assets:precompile RAILS_ENV=production
```
- 서버를 시작하고, 캘린터 플러그인을 즐겨요.

# TODO
- 플러그인 설정을 통해서 다양한 캘린더 옵션 추가를 고려하고 있습니다.
  - header menu : year....

# License

 MIT
