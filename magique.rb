module Magique
  def self.backend
    @backend
  end

  def self.backend=(backend)
    @backend = backend
  end

  class Processor
    def self.start(concurrency = 1)
      concurrency.times { |n| new("Processor #{n}")}
    end

    def initialize(name)
      thread = Thread.new do
        loop do
          payload = Magique.backend.pop
          worker_class = payload[:worker]
          worker_class.new.perform(*payload[:args])
        end
      end

      thread.name = name
    end
  end

  module Worker
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def perform_now(*args)
        new.perform(*args)
      end

      def perform_async(*args)
        # Args sind hier in dem Fall die URLs
        Magique.backend.push(worker: self, args: args)
        # Thread.new { new.perform(*args) }
      end
    end

    def perform(*)
      raise NotImplementedError
    end
  end
end