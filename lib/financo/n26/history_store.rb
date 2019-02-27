# frozen_string_literal: true

require "fileutils"
require "yaml"

require "financo/n26/history"

module Financo
  module N26
    class HistoryStore
      def initialize(base_dir)
        @base_dir = base_dir
      end

      def load(id, *args)
        name = filename(id)

        FileUtils.touch(name)
        File.open(name) { |f| History.new(YAML.safe_load(f), *args) }
      end

      def save(id, history)
        File.open(filename(id), "w") { |f| f.write(history.dump) }
      end

      private

      def filename(id)
        File.join(@base_dir, "history-#{id}.yaml")
      end
    end
  end
end
