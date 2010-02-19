namespace :sms do
  namespace :db do
    task :fill => [:empty_all, :populate] 
  
    task :empty_all => :environment do
      ScheduleItem.destroy_all
      TeacherSubject.destroy_all
      Subject.destroy_all  
      StudentGroup.destroy_all  
      ClassRoom.destroy_all  
      Person.destroy_all  
      Role.destroy_all
      AclAction.destroy_all
    end
    
    task :populate do
      create_settings
      acl_actions = create_acl_actions
      roles = create_roles
      assign_acl_actions
      groups = create_groups
      class_rooms, room_map = create_rooms_and_map
      subject_ids = create_subject_ids(room_map)
      teachers = create_teachers
      create_teacher_subjects(teachers)
      admin = User.create :login => "qwe", :password => "123qwe", :password_confirmation => "123qwe", :email => "qwe@asdasd.ru", :first_name => "first", :last_name => "last", :birth_date => DateTime.now, :home_address => "qwe", :role_id => Role.admin.id
      admin.save
    end
    
    task :fill_acl_actions => :environment do
      AclAction.destroy_all
      create_acl_actions
      assign_acl_actions
    end
    
    def create_settings
      Settings["short_break"] = 10
      Settings["long_break"] = 20
      Settings["lessons_start"] = Time.utc(2010,02,02,8,0,0)
      Settings["lesson_length"] = 45
    end
    
    def create_acl_actions
      AclAction.create ACL_ACTIONS
    end
    
    def create_roles
      ROLES.each do |role|
        Role.create :name => role
      end
    end
    
    def create_groups
      groups = []
      Subject::SCHOOL_YEARS.each do |year|
        LETTERS.each do |letter|
          group = StudentGroup.create :year => year, :letter => letter
          groups << group
        end
      end
      groups
    end
    
    def assign_acl_actions
      Role.admin.acl_actions << AclAction.find_by_name("users")
      Role.admin.acl_actions << AclAction.find_by_name("roles")
    end
    
    def create_rooms_and_map
      class_rooms = []
      room_map = {}
      for i in 1..FLOOR_COUNT do
        for j in 1..ROOMS_PER_FLOOR do
          class_room = ClassRoom.create :number => (i.to_s + (j < 10 ? "0" : "") + j.to_s)
          class_rooms << class_room
          room_map[class_room.number.to_sym] = class_room
        end
      end
      return class_rooms, room_map
    end
    
    def create_subject_ids(room_map)
      subject_ids = []
      Subject::SCHOOL_YEARS.each do |year|
        subject_no = 0
        subjects = []
        SUBJECT_NAMES.each do |subject_name|
          subjects << Subject.new(:name => subject_name, :year => year, :hours_per_week => 4)
        end
        for i in 1..FLOOR_COUNT do
          for j in 1..ROOMS_PER_FLOOR do
            room_no = i.to_s + (j < 10 ? "0" : "") + j.to_s
            subjects[subject_no].class_rooms << room_map[room_no.to_sym]
            subject_no += 1
            if subject_no >= SUBJECT_NAMES.length
              subject_no = 0
            end
          end
        end
        subjects.each do |subject|
          subject.save
          subject_ids << subject.id
        end
      end
      subject_ids
    end
    
    def create_teachers
      teachers = []
      TEACHERS.each_with_index do |teacher_name, index|
        teacher = Teacher.create :birth_date => DateTime.now, :email => "abc@asdasd.ru", :first_name => teacher_name.second, :last_name => teacher_name.first, :login => "teacher#{index}", :password => "password", :role_id => Role.teacher.id
        teachers << teacher
      end
      teachers
    end
    
    def create_teacher_subjects(teachers)
      j = 0
      Subject::SCHOOL_YEARS.each do |year|
        year_groups = StudentGroup.by_year(year)
        year_subjects = Subject.by_year(year)
        year_groups.each do |group|
          year_subjects.each do |subject|
            teacher = teachers[j]
            TeacherSubject.create :student_group => group, :teacher => teacher, :subject => subject
            j += 1
            if j >= teachers.length
              j = 0
            end
          end
        end
      end
    end
    
    ACL_ACTIONS = [
      { :name => "users", :title => "Пользователи" },
      { :name => "roles", :title => "Роли" },
      { :name => "news/new", :title => "Управление новостями" },
      { :name => "years", :title => "Учебные годы и четверти" },
      { :name => "time_table_items", :title => "Расписание звонков" },
      { :name => "class_rooms", :title => "Аудитории" },
      { :name => "students", :title => "Ученики" },
      { :name => "student_groups", :title => "Классы" },
      { :name => "subjects", :title => "Предметы" },
      { :name => "teacher_subjects", :title => "Предметы учителей" },
      { :name => "schedule", :title => "Расписание занятий" },
      { :name => "register", :title => "Журналы" }      
    ]
    
    LETTERS = ["A", "B", "C"]
    SUBJECT_NAMES = ["Математика", "Русский язык", "Белорусский язык", 
            "Физкультура", "Физика", "Химия", 
            "История", "Английский язык", "Биология"]
    FLOOR_COUNT = 3
    ROOMS_PER_FLOOR = 15
    ROLES = [
      "Администратор",
      "Учитель",
      "Родитель",
      "Методист",
      "Директор"
    ]
    
    TEACHERS = [
      ["Абрамишвили", "Мария Гурамовна"],
      ["Августинович", "Глория Олеговна"],
      ["Авеева", "Ева Владимировна"],
      ["Аверина", "Ирина Егоровна"],
      ["Агапова", "Нина Фёдоровна"],
      ["Агуреева", "Полина Владимировна"],
      ["Адельгейм", "Тамара Фридриховна"],
      ["Азарова", "Анна Александровна"],
      ["Азарх-Опалова", "Евгения Эммануиловна"],
      ["Акимова", "Софья Павловна"],
      ["Акиньшина", "Оксана Александровна"],
      ["Аксюта", "Татьяна Владимировна"],
      ["Акулова", "Ирина Григорьевна"],
      ["Акулова", "Тамара Васильевна"],
      ["Алабина", "Инна Ильинична"],
      ["Александрова", "Марина Андреевна"],
      ["Алексахина", "Анна Яковлевна"],
      ["Алентова", "Вера Валентиновна"],
      ["Алимова", "Матлюба Фархатовна"],
      ["Алфёрова", "Ирина Ивановна"],
      ["Вдовина", "Наталья Геннадьевна"],
      ["Вележева", "Лидия Леонидовна"],
      ["Великанова", "Елена Сергеевна"],
      ["Волчек", "Галина Борисовна"],
      ["Вертинская", "Анастасия Александровна"],
      ["Вертинская", "Марианна Александровна"],
      ["Вилкова", "Екатерина Николаевна"],
      ["Вилкова", "Таисия Александровна"],
      ["Виноградова", "Мария Сергеевна"],
      ["Вознесенская", "Анастасия Валентиновна"],
      ["Воилкова", "Валентина Дмитриевна"],
      ["Волкова", "Екатерина Юрьевна"],
      ["Волкова", "Ольга Владимировна"],
      ["Дамскер", "Юлия Иосифовна"],
      ["Данилина", "Эльвира Игоревна"],
      ["Данилова", "Наталья Юрьевна"],
      ["Дапкунайте", "Ингеборга Эдмундовна"],
      ["Дворжецкая", "Нина Игоревна"],
      ["Дезмари", "Диана Игоревна"],
      ["Демидова", "Алла Сергеевна"],
      ["Державина", "Наталья Владимировна"],
      ["Джербинова", "Юлия Георгиевна"],
      ["Джураева", "Тамара Николаевна"],
      ["Димова", "Анна Олеговна"],
      ["Дитковските", "Агния Олеговна"],
      ["Добровольская", "Евгения Владимировна"],
      ["Догилева", "Татьяна Анатольевна"],
      ["Дольникова", "Теона Валентиновна"],
      ["Доронина", "Татьяна Васильевна"],
      ["Дорохина", "Александра Митрофановна"],
      ["Дорохина", "Оксана Сергеевна"],
      ["Юганова", "Алла Сергеевна"],
      ["Юдина", "Зоя Борисовна"],
      ["Юдина", "Ирина Юрьевна"],
      ["Юнгер", "Елена Владимировна"],
      ["Юнникова", "Наталья Александровна"],
      ["Соколова", "Галина Михайловна"],
      ["Соколова", "Зинаида Сергеевна"],
      ["Соколова", "Ирина Леонидовна"],
      ["Соколова", "Любовь Сергеевна"],
      ["Солдатова", "Наталья Эдуардовна"],
      ["Соловей", "Елена Яковлевна"],
      ["Соломина", "Варвара Михайловна"],
      ["Соломина", "Екатерина Сергеевна"],
      ["Сотникова", "Вера Михайловна"],
      ["Сотничевская", "Софья Владимировна"],
      ["Спивак", "Эмилия Семёновна"],
      ["Столповская", "Ольга Борисовна"],
      ["Стрелкова-Оболдина", "Инга Петровна"],
      ["Стрельская", "Варвара Васильевна"],
      ["Стрепетова", "Полина Антипьевна"],
      ["Стриженова", "Екатерина Владимировна"],
      ["Стриженова", "Любовь Васильевна"],
      ["Стриженова", "Марианна Александровна"],
      ["Судейкина", "Вера Артуровна"],
      ["Судзиловская", "Олеся Ильинична"],
      ["Сутулова", "Ольга Александровна"],
      ["Сухаревская", "Лидия Петровна"],
      ["Суюншалина", "Бибигуль Актановна"],
      ["Сёмина", "Тамара Петровна"],
      ["Сёмкина", "Мария Рафаиловна"]
    ]
  end
end