# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/parsers/parser.rb'

module Fusuma
  module Plugin
    module Parsers
      RSpec.describe TapParser do
        describe '#parse_record' do
          before do
            @parser = TapParser.new
          end
          context 'with 1 finger tap' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/1finger-tap.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin release end]
            end
          end
          context 'with 2 finger tap' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/2finger-tap.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin touch release end]
            end
          end

          context 'with 3 finger tap' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/3finger-tap.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin touch touch release release end]
            end
          end

          context 'with 1 finger hold' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/1finger-hold.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin hold end]
            end
          end
          context 'with 2 finger hold' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/2finger-hold.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin touch hold release end]
            end
          end
          context 'with 3 finger hold' do
            before do
              @records = File.readlines('spec/fusuma/plugin/parsers/3finger-hold.txt').map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:status)).to eq %w[begin touch touch hold release release end]
            end
          end
        end
      end
    end
  end
end
