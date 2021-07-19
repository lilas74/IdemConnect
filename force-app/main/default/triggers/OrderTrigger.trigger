/**
 * Created by lilas on 19/07/2021.
 *
 */

trigger OrderTrigger on Order (before insert, before update, after insert, after update) {
if(trigger.isBefore && trigger.isInsert){
    OrderVerificationClass.OrderActivationPrevention(Trigger.new);
}
}