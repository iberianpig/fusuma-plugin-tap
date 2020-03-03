# frozen_string_literal: true

# require 'fusuma/plugin/detectors/detector.rb'

module Fusuma
  module Plugin
    module Detectors
      # Detect tap event
      class TapDetector < Detector
        BUFFER_TYPE = 'tap'
        GESTURE_RECORD_TYPE = 'tap'

        FINGERS = [1, 2, 3].freeze
        BASE_INTERVAL = 0.5

        # @param buffers [Array<Buffer>]
        # @return [Event] if event is detected
        # @return [NilClass] if event is NOT detected
        def detect(buffers)
          buffer = buffers.find { |b| b.type == BUFFER_TYPE }

          return if buffer.empty?

          finger = buffer.finger

          direction = if buffer.events.any? { |e| e.record.status == 'hold' }
                        'hold'
                      else
                        touch_num = buffer.events.count { |e| (e.record.status == 'begin') || (e.record.status == 'touch') }
                        release_num = buffer.events.count { |e| e.record.status == 'release' }
                        MultiLogger.info(touch_num: touch_num, release_num: release_num)
                        case finger
                        when 1
                          'tap' if touch_num == release_num
                        when 2
                          'tap' if touch_num == release_num + 1
                        when 3
                          'tap' if touch_num == release_num + 1
                        end
                      end

          return if direction.nil?

          buffer.clear

          index = create_index(finger: finger, direction: direction)

          return create_event(record: Events::Records::IndexRecord.new(index: index)) if enough?(index: index, direction: direction)

          nil
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

        private

        def enough?(index:, direction:)
          MultiLogger.debug(self)
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
