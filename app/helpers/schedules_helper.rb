module SchedulesHelper
  def student_group_collection(student_groups)
    collect_values(student_groups, [:id, :full_name, :year, :letter])
  end

  def day_time_collection(day_times)
    collection = []
    day_times.each_with_index do |dt, i|
      collection << [i, dt.first, dt.second.start_time.to_s(:lesson)]
    end
    collection
  end
  
  def schedule_item_collection(day_times, groups, item_table)
    collection = []
    day_times.each_with_index do |dt, i|
      collection[i] = []
      groups.each_with_index do |group, j|
        collection[i] << 
          [item_table[i][j].id, i, j, item_table[i][j].subject.id, item_table[i][j].class_room.id, group.id]
      end
    end
    collection
  end
  
  def room_collection(rooms)
    rooms.collect do |room|
      [room.id, room.number, "false"]
    end
  end
  
  def subject_collection(subjects)
    collect_values(subjects, [:id, :name, :year])
  end
  
  def mark_errors(page)
    @errors.each do |key, value|
      value.each do |error|
        page.call "Global.schedule.markInvalid", key.id, error  
      end
    end
  end
end
