enum OrderStatusEnum {
  fraudReview,
  omsBackOrder,
  backOrdered,
  cancelled,
  returned,
  shipped,
  readyForPickup,
  processing,
  delivered,
  customerPickedUp,
  unknown,
}

String? getOrderStatusToDisplay(OrderStatusEnum orderStatusEnum){
  switch(orderStatusEnum){
    case OrderStatusEnum.fraudReview:
      return 'Fraud Review';
    case OrderStatusEnum.omsBackOrder:
      return 'Oms Back Order';
    case OrderStatusEnum.backOrdered:
      return 'Back Ordered';
    case OrderStatusEnum.cancelled:
      return 'Cancelled';
    case OrderStatusEnum.returned:
      return 'Returned';
    case OrderStatusEnum.shipped:
      return 'Shipped';
    case OrderStatusEnum.readyForPickup:
      return 'Ready for Pickup';
    case OrderStatusEnum.processing:
      return 'Processing';
    case OrderStatusEnum.delivered:
      return 'Delivered';
    case OrderStatusEnum.customerPickedUp:
      return 'Customer Picked Up';
    case OrderStatusEnum.unknown:
      return null;
  }
}

OrderStatusEnum getOrderStatus(String? orderStatus) {
  switch (orderStatus) {
    case 'fraudreview':
      return OrderStatusEnum.fraudReview;
    case 'omsbackorder':
      return OrderStatusEnum.omsBackOrder;
    case 'backordered':
      return OrderStatusEnum.backOrdered;
    case 'cancelled':
      return OrderStatusEnum.cancelled;
    case 'returned':
      return OrderStatusEnum.returned;
    case 'shipped':
      return OrderStatusEnum.shipped;
    case 'readyforpickup':
      return OrderStatusEnum.readyForPickup;
    case 'processing':
      return OrderStatusEnum.processing;
    case 'delivered':
      return OrderStatusEnum.delivered;
    case 'customerpickedup':
      return OrderStatusEnum.customerPickedUp;
    default:
      return OrderStatusEnum.unknown;

  }
}

// fraudreview
//
// omsbackorder
//
// backordered
//
// cancelled
//
// returned
//
// shipped
//
// readyforpickup
//
// processing
//
// delivered
//
// customerpickedup
