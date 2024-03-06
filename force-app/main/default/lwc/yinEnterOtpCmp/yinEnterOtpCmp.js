/**
 * @description       : 
 * @author            : Amol Patil/amol.patil@skinternational.com
 * @group             : 
 * @last modified on  : 25-01-2024
 * @last modified by  : Amol Patil/amol.patil@skinternational.com
**/
import { LightningElement, api, track } from 'lwc';
import otpVerification from '@salesforce/apex/YINSecurityDepositOtpVer.otpVerification';
import callPaymentGateway from '@salesforce/apex/YINSecurityDepositPaymentGateway.callPaymentGateway';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class YinEnterOtpCmp extends NavigationMixin(LightningElement) {
  @api securityrecId;
  @api access1;
  @api aadharNo;
  @api module2;
  showLoading = false;
  ///For Amol Module
  @api email;
  @api phone;
  @track email1 = '';
  @track phone1 = '';
  //for Amol Module
  @track securityrecId1 = '';
  @track access2 = '';
  @track aadharNo1 = '';
  @track otpNumber = '';
  @track module3 = '';

  connectedCallback() {
    //console.log('Security Id', this.securityrecId);
    this.securityrecId1 = this.securityrecId;
    this.access2 = this.access1;
    this.aadharNo1 = this.aadharNo;
    //console.log('Access tokan in Otp Form', this.access1);
    console.log('securityrecId>>>>>', this.securityrecId);
    console.log('securityrecId>>>>>', this.securityrecId1);
    this.module3 = this.module2;
    //For Amol Module
    this.email1 = this.email;
    this.phone1 = this.phone1;
    //For Amol Module
  }
  handleChange(event) {
    let value = event.target.value;
    let field = event.target.name;
    this.otpNumber = value;
    //console.log('value is', value);
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
  handleReset(event) {
    this.otpNumber = null;
  }
  /*
   navigateToWebPage(url1) {
     this[NavigationMixin.Navigate]({
         "type": "standard__webPage",
         "attributes": {
             "url": url1
         }
     });
 }
  */
  handleClick(event) {
    this.showLoading = true;
    otpVerification({ recordId: this.securityrecId1, otpNumber: this.otpNumber, accessTokan: this.access2, aadharNumber: this.aadharNo1, module: this.module3, email: this.email1, phone: this.phone1 })
      .then(data => {
        if (data.status == 'Success') {
          this.showToastmessage('Success', 'OTP has been verified successfully.', 'Success');
          if (this.module3 == 'securityDeposit') {
            callPaymentGateway({ recordId: this.securityrecId1 })
              .then((data) => {
                if (data.result == 'success') {
                  // window.open(data.url);   
                  window.location.href = data.url;
                  this.showLoading = false;
                }
              })
          } else {
            this.showLoading = false;
            this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                recordId: this.securityrecId1,
                objectApiName: 'ObjectApiName',
                actionName: 'view'
              }
            });
          }
        }
        else if (data.status == 'error') {
          this.showLoading = false;
          this.showToastmessage('Error', 'OTP verification has been failed', 'Error');
        }
      })
  }
}