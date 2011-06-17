#!/usr/bin/env ruby
# encoding: utf-8

# from http://amqp.rubyforge.org/classes/MQ/Exchange.html

require "bundler"
Bundler.setup

require "amqp"

EventMachine.run do
  AMQP.start do |connection|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.topic("stocks")

    keys = ["stock.us.aapl", "stock.de.dax"]

    EventMachine.add_periodic_timer(1) do # every second
      puts
      exchange.publish(10+rand(10), :routing_key => keys[rand(2)])
    end

    # match against one dot-separated item
    channel.queue("us stocks").bind(exchange, :key => "stock.us.*").subscribe do |price|
      puts "us stock price [#{price}]"
    end

    # match against multiple dot-separated items
    channel.queue("all stocks").bind(exchange, :key => "stock.#").subscribe do |price|
      puts "all stocks: price [#{price}]"
    end

    # require exact match
    channel.queue("only dax").bind(exchange, :key => "stock.de.dax").subscribe do |price|
      puts "dax price [#{price}]"
    end
  end
end
