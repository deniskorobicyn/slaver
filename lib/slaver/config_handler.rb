module Slaver
  class ConfigHandler
    include Singleton

    attr_accessor :current_config
    attr_reader :block, :saved_block, :saved_config

    def for_config(config_name)
      prepare(config_name)
    end

    def save_last_config
      @saved_config ||= @current_config
      @saved_block ||= @block
      @block = false
    end

    def clear_config
      @block = @saved_block if @saved_block
      @saved_block = nil
      @current_config = @block && @saved_config
      @saved_config = nil
    end

    def within_block?
      !!@block
    end

    def run_on(config_name)
      with_config(config_name) do
        keep_block do
          yield
        end
      end
    end

    private

    def with_config(config_name)
      last_config = @current_config
      @current_config = config_name

      begin
        yield
      ensure
        @current_config = last_config
      end
    end

    def keep_block
      last_block = @block
      @block = true

      begin
        yield
      ensure
        @block = last_block
      end
    end

    def prepare(config_name)
      config_name = config_name.to_s

      return config_name if ::ActiveRecord::Base.configurations[config_name].present?

      config_name = "#{Rails.env}_#{config_name}"

      if (::ActiveRecord::Base.configurations[config_name]).blank?
        if Rails.env.production?
          raise ArgumentError, "Can't find #{config_name} on database configurations"
        else
          config_name = Rails.env
        end
      end

      config_name
    end
  end
end
