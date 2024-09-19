 Create a checkout session
Once your product is created, you can copy the product ID by clicking on the product options and selecting “Copy ID”.

Now grab your api-key and create a checkout session by sending a POST request to the following endpoint:


getCheckout.sh

getCheckout.js

curl -X POST https://api.creem.io/v1/checkouts \
  -H "x-api-key: creem_123456789"
  -D '{"product_id": "prod_6tW66i0oZM7w1qXReHJrwg"}'
​
3. Redirect user to checkout url
Once you have created a checkout session, you will receive a checkout URL in the response.

Redirect the user to this URL and that is it! You have successfully created a checkout session and received your first payment!


Track payments with a request ID

When creating a checkout-session, you can optionally add a request_id parameter to track the payment. This parameter will be sent back to you in the response and in the webhook events. Use this parameter to track the payment or user in your system.


Set a success URL on the checkout session

After successfully completing the payment, the user will be automatically redirected to the URL you have set on the product creation. You can bypass this setting by setting a success URL on the checkout session request by adding the success_url parameter. The user will always be redirected with the following query parameters:

session_id: The ID of the checkout session
product_id: The ID of the product
status: The status of the payment
request_id: The request ID of the payment that you optionally have sent
​
4. Receive payment data on your Return URL
A return URL will always contain the following query parameters, and will look like the following:

https://yourwebsite.com/your-return-path?checkout_id=ch_1QyIQDw9cbFWdA1ry5Qc6I&order_id=ord_4ucZ7Ts3r7EhSrl5yQE4G6&customer_id=cust_2KaCAtu6l3tpjIr8Nr9XOp&subscription_id=sub_ILWMTY6uBim4EB0uxK6WE&product_id=prod_6tW66i0oZM7w1qXReHJrwg&signature=044bd1691d254c4ad4b31b7f246330adf09a9f07781cd639979a288623f4394c?

You can read more about Return Urls here.

Query parameter	Description
checkout_id	The ID of the checkout session created for this payment.
order_id	The ID of the order created after successful payment.
customer_id	The customer ID, based on the email that executed the successful payment.
subscription_id	The subscription ID of the product.
product_id	The product ID that the payment is related to.
request_id	Optional The request ID you provided when creating this checkout session.
signature	All previous parameters signed by creem using your API-key, verifiable by you.


Return URLs
Understand how to redirect users back to your website after a successful payment.

​
What is a Return/Redirect URL?
Return and Redirect URLs, are urls that your customer will be redirected to, after a successful payment. They contain important information signed by creem, that you can use to verify the payment and the user.

Using these URLs, you can create a seamless experience for your users, by redirecting them back to your website after a successful payment.

You have the optionality to use the information in the URL query parameters, or to use webhooks to receive updates on your application automatically, or both.

​
How to set a Return/Redirect URL

Option 1: Set a success URL on the product creation.

When creating a product, you can optionally add a Return URL. This URL will be used as a default to every payment done to this product, in case you don’t provide other URLs when creating a checkout session or using a payment link.



Option 2: Set a success URL when creating a checkout session

You can bypass the product Return URL by setting a success URL on the checkout session request by adding the success_url parameter.

​
What is included on the Return URL?
A return URL will always contain the following query parameters, and will look like the following:

https://yourwebsite.com?checkout_id=ch_1QyIQDw9cbFWdA1ry5Qc6I&order_id=ord_4ucZ7Ts3r7EhSrl5yQE4G6&customer_id=cust_2KaCAtu6l3tpjIr8Nr9XOp&subscription_id=sub_ILWMTY6uBim4EB0uxK6WE&product_id=prod_6tW66i0oZM7w1qXReHJrwg&signature=044bd1691d254c4ad4b31b7f246330adf09a9f07781cd639979a288623f4394c?

Query parameter	Description
checkout_id	The ID of the checkout session created for this payment.
order_id	The ID of the order created after successful payment.
customer_id	The customer ID, based on the email that executed the successful payment.
subscription_id	The subscription ID of the product.
product_id	The product ID that the payment is related to.
request_id	Optional The request ID you provided when creating this checkout session.
signature	All previous parameters signed by creem using your API-key, verifiable by you.
​
How to verify Creem signature?
To verify the signature, you can use the following code snippet:


export interface RedirectParams {
  request_id?: string | null;
  checkout_id?: string | null;
  order_id?: string | null;
  customer_id?: string | null;
  subscription_id?: string | null;
  product_id?: string | null;
}

  private generateSignature(params: RedirectParams, apiKey: string): string {
    const data = Object.entries(params)
      .map(([key, value]) => `${key}=${value}`)
      .concat(`salt=${apiKey}`)
      .join('|');
    return crypto.createHash('sha256').update(data).digest('hex');
  }
In summary, concatenate all parameters and the salt (your API-key) with a | separator, and hash it using SHA256. This will generate a signature that you can compare with the signature provided in the URL.