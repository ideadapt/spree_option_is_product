Spree::Api::ShipmentsController.class_eval do
  #Override from Spree API
  def create
    variant = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].to_i

    @shipment = @order.shipments.create(:stock_location_id => params[:stock_location_id])
    #Added extra params
    @order.contents.add(variant, quantity, nil, @shipment, nil, false, params["options"])

    @shipment.refresh_rates
    @shipment.save!

    respond_with(@shipment.reload, :default_template => :show)
  end
end
