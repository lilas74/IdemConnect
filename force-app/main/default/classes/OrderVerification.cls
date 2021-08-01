/**
 * Created by lilas on 19/07/2021.
 * @description Class to verify some data on the Order Object
 */

public with sharing class OrderVerification {
	/**
	 * @description When the "Status" field changes from "Draft" to "Active" status,
	 * a trigger process is triggered to call an apex class which verifies that the order in question has products.
	 * If the order does not has no products,
	 * the modification is blocked and an error message prompting the user to enter products before activating the order is displayed
	 *
	 * @param orders from the trigger
	 */

	public static void OrderActivationPrevention(List<Order> orders) {
		for (Order order : orders) {
			Id orderId = order.Id;
			List<OrderItem> items = [
					SELECT Id, UnitPrice, Quantity, OrderId, Order.Status
					FROM OrderItem
					WHERE OrderId = :orderId
			];
			if (items.size() == 0 && order.Status == 'Activated') {
				order.Status = 'Draft';
				order.addError('Please add product to the order before changing status');
			}
		}
	}
	/**
	 * @description When an order is deleted, a trigger is fired on deletion to call an apex class
	 * that checks that there is no other order attached to the account.
	 * If there is no other order attached to an account, the Active__c box will be unchecked if it has been checked.
	 *
	 * @param orders
	 */
	public static void InactiveAccountWithNoOrder(List<Order> orders) {
		List<Account> accounts = new List<Account>();
		for (Order order : orders) {
			Id accountId = order.AccountId;
			accounts.add([
					SELECT Id
					FROM Account
					WHERE Id = :accountId

			]);
		}

		for (Account acc : accounts) {
			Id accountId = acc.Id;
			List<Order> ordersAcc = [
					SELECT Id
					FROM Order
					WHERE AccountId = :accountId
			];
			if (ordersAcc.size() == 0) {
				acc.Active__c = false;

			}

		}
		update accounts;
	}
	/**
	 * @description The order can also be linked to an account. When an order is added to an account, regardless
	 * the status of the order, a field custom "Active" is checked automatically.
	 *
	 * @param accountsIds
	 */
	public static void ActivateAccountWithOrder(Set<Id> accountsIds) {
		List<Account> accounts = [
				SELECT Id, Active__c, (
						SELECT Id
						FROM Orders
				)
				FROM Account
				WHERE Id IN :accountsIds
		];
		for (Account acc : accounts) {
			List<Order> orders = [
					SELECT Id
					FROM Order
					WHERE AccountId = :acc.Id
			];
			if (orders.size() > 0) {
				acc.Active__c = true;
			}
			update acc;
		}
		update accounts;
	}
}