module Events
  module DateHelper
    
    def openings(d)
      return [] unless available_date?(d)
      
      sql = <<~SQL
         with RECURSIVE openings(opening) as (
           select time(starts_at) from events where  kind = 'opening'
           union
           select time(opening, '+30 minute') from openings
           where time(opening) < (select time(ends_at) from events where kind = 'opening')
        )
         select opening from openings
         except
         select opening from openings
           where opening >= (
                              select time(starts_at) from events where kind = 'appointment'
                               and datetime(starts_at, 'start of day') = "#{d.beginning_of_day.strftime('%Y-%m-%d %H:%M:%S')}"
                            )
             and opening < (
                              select time(ends_at) from events where kind = 'appointment'
                                and datetime(ends_at, 'start of day') = "#{d.beginning_of_day.strftime('%Y-%m-%d %H:%M:%S')}"
                            );
      SQL
      
      connection.execute(sql).map { |h| DateTime.parse(h['opening'])&.strftime('%l:%M')&.squish }
                .reject { |r| where(kind: 'opening').pluck(:ends_at).map { |c| c.strftime('%l:%M') }.include?(r) }
    end
    
    def available_date?(d)
      valid_non_recurring_date?(d) || valid_recurring_date?(d)
    end
    
    def valid_recurring_date?(d)
      day_of_week = d.strftime('%w')
      
      (select("strftime('%w', starts_at) as dow").where(kind: 'opening', weekly_recurring: true).map(&:dow).include?(day_of_week) &&
        (1..5).include?(day_of_week.to_i))
    end
    
    def valid_non_recurring_date?(d)
      where(kind: 'opening', weekly_recurring: false)
        .find_by("strftime('%Y/%m/%d', starts_at) = '#{d.strftime('%Y/%m/%d')}'")
    end
  end
end