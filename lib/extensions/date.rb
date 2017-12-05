class Date
  def business_dates(count)
    arr = []
    d = self
    arr << d if d.bussiness_date?
    until arr.size == count do
      d = d.next_business_date
      arr << d
    end
    arr
  end

  def next_business_date
    d = self.next
    until d.bussiness_date? do
      d = d.next
    end
    d
  end

  def bussiness_date?
    self.workday? && !self.holiday?
  end

  def holiday?
    HolidayJp.holiday?(self)
  end
end