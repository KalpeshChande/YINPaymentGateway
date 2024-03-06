/**
 * @description       : 
 * @author            : Amol Patil/amol.patil@skinternational.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : Amol Patil/amol.patil@skinternational.com
**/
import { LightningElement, api, track } from 'lwc';
import aadharVerification from '@salesforce/apex/YINSecurityDepositAadharVer.aadharVerification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getAadharNumber from '@salesforce/apex/YINSecurityDepositAddharConsent.getAadharNumber';

export default class YinEnterAadhaarVerificationCmp extends NavigationMixin(LightningElement) {


  @api customerCode;
  @track maskedAadhar;
  @track booleandisabled=true;
  @api securityId;
  @track aadharNumber = '';
  @api module;
  @track module1;
  showLoading = false;
  //Amol Component by---Prashant Kumbhar
  @api emailId1;
  @api phoneNo1;
  @track emailId2 = '';
  @track phoneNo2 = '';
 // @track inputboxdisabled=true;
  @track securityId1 = '';
  @track checkboxValue;
  @track isDisabled = true;
  @track isChecked = false;
  hasRender=false;  
 
  /*
  renderedCallback() {
    if(!this.hasRender){
    Promise.all([
        loadStyle(this, customCSS)
    ]);
    this.hasRender=true;
  }
}   */

  connectedCallback() {
    //console.log('customer code:', this.customerCode);
    this.securityId1 = this.securityId;
    this.module1 = this.module;

    this.emailId2 = this.emailId1;
    this.phoneNo2 = this.phoneNo1;
    this.getAadhar();
    

  }

  
  
  @track showComponenet=false;
  @track componentParamter= {
    securityrecId:"",
    access1: "",
    aadharNo: "",
    module2: "",
    email: "",
    phone: ""
  }

  //for CheckBox
  @track value = 'Y';
  @track consentVal = 'N';

  // get options() {
  //   return [
  //     { label: 'I authorize to Verify My Aadhaar', value: 'Y' },

  //   ];
  // }
  @track message='I authorize to Verify My Aadhaar';

  // get selectedValues() {
  //   return this.value.join(',');
  // }

  handleChange1(e) {
    this.value = e.target.value;
    this.isChecked = e.target.checked;
    if (this.value == 'Y' && e.target.checked) {
      //console.log('inside If aadhaar:');
      this.showLoading = true;
      this.consentVal = 'Y';
      this.showLoading = false;
      this.booleandisabled=false;
    }
    else if(!e.target.checked){
      //console.log('inside else aadhaar:');
      this.booleandisabled=true;
      //this.inputboxdisabled=false;

    }
  }

  getAadhar() {
    getAadharNumber({ recordId: this.securityId,erpCustomerCode: this.customerCode, module: this.module1 })
      .then(data => {
        if (data.result == 'success') {
          this.maskedAadhar = data.maskedAadhar;
          this.aadharNumber = data.realAadhar;
          this.isDisabled = false;
          
        }

        if (data.result == 'Fail') {
          this.isDisabled = true;
          this.showToastmessage('Error', 'Aadhaar number is unavailable. Please contact to system administrator.', 'Error');
        }
      })

  }

  //For Check Box

  handleChange(event){
      let value = event.target.value;
      let field = event.target.name;
      this.aadharNumber=value;
      
  } 

  handlereset(event) {
    this.aadharNumber=null;
    this.value = 'Y';
    this.isChecked = false;
    this.booleandisabled = true;

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


  

  handleNavigation(recId, accessTokan, aadhar) {
 

   /* let compDetails = {
      componentDef: "c:yinEnterOtpCmp",
      attributes: {
        securityrecId: recId,
        access1: accessTokan,
        aadharNo: aadhar,
        module2: this.module1,
        email: this.emailId2,
        phone: this.phoneNo2

      }
    }
    let encodedComponentDef = btoa(JSON.stringify(compDetails));
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: '/one/one.app#' + encodedComponentDef
      }
    })
    */

   this.componentParamter= {
      securityrecId: recId,
      access1: accessTokan,
      aadharNo: aadhar,
      module2: this.module1,
      email: this.emailId2,
      phone: this.phoneNo2

    }
  }



  handleClick(event) {
    this.showLoading = true;
    let flag = true;

    if (this.aadharNumber == '' || this.aadharNumber == null) {
      flag = false;
      this.showToastmessage('Error','Please share the consent for Aadhaar authentication.', 'Error');
      this.showLoading = false;
    }

    if (flag) {
    aadharVerification({ recordId: this.securityId, aadharNumber: this.aadharNumber, module: this.module1, consent1: this.consentVal,consentMessage:this.message })
      .then((data) => {
       

        if (data.status == 'success') {

          this.showToastmessage('Success', 'OTP has been sent to registered mobile number.', 'Success');

          this.showLoading = false;

          this.handleNavigation(this.securityId1, data.accessTokanOtp, data.aadhar);

        }

        else if (data.status == 'Consent Not Accepted') {

          this.showToastmessage('Error', 'Consent not accepted', 'Error');
          this.showLoading = false;

        }

        else if (data.status == 'Otp generation fail') {

          this.showToastmessage('Error', 'OTP generation failed.', 'Error');
          this.showLoading = false;

        }


      })
    }
  }



}