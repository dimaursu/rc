#!/bin/env ruby
require 'csv'
#
# A program that verifies the metrics of a computer networks, and check if it's
# corectly built.

# Open constraints CSV
class CableProperties
  attr_accessor :name, :baza_stinga, :baza_iterm, :retinerea, :max_length

  def initialize
    pdv = {}
    CSV.foreach('PDV.csv', headers: true) do |row|
      #instead of creating an hash with objects, we can use all those
      #fields in the class, moving this up.
      pdv[row[0]] = CableProperties.new(row[1..-1])
    end
  end
end

# Open Input data CSV
class Concentratoare
  def initialize
    CSV.foreach('con.csv', headers: true) do |row|
      puts row
    end
  end
end


class Concentr_statii
  def initialize
    CSV.foreach('con-st.csv', headers: true) do |row|
      puts row
    end
  end
end
