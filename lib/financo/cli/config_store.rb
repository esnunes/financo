# frozen_string_literal: true

require "yaml"
require "fileutils"

require "financo/cli/config"

module Financo
  module CLI
    class ConfigStore
      def initialize(base_dir)
        @base_dir = base_dir
      end

      def load(id)
        name = filename(id)

        FileUtils.touch(name)

        data = File.open(name) { |f| YAML.safe_load(f) } || {}
        data["id"] ||= id
        data["retention_days"] ||= 31
        data["loaded_at"] ||= 0

        Config.new(*data.values_at("id", "checking", "loaded_at", "retention_days"))
      end

      def save(id, config)
        File.open(filename(id), "w") { |f| f.write(config.to_yaml) }
      end

      private

      def filename(id)
        File.join(@base_dir, "config-#{id}.yaml")
      end
    end
  end
end
