import { LightningElement,api, track,wire } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
//import security from '@salesforce/resourceUrl/resource';
import getSecurityDeposit from '@salesforce/apex/YINSecurityDepositGet.getSecurityDeposit';
import saveSecurityDeposit from '@salesforce/apex/YINSecurityDepositSave.saveSecurityDeposit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status__c from '@salesforce/schema/YIN_Security_Deposit__c.Status__c';

export default class YinSecurityDepositIncreaseCmp extends NavigationMixin(LightningElement) {

@api recordId;
   @track securityWrap={};
   @track status = [];
   showLoading = false;
   @track aadharVerificationParam = {sdId:'',emailId:'',phoneNo:'',module:'',erpCustomerCode:''};


   @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Status__c })
  propertyOrFunction1({ error, data }) {
    if (data) {
      this.status = data.values;
    }

  };
    renderedCallback() {
        /*
        Promise.all([
            loadStyle(this, security + '/resource/security.css'),
      ]).then(() => { /* callback */   //}); */
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

      connectedCallback(){
        this.showLoading=true;
      this.getSecurityDep();
      this.showLoading=false;
      }

        getSecurityDep(){
            getSecurityDeposit()
            .then((data)=>{
            this.securityWrap=data;
            console.log('data is',this.securityWrap);   
            if(this.securityWrap.status=='Failed'){
              this.showToastmessage('Error','Please Make Payment', 'Error');
            } 
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
            if (field == 'Request for Increase') {
                this.securityWrap.increaseAmount = value;
                console.log('increase req',this.securityWrap.increaseAmount);
                this.securityWrap.balanceAmount = Number(this.securityWrap.availableSD) + Number(this.securityWrap.increaseAmount);
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

          handleNavigation(sdId){
            console.log('sdId>>>>'+sdId);
            let compDetails = {
                componentDef: "c:yinEnterAadhaarVerificationCmp",
                attributes: {
                securityId:sdId,    
                module:'securityDeposit'
                }
            }
            let encodedComponentDef = btoa(JSON.stringify(compDetails));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
          attributes: {
           url: '/one/one.app#' + encodedComponentDef
         }
        }) 
         }

        handleClick(event){
          this.showLoading = true;
            let flag = true;
            if (this.securityWrap.increaseAmount == '' || this.securityWrap.increaseAmount == null) {
                flag = false;
                this.showToastmessage('Error','Please Enter Increase Amount', 'Error');
                this.showLoading = false;
              }
              if (flag) {
            saveSecurityDeposit({ wrapperData: JSON.stringify(this.securityWrap) })
              .then(result => {
                console.log('results>>>>',result);
                if (result.id != null) {
                  if (result.resultwrap == 'success') {
                    this.showLoading = false;
                    this.showToastmessage('Success','Security Deposit Saved Successfully' , 'Success');
                    this.handleNavigation(result.id,result.emailId,result.phoneNumber,result.erpCustomerCode);
                  }
                }
            })
        }
        }
        handleNavigation(sdId,emailId,phoneNo,erpCode){
          console.log('ERP Code:',erpCode);
          this.aadharVerificationParam = {sdId:sdId,emailId:emailId,phoneNo:phoneNo,module:'securityDeposit',erpCustomerCode:erpCode};
          }
}