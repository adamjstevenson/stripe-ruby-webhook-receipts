# Custom Stripe subscription email receipts using Mailgun and Sinatra

A basic Sinatra example using Stripe's webhook functionality and the Mailgun Ruby gem to send custom email receipts to customers when the `invoice.payment_succeeded` event is received. 

![Example receipt](receipt_email.png)

## Features

* Uses Mailgun's [responsive email templates](http://blog.mailgun.com/transactional-html-email-templates/) for invoices to send nicely formatted receipts. 
* HTML receipts include each invoice line item and totals. If you [pass descriptions](https://stripe.com/docs/api#create_invoiceitem-description) when creating invoice items, they'll each be listed here.
* Sends both text and HTML emails for clients that don't support HTML.

Modify the webhook.rb script and [deploy this on Heroku](https://devcenter.heroku.com/articles/rack) or another service to send email receipts to your Stripe customers. 

## Getting started

1. Create and configure a [Mailgun account](https://mailgun.com/signup) to send emails from your domain. You can also just test [for free](https://www.mailgun.com/pricing) and use their sandbox domain until you're ready to configure your own.

2. Clone this repository:
```
git clone https://github.com/adamjstevenson/stripe-webhook-receipts.git
```

3. Modify **webhook.rb** and **views/html_email.erb** to add your own domain and site name in place of `SITE-NAME` and `YOUR-DOMAIN.COM`

4. Obtain your API keys from your [Stripe dashboard](https://dashboard.stripe.com/account/apikeys) and [Mailgun settings](https://mailgun.com/app/domains). Set these as environment variables when running this app. 

You can run this locally to test with a service like [Ngrok](https://ngrok.io), e.g.

```
STRIPE_KEY='sk_test_YOUR-STRIPE-KEY' MAILGUN_KEY='key-YOUR-MAILGUN-KEY' ruby webhook.rb
```