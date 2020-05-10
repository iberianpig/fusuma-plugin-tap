#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'fusuma/device'

# Generate libinput generator
class LibinputDebugEventsGenerator
  def initialize(evemu_record:)
    @evemu_record = evemu_record
    @gesture_name = Pathname.new(evemu_record).basename
    @list_devices = ENV.fetch('LIBINPUT_LIST_DEVICES', 'libinput list-devices')
    @debug_events = ENV.fetch('LIBINPUT_DEBUG_EVENTS', 'libinput debug-events')
    @libinput_version = ENV.fetch('LIBINPUT_VERSION', 'libinput list-devices')
  end

  def generate_debug_events
    if File.exist?(filepath)
      puts "exist file: #{filepath}"
      return
    end

    require 'pty'
    require 'timeout'

    puts "----#{@gesture_name}--------------"
    puts '----DO NOT TOUCH YOUR TRACKPAD----'
    sleep 3

    options = "--enable-tap --verbose --device=/dev/input/#{device_id}"

    PTY.spawn("#{@debug_events} #{options}") do |r, w, pid|
      w.close_write
      r.sync = true

      begin
        Timeout.timeout(5) do
          loop { print r.getc }
        end
      rescue Timeout::Error
        puts 'cut out device infos'
      end

      command = "evemu-play /dev/input/#{device_id} < #{@evemu_record}"

      begin
        Timeout.timeout(3) do
          Kernel.system(command)
        end
      rescue Timeout::Error
        puts command
      end

      log = ''
      begin
        Timeout.timeout(5) do
          loop { log += r.getc }
        end
      rescue Timeout::Error
        puts 'cut out device infos'
      end

      r.close
      puts log

      file = File.open(filepath, 'w')
      file.puts log
      file.close

      puts Process.kill(:TERM, pid)
      Process.wait(pid)
      sleep 3
    end
  end

  private

  def mkdir
    dir = "spec/fusuma/plugin/parsers/#{version}"
    FileUtils.mkdir_p(dir)
  end

  def filepath
    "#{mkdir.first}/#{@gesture_name}"
  end

  def device_id
    Fusuma::Device.available.first.id
  end

  def version
    raise 'Make rebuild libinput' unless @libinput_version == `#{@list_devices} --version`.chomp

    @libinput_version
  end
end

evemu_records = Dir.glob 'spec/fusuma/plugin/parsers/evemu/*'

evemu_records.each do |evemu_record|
  LibinputDebugEventsGenerator
    .new(evemu_record: evemu_record)
    .generate_debug_events
end
