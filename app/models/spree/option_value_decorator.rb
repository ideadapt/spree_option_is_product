Spree::OptionValue.class_eval do
  belongs_to :variant
  attr_accessible :variant_id, :special_price, :quantity, :default_option

  def is_a_variant?
    !variant_id.blank?
  end
end
