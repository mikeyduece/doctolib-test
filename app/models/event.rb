class Event < ApplicationRecord
  extend Events::DateHelper
  
  scope :availabilities, ->(date) {
    date_range = (date..(date + 6.day).end_of_day)
    
    date_range.each_with_object([]) do |d, acc|
      data = {
        date: d.strftime('%Y/%m/%d'),
        slots: openings(d)
      }
      acc << data
    end
  }
end

