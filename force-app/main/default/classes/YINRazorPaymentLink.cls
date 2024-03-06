public class YINRazorPaymentLink{
	public boolean accept_partial;
	public Decimal amount;	
	public Decimal amount_paid;	
	public String callback_method;	
	public String callback_url;	
	public String cancelled_at;	
	public String created_at;
	// public String currency;	
	public Customer customer;
	public String description;	
	public String expire_by;	
	public String expired_at;	
	public Decimal first_min_partial_amount;	
	public String id;	
	public Notes notes;
	public Notify notify;
	public String reference_id;	
	public boolean reminder_enable;
	public String short_url;	
	public String status;	
	public String updated_at;	
	public String user_id;
	class customer {
		public String contact;	
		public String email;	
		public String name;	
	}
	class Notes {
		public String policy_name;	
	}
	class Notify {
		public boolean email;
		public boolean sms;
	}
	public static YINRazorPaymentLink parse(String json){
		return (YINRazorPaymentLink) System.JSON.deserialize(json, YINRazorPaymentLink.class);
	}
}