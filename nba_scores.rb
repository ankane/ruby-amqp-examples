#!/usr/bin/env ruby
# encoding: utf-8

# from http://rdoc.info/github/ruby-amqp/amqp/master/file/docs/GettingStarted.textile

require "bundler"
Bundler.setup

require "amqp"

AMQP.start do |connection|
  channel  = AMQP::Channel.new(connection)
  exchange = channel.fanout("nba.scores")

  channel.queue("joe").bind(exchange).subscribe do |payload|
    puts "#{payload} => joe"
  end

  channel.queue("aaron").bind(exchange).subscribe do |payload|
    puts "#{payload} => aaron"
  end

  channel.queue("bob").bind(exchange).subscribe do |payload|
    puts "#{payload} => bob"
  end

  1.times do
    exchange.publish("BOS 101, NYK 89").publish("ORL 85, ALT 88")
  end

  # disconnect & exit after 2 seconds
  EventMachine.add_timer(2) do
    exchange.delete

    connection.close { EventMachine.stop }
  end
end
