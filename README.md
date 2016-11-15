# Custom Stripe subscription email receipts with Mailgun

A basic example app built with Sinatra that uses Stripe's webhook functionality and the [Mailgun Ruby gem](https://github.com/mailgun/mailgun-ruby) to send custom email receipts to customers when the `invoice.payment_succeeded` event is received.

Modify the webhook.rb script and [deploy this on Heroku](https://devcenter.heroku.com/articles/rack) or another service to send email receipts to your Stripe customers. 

![Example receipt](/receipt_html.png)

## Features

* Uses Mailgun's [responsive email templates](http://blog.mailgun.com/transactional-html-email-templates/) for invoices to send nicely formatted receipts. 
* HTML receipts include each invoice line item and totals. If you [pass descriptions](https://stripe.com/docs/api#create_invoiceitem-description) when creating invoice items, they'll each be listed here.
* Sends both text and HTML emails for clients that don't support HTML.

## Getting started

Create and configure a [Mailgun account](https://mailgun.com/signup) to send emails from your domain. You can also just test [for free](https://www.mailgun.com/pricing) and use their sandbox domain until you're ready to configure your own.

Clone this repository:
```
git clone https://github.com/adamjstevenson/stripe-webhook-receipts.git
```

Run `bundle install`

Modify **webhook.rb** and **views/html_email.erb** to add your own domain and site name in place of `SITE-NAME` and `YOUR-DOMAIN.COM`

Obtain your API keys from your [Stripe dashboard](https://dashboard.stripe.com/account/apikeys) and [Mailgun settings](https://mailgun.com/app/domains). Set these as environment variables when running this app. 

## Testing

You can test this locally and run on your machine by passing in the `STRIPE_KEY` and `MAILGUN_KEY` env variables:

```
STRIPE_KEY='sk_test_YOUR-STRIPE-KEY' MAILGUN_KEY='key-YOUR-MAILGUN-KEY' ruby webhook.rb
```

Once this is running locally, you can use a service like [Ngrok](https://ngrok.com) to make the endpoint accessible at a URL like https://abcd1234.ngrok.io/webhook, then add the webhook endpoint in the [Stripe dashboard](https://dashboard.stripe.com/account/webhooks). 

You can find [test cards](https://stripe.com/docs/testing) on Stripe to create test customers and subscriptions. 

## Other notes

By default **webhook.rb** looks for an email address on the customer object. Be sure to either [create customer objects with an email](https://stripe.com/docs/api#create_customer-email) property or modify this to retrieve the email address from somewhere else. 