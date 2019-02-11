require 'fusuma/vector'

module Fusuma
  module Vectors
    # vector data
    class TapVector < BaseVector
      TYPE = 'tap'.freeze
      GESTURE = 'tap'.freeze

      BASE_INTERVAL   = 0.1

      def initialize(finger, status)
        @finger = finger.to_i
        @status = status
      end
      attr_reader :finger, :status

      def enough?
        MultiLogger.debug(self)
        released? && enough_interval?
      end

      private

      def released?
        status == 'pressed'
      end

      def enough_interval?
        return true if first_time?
        return true if (Time.now - self.class.last_time) > interval_time

        false
      end

      def first_time?
        !self.class.last_time
      end

      def interval_time
        @interval_time ||= BASE_INTERVAL * Config.interval(self)
      end

      class << self
        attr_reader :last_time

        def generate(event_buffer:)
          return if event_buffer.gesture != GESTURE
          return if Generator.prev_vector && Generator.prev_vector != self

          new(event_buffer.finger, event_buffer.events.last.record.status).tap do |v|
            return nil unless v.enough?

            Generator.prev_vector = self
          end
        end
      end
    end
  end
end
