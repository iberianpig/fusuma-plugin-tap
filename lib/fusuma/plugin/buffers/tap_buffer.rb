# frozen_string_literal: true

module Fusuma
  module Plugin
    module Buffers
      # manage events and generate command
      class TapBuffer < Buffer
        DEFAULT_SOURCE = 'libinput_tap_parser'
        DEFAULT_SECONDS_TO_KEEP = 0.1

        def config_param_types
          {
            'source': [String]
          }
        end

        # clear old events
        def clear_expired(*)
          clear if @events.any? { |e| ended?(e) }
        end

        # @param event [Event]
        # @return [NilClass, TapBuffer]
        def buffer(event)
          return unless (event&.tag == source) || (event&.tag == 'libinput_gesture_parser')

          # NOTE: need to set `begin` event at first of buffer
          clear && return unless bufferable?(event)

          @events.push(event)
          self
        end

        # return [Integer]
        def finger
          @events.map { |e| e.record.finger }.max
        end

        def empty?
          @events.empty?
        end

        def bufferable?(event)
          case event.record.status
          when 'end'
            true
          when 'begin'
            if empty?
              true
            else
              false
            end
          when 'keep', 'touch', 'hold', 'release', 'move'
            if empty?
              false
            else
              true
            end
          when 'update' # libinput_gesture_parser
            if empty?
              false
            else
              true
            end
          else
            raise "Unexpected status: #{event.record.status}"
          end
        end

        def present?
          !empty?
        end

        def select_by_events
          return enum_for(:select) unless block_given?

          events = @events.select { |event| yield event }
          self.class.new events
        end

        def ended?(event)
          event.record.status == 'end'
        end

        def begin?(event)
          event.record.status == 'begin'
        end
      end
    end
  end
end
