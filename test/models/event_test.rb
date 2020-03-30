require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  test "one simple test example" do
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create(kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30"))
    availabilities = Event.availabilities(DateTime.parse("2014-08-10"))
    
    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end
  
  test 'it can account for more than one weekly recurring openings' do
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-05 09:30"), ends_at: DateTime.parse("2014-08-05 12:30"), weekly_recurring: true)
    Event.create(kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30"))
    availabilities = Event.availabilities(DateTime.parse("2014-08-10"))

    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end
  
  test 'it can account for non weekly recurring openings' do
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 12:30"))
    availabilities = Event.availabilities(DateTime.parse("2014-08-10"))
    availabilities1 = Event.availabilities(DateTime.parse("2014-08-17"))
    
    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
    
    assert_equal [], availabilities1[1][:slots]
  end
  
  test 'it can have recurring and non recurring openings' do
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-12 09:30"), ends_at: DateTime.parse("2014-08-12 12:30"))
    availabilities = Event.availabilities(DateTime.parse("2014-08-10"))
    availabilities1 = Event.availabilities(DateTime.parse("2014-08-17"))
    
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal '2014/08/12', availabilities[2][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[2][:slots]
    
    assert_equal '2014/08/18', availabilities1[1][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities1[1][:slots]
    assert_equal '2014/08/19', availabilities1[2][:date]
    assert_equal [], availabilities1[2][:slots]
  end

  test 'it can have recurring and non recurring openings with appointments' do
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create(kind: 'opening', starts_at: DateTime.parse("2014-08-12 09:30"), ends_at: DateTime.parse("2014-08-12 12:30"))
    Event.create(kind: 'appointment', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 11:30"))
    Event.create(kind: 'appointment', starts_at: DateTime.parse("2014-08-12 09:30"), ends_at: DateTime.parse("2014-08-12 10:00"))
    
    availabilities = Event.availabilities(DateTime.parse("2014-08-10"))
    availabilities1 = Event.availabilities(DateTime.parse("2014-08-17"))
  
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["11:30", "12:00"], availabilities[1][:slots]
    assert_equal '2014/08/12', availabilities[2][:date]
    assert_equal ["10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[2][:slots]
    
    assert_equal '2014/08/18', availabilities1[1][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities1[1][:slots]
    assert_equal '2014/08/19', availabilities1[2][:date]
    assert_equal [], availabilities1[2][:slots]
  end

end
