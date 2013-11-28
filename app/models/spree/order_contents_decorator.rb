Spree::OrderContents.class_eval do

  def add(variant, quantity=1, currency=nil, shipment=nil, price=nil, force_new_line_item=false, options=[])
    line_item = force_new_line_item ? nil : order.find_line_item_by_variant(variant)
    line_item = add_to_line_item(line_item, variant, quantity, currency, shipment, price)
    add_options(options,line_item,currency,shipment) unless options.blank?
    line_item
  end

  private
  # Override from spree's original method to add the `price` argument passed by `add`
  def add_to_line_item(line_item, variant, quantity, currency=nil, shipment=nil, price=nil, parent=nil)
    ::Rails.logger.info("debugi - li  = #{line_item.inspect}\ndebugi - var = #{variant.inspect}\n debugi - qty = #{quantity.inspect}\n debugi - cur = #{currency.inspect}\n debugi - shi = #{shipment.inspect}\n debugi - pri = #{price.inspect}\n debugi - par = #{parent.inspect}\ndebugi- ###################")
    if line_item
      line_item.target_shipment = shipment
      line_item.quantity += quantity.to_i
      line_item.currency = currency unless currency.nil?
      line_item.save
    else
      line_item = Spree::LineItem.new(quantity: quantity)
      line_item.target_shipment = shipment
      line_item.variant = variant
      if currency
        line_item.currency = currency unless currency.nil?
        line_item.price    = price || variant.price_in(currency).amount
      else
        line_item.price    = price || variant.price
      end

      line_item.parent = parent unless parent.nil?
      order.line_items << line_item
      line_item
    end

    order.reload
    line_item
  end

  def add_options(options,parent,currency,shipment)
    options.each do |o|
      ov = Spree::OptionValue.find(o)
      add_to_line_item(nil,ov.variant, ov.quantity, currency, shipment, determine_variant_price(ov), parent)
    end
  end

  def determine_variant_price(option_value)
    if order.user.present? && order.group_order?
      option_value.distributor_price || option_value.variant.price_for_user(order.user)
    else
      option_value.special_price || option_value.variant.price
    end
  end
end
