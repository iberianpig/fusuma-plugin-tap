# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/events/records/gesture_record.rb'
require 'fusuma/plugin/events/event.rb'
require 'fusuma/plugin/buffers/buffer.rb'

module Fusuma
  module Plugin
    module Buffers
      RSpec.describe TapBuffer do
        before do
          @buffer = TapBuffer.new
          @event_generator = lambda { |time = nil, finger = 1, status = 'begin'|
            Events::Event.new(time: time,
                              tag: 'libinput_tap_parser',
                              record: Events::Records::GestureRecord.new(
                                status: status,
                                gesture: 'tap',
                                finger: finger,
                                direction: nil
                              ))
          }
        end

        describe '#type' do
          it { expect(@buffer.type).to eq 'tap' }
        end

        describe '#buffer' do
          it 'should buffer gesture event' do
            event = @event_generator.call(Time.now)
            @buffer.buffer(event)
            expect(@buffer.events).to eq [event]
          end

          it 'should NOT buffer other event' do
            event = Events::Event.new(tag: 'SHOULD NOT BUFFER', record: 'dummy record')
            @buffer.buffer(event)
            expect(@buffer.events).to eq []
          end
        end

        describe '#clear_expired' do
          it 'should NOT clear any events' do
            time = Time.now
            event1 = @event_generator.call(time,       1, 'begin')
            event2 = @event_generator.call(time + 0.1, 2, 'tap')
            event3 = @event_generator.call(time + 0.2, 1, 'release')
            @buffer.buffer(event1)
            @buffer.buffer(event2)
            @buffer.buffer(event3)

            @buffer.clear_expired(current_time: time + 100)

            expect(@buffer.events).to eq [event1, event2, event3]
          end
        end

        describe '#bufferable?' do
          it 'should buffer first begin event' do
            time = Time.now
            event1 = @event_generator.call(time, 1, 'begin')
            expect(@buffer.bufferable?(event1)).to eq true
          end

          context 'already exists events in buffer' do
            before do
              event2 = @event_generator.call(Time.now, 1, 'begin')
              @buffer.buffer(event2)
            end
            it 'should NOT buffer begin event' do
              event2 = @event_generator.call(Time.now, 1, 'begin')
              expect(@buffer.bufferable?(event2)).to eq false
            end

            it 'should buffer touch event' do
              event2 = @event_generator.call(Time.now, 2, 'touch')
              expect(@buffer.bufferable?(event2)).to eq true
            end

            it 'should buffer release event' do
              event2 = @event_generator.call(Time.now, 1, 'release')
              expect(@buffer.bufferable?(event2)).to eq true
            end

            it 'should NOT buffer end event' do
              event2 = @event_generator.call(Time.now, 1, 'end')
              expect(@buffer.bufferable?(event2)).to eq false
            end
          end
        end

        describe '#source' do
          it { expect(@buffer.source).to eq TapBuffer::DEFAULT_SOURCE }

          context 'with config' do
            around do |example|
              @source = 'custom_event'

              ConfigHelper.load_config_yml = <<~CONFIG
                plugin:
                  buffers:
                    tap_buffer:
                      source: #{@source}
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it { expect(@buffer.source).to eq @source }
          end
        end

        describe '#finger' do
          it 'should return number of fingers in gestures' do
            @buffer.buffer(@event_generator.call(Time.now, 1, 'begin'))
            expect(@buffer.finger).to eq 1
            @buffer.buffer(@event_generator.call(Time.now, 2, 'touch'))
            expect(@buffer.finger).to eq 2
            @buffer.buffer(@event_generator.call(Time.now, 3, 'touch'))
            expect(@buffer.finger).to eq 3
            @buffer.buffer(@event_generator.call(Time.now, 3, 'release'))
            expect(@buffer.finger).to eq 3
          end
        end

        describe '#empty?' do
          context 'no gestures in buffer' do
            before { @buffer.clear }
            it { expect(@buffer.empty?).to be true }
          end

          context 'buffered some gestures' do
            before { @buffer.buffer(@event_generator.call(Time.now, 'begin')) }
            it { expect(@buffer.empty?).to be false }
          end
        end
      end
    end
  end
end
