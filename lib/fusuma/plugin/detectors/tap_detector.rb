# frozen_string_literal: true

# require 'fusuma/plugin/detectors/detector.rb'

module Fusuma
  module Plugin
    module Detectors
      class TapDetector < Detector
        BUFFER_TYPE = 'gesture'
        GESTURE_RECORD_TYPE = 'tap'

        FINGERS = [1, 2, 3].freeze
        BASE_INTERVAL = 0.5

        # @param buffers [Array<Buffer>]
        # @return [Event] if event is detected
        # @return [NilClass] if event is NOT detected
        def detect(buffers)
          # 空の場合はnilを返す
          # tapイベントが一つでもあれば(pressed/releaseed)
          # vector_recordを作成。directionはtap情報が無いのでとかpressed/releasedくらいしか無い
          buffer = buffers.find { |b| b.type == BUFFER_TYPE }
          buffer = buffer.select_by_events { |event| event.record.gesture == GESTURE_RECORD_TYPE }

          return if buffer.empty?

          finger = buffer.finger

          direction = case buffer.events.last.record.status
                      when 'pressed'
                        'press'
                      when 'released'
                        'release'
                      else
                        MultiLogger.error("unkown status: #{buffer.events.last.record.status}")
                      end
          index = create_index(finger: finger)

          if enough?(index: index, direction: direction)
            return create_event(record: Events::Records::IndexRecord.new(index: index))
          end

          nil
        end

        # @return [Config::Index]
        def create_index(finger:)
          Config::Index.new(
            [
              Config::Index::Key.new(type),
              Config::Index::Key.new(finger.to_i)
            ]
          )
        end

        private

        def enough?(index:, direction:)
          MultiLogger.debug(self)
          enough_interval?(index: index) && released?(direction: direction)
        end

        def released?(direction:)
          direction == 'release'
        end

        def enough_interval?(index:)
          return true if first_time?
          return true if (Time.now - @last_time) > interval_time(index: index)

          false
        end

        def first_time?
          !last_time
        end

        def interval_time(index:)
          @interval_time ||= {}
          @interval_time[index.cache_key] ||= begin
                               keys_specific = Config::Index.new [*index.keys, 'interval']
                               keys_global = Config::Index.new ['interval', type]
                               config_value = Config.search(keys_specific) ||
                                              Config.search(keys_global) || 1
                               BASE_INTERVAL * config_value
                             end
        end
      end
    end
  end
end
