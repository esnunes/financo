# frozen_string_literal: true

module Financo
  Transaction = Struct.new(
    :id,
    :date,
    :description,
    :comment,
    :account,
    :amount,
    :commodity,
    :exchange_rate,
    :original_commodity,
    :status,
  ) {
    def to_s
      StringIO.open do |s|
        s.puts "#{Time.at(date / 1000).strftime("%Y-%m-%d")} * #{description}"
        s.puts "    ; #{comment}" unless comment.nil? || comment.strip.empty?
        s << "    #{"%-50s" % account} #{amount} #{commodity}"
        s << " {#{exchange_rate} #{original_commodity}}" if original_commodity && commodity != original_commodity
        s.puts
        s.puts "      ; TransactionId: #{id}"

        s.string
      end
    end
  }
end
