# frozen_string_literal: true

# require 'fusuma/plugin/detectors/detector.rb'

module Fusuma
  module Plugin
    module Detectors
      # Detect tap event
      class TapDetector < Detector
        BUFFER_TYPE = 'tap'
        GESTURE_RECORD_TYPE = 'tap'

        BASE_INTERVAL = 0.5
        BASE_HOLDING_TIME = 0.1
        BASE_TAP_TIME = 1

        # @param buffers [Array<Buffer>]
        # @return [Event] if event is detected
        # @return [NilClass] if event is NOT detected
        def detect(buffers)
          buffer = buffers.find { |b| b.type == BUFFER_TYPE }

          return if buffer.empty?

          finger = buffer.finger

          holding_time = buffer.events.last.time - buffer.events.first.time

          direction = if hold?(buffer, holding_time)
                        'hold'
                      elsif tap?(buffer, holding_time)
                        'tap'
                      end

          return if direction.nil?

          buffer.clear

          index = create_index(finger: finger, direction: direction)

          return unless enough?(index: index, direction: direction)

          create_event(record: Events::Records::IndexRecord.new(index: index))
        end

        # @return [Config::Index]
        def create_index(finger:, direction:)
          Config::Index.new(
            [
              Config::Index::Key.new(direction),
              Config::Index::Key.new(finger.to_i)
            ]
          )
        end

        def hold?(buffer, holding_time)
          return false if holding_time < 1

          return true if buffer.finger == 4

          true if buffer.events.any? { |e| e.record.status == 'hold' }
        end

        def tap?(buffer, holding_time)
          return false if holding_time > 0.15

          tap_released?(buffer)
        end

        def tap_released?(buffer)
          touch_num = buffer.events.count { |e| (e.record.status =~ /begin|touch/) }
          release_num = buffer.events.count { |e| e.record.status =~ /release|end/ }
          MultiLogger.debug(touch_num: touch_num, release_num: release_num)

          case buffer.finger
          when 1
            touch_num == release_num
          when 2
            touch_num == release_num + 1
          when 3
            touch_num == release_num + 1
          when 4
            touch_num > 0 && release_num > 0
          else
            false
          end
        end

        private

        def enough?(index:, direction:)
          enough_interval?(index: index, direction: direction)
        end

        def enough_interval?(index:, direction:)
          return true if first_time?
          return true if (Time.now - @last_time) > interval_time(index: index, direction: direction)

          false
        end

        def interval_time(index:, direction:)
          @interval_time ||= {}
          @interval_time[index.cache_key] ||= begin
                               keys_specific = Config::Index.new [*index.keys, 'interval']
                               keys_global = Config::Index.new ['interval', direction]
                               config_value = Config.search(keys_specific) ||
                                              Config.search(keys_global) || 1
                               BASE_INTERVAL * config_value
                             end
        end
      end
    end
  end
end
