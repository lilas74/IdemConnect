/**
 * Created by lilas on 19/07/2021.
 *
 */

trigger OrderTrigger on Order (before update, before insert, before delete, after delete) {
	Set<Id> accountIds = new Set<Id>();//Set of all of the account Id from the orders

	if (trigger.isBefore && trigger.isUpdate ) {
		OrderVerification.OrderActivationPrevention(Trigger.new);


	}
	if(Trigger.isDelete) {
		OrderVerification.InactiveAccountWithNoOrder(Trigger.old);
	}


}