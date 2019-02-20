module Fusuma
  module Plugin
    module Parsers
      # parse libinput and generate vector
      class TapParser < Parser
        Gesture = Struct.new(:status, :gesture, :finger, :move_x, :move_y, :zoom, :rotate)

        def initialize(*options)
          @options = options
        end

        # @param event [Event]
        # @return Event
        def parse(event)
          case line = event.record.to_s
          when /POINTER_BUTTON.+(\d+\.\d+)s.*BTN_(LEFT|RIGHT|MIDDLE).*(pressed|released)/
            matched = Regexp.last_match
            time = matched[1]
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

          event.tap do |e|
            e.record = Gesture.new(status, gesture, finger,
                                   move_x.to_f,
                                   move_y.to_f,
                                   zoom.to_f,
                                   rotate.to_f)
          end
        end
      end
    end
  end
end
