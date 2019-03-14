# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module Financo
  module N26
    # HistoryStore
    class HistoryStore
      def initialize(base_dir: File.join(Dir.pwd, '.financo'))
        @base_dir = base_dir

        FileUtils.mkdir_p(@base_dir, mode: 0o700)
      end

      def load(id)
        path = filename(id)

        FileUtils.touch(path)

        File.open(path, 'r+') do |f|
          data = YAML.safe_load(f) || {}
          data = data.each_with_object({}) { |(k, v), m| m[k.to_sym] = v; }

          History.new(**data)
        end
      end

      def save(id, history)
        File.open(filename(id), 'w') { |f| f.write(history.dump) }
      end

      private

      def filename(id)
        File.join(@base_dir, "history-#{id}.yaml")
      end
    end
  end
end
