class ExampleRecurringJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[ExampleRecurringJob] ran at #{Time.current}"
  end
end
