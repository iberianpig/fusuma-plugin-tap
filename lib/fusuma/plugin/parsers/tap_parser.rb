# frozen_string_literal: true

# require 'fusuma/plugin/parsers/parser.rb'
# require 'fusuma/plugin/events/event.rb'

module Fusuma
  module Plugin
    module Parsers
      # parse libinput and generate event
      class TapParser < Parser
        DEFAULT_SOURCE = 'libinput_command_input'

        # @param record [String]
        # @return [Records::Gesture, nil]
        def parse_record(record)
          case record.to_s
          when /POINTER_BUTTON.+(\d+\.\d+)s.*BTN_(LEFT|RIGHT|MIDDLE).*(pressed|released)/
            matched = Regexp.last_match
            # time = matched[1]
            gesture = 'tap'
            finger = case matched[2]
                     when 'LEFT'
                       1
                     when 'RIGHT'
                       2
                     when 'MIDDLE'
                       3
                     end
            status = matched[3]
          else
            return
          end

          direction = Events::Records::GestureRecord::Delta.new(0, 0,
                                                                0, 0)

          Events::Records::GestureRecord.new(status: status,
                                             gesture: gesture,
                                             finger: finger,
                                             direction: direction)
        end

        def tag
          'libinput_gesture_parser'
        end
      end
    end
  end
end
