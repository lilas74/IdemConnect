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
    public static void InactiveAccountWithNoOrder(List<Order> orders) {
        List<Account> accounts = new List<Account>();
        for(Order order : orders) {
            Id accountId = order.AccountId;
            accounts.add([
                    SELECT Id
                    FROM Account
                    WHERE Id =: accountId

            ]);
        }

        for(Account acc : accounts) {
            Id accountId = acc.Id;
            List<Order> ordersAcc = [
                    SELECT Id
                    FROM Order
                    WHERE AccountId =: accountId
            ];
            if(ordersAcc.size()==0){
                acc.Active__c = false;

            }

        }
       update accounts;
    }
    public static void ActivateAccountWithOrder(List<Order> orders) {
        List<Account> accounts = new List<Account>();
        for(Order order : orders) {
            Id accountId = order.AccountId;
            accounts.add([
                    SELECT Id
                    FROM Account
                    WHERE Id =: accountId

            ]);
        }

        for(Account acc : accounts) {
            Id accountId = acc.Id;
            List<Order> ordersAcc = [
                    SELECT Id
                    FROM Order
                    WHERE AccountId =: accountId
            ];
            if(ordersAcc.size()>0){
                acc.Active__c = true;

            }

        }
        update accounts;
    }
}