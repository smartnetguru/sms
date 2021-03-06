# coding: utf-8

class Mailer < ActionMailer::Base
  def student_weekly_results(student, weekly_diary)
    recipients  student.parent_email
    from        'school.management.system@yandex.ru'
    subject     "Успеваемость за неделю"
    body        :student => student,
                :weekly_diary => weekly_diary
    content_type "text/html"
  end
end
