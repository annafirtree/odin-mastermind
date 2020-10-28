# frozen_string_literal:true

# Info class stores what is known about a particular color or color combination
class Info
  attr_reader :min, :max

  def initialize
    @min = 0
    @max = Pattern::MAX_LENGTH
  end

  def to_s
    "[min: #{@min}, max: #{@max}]"
  end

  def raise_min_to_at_least(new_min)
    @min = [new_min, @min].max
    raise "tried to raise min (#{@min}) higher than max (#{max})" if @min > @max
  end

  def lower_max_to_no_more_than(new_max)
    @max = [new_max, @max].min
    raise "tried to lower max (#{max}) below  min (#{@min})" if @max < @min
  end
end
