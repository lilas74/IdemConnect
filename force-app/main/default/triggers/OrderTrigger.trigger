/**
 * Created by lilas on 19/07/2021.
 *
 */

trigger OrderTrigger on Order (before update, before insert, before delete, after delete) {
	if (trigger.isBefore && trigger.isUpdate ) {
		OrderVerification.OrderActivationPrevention(Trigger.new);


	}
	if(Trigger.isDelete) {
		OrderVerification.InactiveAccountWithNoOrder(Trigger.old);
	}


}