class ProductKit
  base_price: 0
  constructor: () ->
    @set_base_price parseFloat($('#base_price').val(), 10)
    @update_cart_options()
    @update_cart_total() if $("#specs-list").is "*"
    #listens for changes and updates order total
    $('.option_type_select').change (event) =>
      @update_related_fields(event.target)
      @update_cart_total()
      @reset_and_hide_parts_details($(event.target).closest('.cart-option-row'))
    $('.product_option_quantities').change (event) =>
      @update_cart_total()
      @display_extra_parts_details(event.target)

  #Set the base price
  set_base_price: (price)->
    @base_price = price

  #Always gets the initial base price for a kit
  get_base_price: () ->
    return @base_price

  #Update the option fields on sidebar
  update_cart_options: ->
    selects = $('select.option_type_select');
    @update_related_fields(el) for el in selects

  update_related_fields: (el) ->
    el = $(el)
    [oid, selected_option] = [el.attr('id'), el.find(":selected")]
    [price, regular_price, qty] = [parseFloat(selected_option.data('price'), 10), parseFloat(selected_option.data('regular-price'), 10), parseFloat(selected_option.data('qty'), 10)]
    [price_display_element, qty_field] = [$("##{oid}_price_display"), $("##{oid}_quantity")]

    if isNaN(price)
      price = 0
      regular_price = 0 # if price is NaN then regular price is also (e.g. empty option)
      price_display_element.text '--'
    else
      price_display_element.text "$#{price}"

    $("##{oid}_price").val(price).attr('data-regular-price', regular_price)

    if isNaN(qty)
      qty_field.attr('readonly', 'readonly').val(0)
    else
      qty_field.attr 'min', qty
      qty_field.removeAttr('readonly').val(qty)

    $("##{oid}").val(el.val())

  #Update Order total
  update_cart_total: () ->
    current_total = @get_base_price()
    $('.product_option_prices').each (index, element) =>
      qty_field = $(element).siblings('.product_option_quantities')
      quantity = parseInt qty_field.val(), 10
      quantity = if !isNaN(quantity) && quantity > 0 then quantity else qty_field.attr('min')
      qty_field.val(quantity) unless qty_field.attr("readonly")
      item_multiply = parseInt(quantity, 10)
      min_qty = parseInt(qty_field.attr('min'), 10)
      extra_qty = item_multiply - min_qty
      regular_price_sum = parseFloat($(element).attr('data-regular-price')) * extra_qty
      kit_price_sum = (parseFloat($(element).val(), 10) * min_qty)
      current_total += regular_price_sum
      current_total += kit_price_sum
    $('#product-price span.price').text "$" + ( current_total.toFixed(2) )

  display_extra_parts_details: (el) ->
    el = $(el)
    current_qty = el.val()
    min_qty = el.attr('min')

    selected_option = el.siblings('.option_type_select').find(":selected")
    kit_price = selected_option.data('price')
    regular_price = selected_option.data('regular-price')

    row = $(el).closest('.cart-option-row')
    details = if ($('.option_details', row).length > 0) then $('.option_details', row) else $('<div class="option_details"></div>').appendTo(row).hide()

    if current_qty > min_qty
      details.slideDown('fast')
      extra_qty = current_qty - min_qty
      details.text("#{min_qty} @ $#{kit_price} and #{extra_qty} @ $#{regular_price}")
    else
      @reset_and_hide_parts_details(row)

  reset_and_hide_parts_details: (row) ->
    $('.option_details', row).text('').slideUp()


jQuery ->
  $(document).ready ->
    new ProductKit()
    $('.option_type_select').select2(minimumResultsForSearch: -1, width: '65%')

Spree.ready ($) ->
  reset_children_quantity = ->
    parent_rows = $('tbody#line_items tr.master-item')
    parent_rows.each (i, parent_row) ->
      parent_row = $(parent_row)
      value = parent_row.find('input.line_item_quantity').val()
      if value == '0'
        slave_rows = parent_row.nextUntil('tr.master-item', 'tr.slave-item').get()
        $(slave_rows).each (i, row) ->
          $(row).find('input.line_item_quantity').val 0

  if ($ 'form#update-cart').is('*')
    $('form#update-cart a.delete').off 'click' # turn off default handler
    ($ 'form#update-cart a.delete').show().one 'click', ->
      tr = ($ this).parents('.line-item').first()
      tr.find('input.line_item_quantity').val 0
      ($ this).parents('form').first().submit()
      false

    ($ 'form#update-cart').on 'submit', ->
      reset_children_quantity()
