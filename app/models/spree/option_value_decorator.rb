Spree::OptionValue.class_eval do
  belongs_to :variant

  scope :default, -> { where default_option: true }

  delegate :default_stock_state, :default_stock_item, :product, to: :variant, allow_nil: true

  def available
    default_stock_item.nil? ? true : default_stock_item.available?
  end

  def price
    if Spree::User.current && Spree::User.current.distributor?
      return distributor_price unless distributor_price.nil?
    end
    special_price || variant.price
  end
end
