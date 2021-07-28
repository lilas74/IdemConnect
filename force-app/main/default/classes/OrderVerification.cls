/**
 * Created by lilas on 19/07/2021.
 * @description Class to verify some data on the Order Object
 */

public with sharing class OrderVerification {


    public static void OrderActivationPrevention(List<Order> orders) {
            for(Order order : orders) {
                Id orderId = order.Id;
                List<OrderItem> items = [
                        SELECT Id, UnitPrice, Quantity, OrderId,
                                Order.Status
                        FROM OrderItem
                        WHERE OrderId = :orderId
                ];
                 if(items.size() == 0 && order.Status == 'Activated') {
                     order.Status = 'Draft';
                     order.addError('Please add product to the order before changing status');
                 }
            }
    }
}