# frozen_string_literal: true

# require 'fusuma/plugin/parsers/parser.rb'
# require 'fusuma/plugin/events/event.rb'

module Fusuma
  module Plugin
    module Parsers
      # parse libinput and generate event
      class TapParser < Parser
        DEFAULT_SOURCE = 'libinput_command_input'

        # TAP_STATE_IDLE = 4,
        #   TAP_STATE_TOUCH,
        #   TAP_STATE_HOLD,
        #   TAP_STATE_TAPPED,
        #   TAP_STATE_TOUCH_2,
        #   TAP_STATE_TOUCH_2_HOLD,
        #   TAP_STATE_TOUCH_2_RELEASE,
        #   TAP_STATE_TOUCH_3,
        #   TAP_STATE_TOUCH_3_HOLD,
        #   TAP_STATE_DRAGGING_OR_DOUBLETAP,
        #   TAP_STATE_DRAGGING_OR_TAP,
        #   TAP_STATE_DRAGGING,
        #   TAP_STATE_DRAGGING_WAIT,
        #   TAP_STATE_DRAGGING_2,
        #   TAP_STATE_DEAD
        STATE = {
          idle: 'TAP_STATE_IDLE',
          holds: %w[
            TAP_STATE_TOUCH_3_HOLD
            TAP_STATE_TOUCH_2_HOLD
            TAP_STATE_HOLD
            TAP_STATE_DEAD
          ],
          touches: %w[
            TAP_STATE_TOUCH_3
            TAP_STATE_TOUCH_2
            TAP_STATE_TOUCH
            TAP_STATE_DEAD
          ],
          releases: %w[
            TAP_STATE_TOUCH_2_RELEASE
            TAP_STATE_TOUCH_2_HOLD
            TAP_STATE_TAPPED
            TAP_STATE_HOLD
            TAP_STATE_DEAD
          ]
        }.freeze

        # @param record [String]
        # @return [Records::Gesture, nil]
        def parse_record(record)
          gesture = 'tap'

          case record.to_s

          # BEGIN
          when /\stap(?:| state):\s.*TAP_STATE_IDLE → TAP_EVENT_TOUCH → TAP_STATE_TOUCH/
            status = 'begin'
            finger = 1

          # TOUCH
          when /\stap(?:| state):\s.*(#{STATE[:touches].join('|')}) → TAP_EVENT_(?:TOUCH|MOTION) → (#{STATE[:touches].join('|')})/

            status = 'touch'

            finger = case Regexp.last_match(2)
                     when 'TAP_STATE_DEAD'
                       if Regexp.last_match(1) == 'TAP_STATE_TOUCH_3'
                         4
                       else
                         0
                       end
                     when 'TAP_STATE_TOUCH_3'
                       3
                     when 'TAP_STATE_TOUCH_2'
                       2
                     when 'TAP_STATE_TOUCH'
                       1
                     end

          # HOLD
          when /\stap(?:| state):\s.*(#{STATE[:touches].join('|')}) → TAP_EVENT_TIMEOUT → (#{STATE[:holds].join('|')})/

            status = 'hold'

            matched = Regexp.last_match

            finger = case matched[2]
                     when 'TAP_STATE_DEAD'
                       4
                     when 'TAP_STATE_TOUCH_3_HOLD'
                       3
                     when 'TAP_STATE_TOUCH_2_HOLD'
                       2
                     when 'TAP_STATE_HOLD'
                       1
                     end
          # KEEP
          when /\sgesture(| state):\s/ # 1.10.4 prints "gesture state: GESTURE_STATE_.*"
            # NOTE: treat the "gesture(| state):" as KEEP
            status = 'keep'
            finger = 0

          # MOVE
          when /\sPOINTER_AXIS\s/, /\sPOINTER_MOTION\s/, /\sTAP_EVENT_PALM\s/
            status = 'move'
            finger = 0

          # RELEASE
          when /\stap(?:| state):\s.*(#{(STATE[:touches] | STATE[:holds]).join('|')}) → TAP_EVENT_RELEASE → (#{STATE[:releases].join('|')})/

            status = 'release'
            matched = Regexp.last_match

            finger = case matched[1]
                     when 'TAP_STATE_DEAD'
                       4
                     when 'TAP_STATE_TOUCH_3', 'TAP_STATE_TOUCH_3_HOLD'
                       3
                     when 'TAP_STATE_TOUCH_2', 'TAP_STATE_TOUCH_2_HOLD'
                       2
                     when 'TAP_STATE_TOUCH', 'TAP_STATE_HOLD'
                       1
                     end

          # END
          when /\stap(?:| state):\s.*(#{STATE[:releases].join('|')}) → TAP_EVENT_(.*) → #{STATE[:idle]}/
            status = 'end'

            matched = Regexp.last_match
            finger = case matched[1]
                     when 'TAP_STATE_DEAD' # NOTE: 2 finger hold -> scroll become  TAP_STATE_DEAD
                       0
                     when 'TAP_STATE_TOUCH_3', 'TAP_STATE_TOUCH_3_HOLD'
                       3
                     when 'TAP_STATE_TOUCH_2', 'TAP_STATE_TOUCH_2_HOLD', 'TAP_STATE_TOUCH_2_RELEASE'
                       2
                     when 'TAP_STATE_TOUCH', 'TAP_STATE_HOLD', 'TAP_STATE_TAPPED'
                       1
                     end
          else
            return
          end

          Events::Records::GestureRecord.new(status: status,
                                             gesture: gesture,
                                             finger: finger,
                                             delta: nil)
        end

        def tag
          'libinput_tap_parser'
        end
      end
    end
  end
end
