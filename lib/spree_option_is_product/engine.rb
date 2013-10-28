module SpreeOptionIsProduct
  class Engine < Rails::Engine
    engine_name 'spree_option_is_product'

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    config.to_prepare &method(:activate).to_proc
  end
end

