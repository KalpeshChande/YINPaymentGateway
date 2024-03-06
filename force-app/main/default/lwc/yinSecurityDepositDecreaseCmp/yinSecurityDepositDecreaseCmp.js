import { LightningElement, track,wire } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
//import security from '@salesforce/resourceUrl/resource';
import getSecurityDeposit from '@salesforce/apex/YINSecurityDepositGetDecrease.getSecurityDeposit';
import saveSecurityDeposit from '@salesforce/apex/YINSecurityDepositSave.saveSecurityDeposit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status__c from '@salesforce/schema/YIN_Security_Deposit__c.Status__c';

export default class YinSecurityDepositDecreaseCmp extends LightningElement {

    renderedCallback() {
       /*
        Promise.all([
            loadStyle(this, security + '/resource/security.css'),
      ]).then(() => { /* callback */  //}); */
}





        value = 'Draft';
    
        get options() {
            return [
                { label: 'Draft', value: 'Draft' },
                { label: 'Aadhaar Verification In Progress', value: 'Aadhaar Verification In Progress' },
                { label: 'Aadhaar Verification Success', value: 'Aadhaar Verification Success' },
                { label: 'Aadhaar Verification Failed', value: 'Aadhaar Verification Failed' },
                { label: 'Payment In Progress', value: 'Payment In Progress' },
                { label: 'Payment Success', value: 'Payment Success' },
                { label: 'Payment Failed', value: 'Payment Failed' },
                { label: 'Transaction to ERP In Progress', value: 'Transaction to ERP In Progress' },
                { label: 'Transaction to ERP Success', value: 'Transaction to ERP Success' },
                { label: 'Transaction to ERP Failed', value: 'Transaction to ERP Failed' },
                { label: 'Completed', value: 'Completed' },
                { label: 'Closed', value: 'Closed' },
            ];
        }
    
        @track securityWrap={};
   @track status = [];

   @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Status__c })
  propertyOrFunction1({ error, data }) {
    if (data) {
      this.status = data.values;
    }

  };


  connectedCallback(){
    this.getSecurityDep();
        
    }


    getSecurityDep(){

        getSecurityDeposit({recordId:this.recordId}).then((data)=>{
        
        this.securityWrap=data;
        console.log('data is',this.securityWrap);    
        
        })    

    }

    handleChange(event){
        let value = event.target.value;
        let field = event.target.name;

        console.log('In Change Event');
        console.log('Event name',field);
        console.log('Event value',value);
        

        if (field == 'Available Security Deposit') {
            this.securityWrap.availableSD = value;
           
        }
        
        if (field == 'Request for decrease') {
            this.securityWrap.decreaseAmount = value;
            console.log('decrease req',this.securityWrap.decreaseAmount);
            this.securityWrap.balanceAmount = Number(this.securityWrap.availableSD) - Number(this.securityWrap.decreaseAmount);
            
            if(this.securityWrap.balanceAmount <0){
              this.showToastmessage('Error','Balance amount should not less then zero', 'Error');
            }

        }

        if (field == 'Balance Amount') {
            
        }
        if (field == 'Remark') {
            this.securityWrap.remarks = value;
        }
        if (field == 'status') {
            this.securityWrap.status = value;
        }

    }
    
    showToastmessage(title, message, varient) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
          }),
        );
      }
      

      handleClick(event){

        let flag = true;

        console.log('decreae in handlcki',this.securityWrap.decreaseAmount);
        
        if (this.securityWrap.decreaseAmount == '' || this.securityWrap.decreaseAmount == null) {
            flag = false;
            this.showToastmessage('Error','Please Enter decrease Amount', 'Error');
          }

          if(this.securityWrap.balanceAmount <0){
            flag = false;
            this.showToastmessage('Error','Balance amount should not less then zero', 'Error');
          } 

          if (flag) {

        saveSecurityDeposit({ wrapperData: JSON.stringify(this.securityWrap) })
          .then(result => {
            
            if (result.id != null) {
              if (result.resultwrap == 'success') {

                this.showToastmessage('Success','Security Deposit Saved Successfully' , 'Success');
                
               

              }
            }
        })

    }


    }


}