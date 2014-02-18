Spree::OptionType.class_eval do
  scope :product_based, -> { where :product_based => true }
  scope :optional, -> { where optional: true }
  scope :mandatory, -> { where optional: false }

  def price_of_first_option
    option_values.first.try :price
  end
end
