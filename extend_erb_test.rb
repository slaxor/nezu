#!/usr/bin/env ruby
#
require 'erb'

class ERBNamespace
  @bar = 2.741

  def self.get_binding
    binding
  end

  def self.foo
    3.1415926537
  end

  ###############################################
  def initialize(hash)
    hash.each do |key, value|
      singleton_class.send(:define_method, key) { value }
    end
  end


  def get_binding
    binding
  end
end

#template = 'Name: <%= name %> <%= last %>'
#ns = ERBNamespace.new(name: 'Joan', last: 'Maragall')
#puts ERB.new(template).result(ns.get_binding)
#=> Name: Joan Maragall

template = 'foo = <%= foo %> bar = <%= @bar %>'
#ns = ERBNamespace.new(name: 'Joan', last: 'Maragall')
puts ERB.new(template).result(ERBNamespace.get_binding)

