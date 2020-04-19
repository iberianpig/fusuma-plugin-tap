#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'
require 'fusuma/device'

class EvemuRecorder
  def initialize(option)
    @gesture_name = option[:gesture_name]
    @overwrite = option[:overwrite]
    @record_command = 'evemu-record'
  end

  def record
    if File.exist?(filepath)
      raise "exist file: #{@filepath}" unless @overwrite
    end

    puts '----DO NOT TOUCH YOUR TRACKPAD----'

    require 'pty'
    require 'timeout'
    PTY.spawn("#{@record_command} /dev/input/#{device_id}") do |r, w, pid|
      w.close_write
      r.sync = true
      log = ''

      begin
        log = r.read_nonblock(100_000)
      rescue IO::EAGAINWaitReadable
        retry
      end

      begin
        Timeout.timeout(5) do
          loop { log += r.getc }
        end
      rescue Timeout::Error
        puts 'cut out device infos'
      end

      file = File.open(filepath, 'w')
      file.puts log
      file.close

      puts Process.kill(:TERM, pid)
      Process.wait(pid)
    end
  end

  private

  def mkdir
    dir = 'spec/fusuma/plugin/parsers/evemu'
    FileUtils.mkdir_p(dir)
  end

  def filepath
    "#{mkdir.first}/#{@gesture_name}"
  end

  def device_id
    Fusuma::Device.available.first.id
  end

  def version
    @version ||= `#{@list_devices} --version`.chomp
  end
end

option = {}
opt = OptionParser.new

opt.on('-f', 'force overwrite record file') do |v|
  option[:overwrite] = v
end

opt.on('-g', '--gesture_name=', 'gesture filename: like 1finger-tap.txt') do |v|
  option[:gesture_name] = v
end

opt.parse!(ARGV)

raise 'require filename -g 1finger-tap.txt' unless option[:gesture_name]

EvemuRecorder.new(option).record
