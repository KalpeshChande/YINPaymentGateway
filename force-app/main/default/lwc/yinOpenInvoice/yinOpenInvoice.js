import { LightningElement,api } from 'lwc';
import getOpenInvoice from '@salesforce/apex/YINMakePaymentController.getOpenInvoice';
import createPaymentRecordAndRazorPayLink from '@salesforce/apex/YINMakePaymentController.createPaymentRecordAndRazorPayLink';
import updateLedgerOpenInvoice from '@salesforce/apex/YINMakePaymentController.updateLedgerOpenInvoice';
import LightningAlert from 'lightning/alert';

export default class YinOpenInvoice extends LightningElement {
    @api accountId;
    @api amount;
    openInvoiceLedger = [];
    openInvoiceLedgerVirtual = [];
    currentCheckIndex = 0;
    payingAmount = 0;
    isLoading = false;
    @api overDueAmount;

    
    async connectedCallback(){
        console.log('accountId ',this.accountId);
        let openInvoices = await getOpenInvoice({accountId:this.accountId});
        // formating Date to DD-MM-YYYY
        openInvoices = openInvoices.map(ele=>{
            ele.Posting_Date__c = ele.Posting_Date__c?this.formatDate(ele.Posting_Date__c):'';
            ele.Due_Date__c = ele.Due_Date__c?this.formatDate(ele.Due_Date__c):'';
            return ele;
        })
        this.openInvoiceLedgerVirtual = openInvoices;
        
        console.log('openInvoiceLedger ',openInvoices);
        this.refreshTable();
    }

    formatDate(inputDate) {
        // Split the input date string by '-' separator
        let parts = inputDate.split('-');
        let formattedDate = '';
        if(parts){
          formattedDate = parts[2] + '-' + parts[1] + '-' + parts[0];
        }
        
        return formattedDate;
    }
    
    handleCheck(event){
        console.log('Checked ',event.target.checked);
        let index = event.target.dataset.itemindex;
        if(index!=-1){
            if(event.target.checked){
                this.currentCheckIndex = isNaN(event.target.dataset.index)?0:Number(event.target.dataset.index);
                console.log('this.currentCheckIndex true',this.currentCheckIndex);
                this.refreshTable();
                this.payingAmount = this.payingAmount + this.openInvoiceLedgerVirtual[index].Remaining_Amount__c;
            }else{
                this.currentCheckIndex = this.currentCheckIndex - 1;
                console.log('this.currentCheckIndex false',this.currentCheckIndex);
                this.refreshTable();
                this.payingAmount = this.payingAmount - this.openInvoiceLedgerVirtual[index].Remaining_Amount__c;
            }
        }
    }

    async handlePay(){
        try {
            this.isLoading = true;
            // razorpay amount is in cents 
            let razorPayAmount = this.payingAmount * 100;
            let paymentRec = {amount:razorPayAmount,currency:'INR'};
            // create payment link and link it with Invoice
            let params = {accountId:this.accountId,recordId:'',paymentRecordTypeName:'Invoice'}
            console.log('paymentRec ',JSON.stringify(paymentRec));
            console.log('params ',JSON.stringify(params));
            let paymentRecordAndLink = await createPaymentRecordAndRazorPayLink({payment:JSON.stringify(paymentRec),params:JSON.stringify(params)});
            console.log('Payment Record ',paymentRecordAndLink);
            let invoiceLedgerRecordSelected = [];
            Array.from(this.template.querySelectorAll('[data-name="check"]')).map(ele=>{
                console.log('ele ',ele.checked,' value ',ele.value);
                if(ele.checked){
                    invoiceLedgerRecordSelected.push(ele.value);
                }
            });
            console.log('paymentRecordAndLink.sfdcPaymentRecord.Id ',paymentRecordAndLink.sfdcPaymentRecord.Id);
            console.log('invoiceLedgerRecordSelected ',JSON.stringify(invoiceLedgerRecordSelected));
            if(invoiceLedgerRecordSelected.length > 0){
            let updateLedgerRecordsResult = await updateLedgerOpenInvoice({records:JSON.stringify(invoiceLedgerRecordSelected),paymentId:paymentRecordAndLink.sfdcPaymentRecord.Id});
                if(updateLedgerRecordsResult=='Success'){
                    this.isLoading = false;
                    location.replace(paymentRecordAndLink.short_url);
                }else{
                    console.log('Failed to update ledger records ',invoiceLedgerRecordSelected);
                }
            }else{
                console.log('No Ledger Selected');
            }
            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            console.log('error ',error);
            console.log('error ',error.message);
            
        }

    }

    handleClick(event){
        this.dispatchEvent(new CustomEvent("cancel",{detail:true}));
    }

    refreshTable(){
        let index = 0;
        this.currentCheckIndex = isNaN(this.currentCheckIndex)?0:Number(this.currentCheckIndex);
        try {
            this.openInvoiceLedger = this.openInvoiceLedgerVirtual.map(ele=>{
            index++;
            return {
                index:index,
                disable: this.currentCheckIndex+1 != index && this.currentCheckIndex != index,
                ...ele
            }
        });
        } catch (error) {
            console.log('error ',error);
            console.log('error ',error.message);
            this.showAlert(error.body.message ,'error','Error');
        }
        console.log('openInvoiceLedger :',JSON.parse(JSON.stringify(this.openInvoiceLedger)));
    }
    async showAlert(message,theme,label){
        await LightningAlert.open({
            message: message,
            theme: theme, 
            label: label, 
        });
    }
}