Spree::Product.class_eval do

  scope :kits, -> { joins(:option_types).where(:spree_option_types => { :product_based => true }).uniq }
  has_many :product_options, through: :product_option_types, source: :option_type, conditions: { product_based: true}
  has_many :option_values, through: :product_options

  def master_price(some_price=nil)
    new_price = some_price || self.price
    options_price = product_options.mandatory.map(&:price_of_first_option).sum

    product_options_values = self.product_options.optional.map(&:option_values)

    if options_price
      optional_values_default_pricing = product_options_values.map {|pov| pov.find(&:default_option) }.compact.map(&:price).sum
      new_price += (options_price + (optional_values_default_pricing.nil? ? 0 : optional_values_default_pricing))
    end
    Spree::Money.new(new_price || 0, {:currency => self.currency} )
  end

  def master_client_price
    self.master_price(Spree::Price.where(:variant_id => self.master.id).first.try(:amount))
  end

  def min_quantity_for_part(variant_id)
    option_values.find{|ov| ov.variant_id == variant_id}.try(:quantity) || 0
  end

end
