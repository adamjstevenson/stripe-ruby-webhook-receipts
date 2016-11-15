require 'sinatra'
require 'stripe'
require 'mailgun-ruby'

# Set your Stripe secret key as an environment variable: https://dashboard.stripe.com/account/apikeys
set :secret_key, ENV['STRIPE_KEY']
Stripe.api_key = settings.secret_key

# Set mailgun API key: https://mailgun.com/app/domains
set :mailgun_key, ENV['MAILGUN_KEY']
mg_client = Mailgun::Client.new settings.mailgun_key

# Listen for a POST to the /webhook endpoint
post "/webhook" do
  # Retrieve the request's body and parse it as JSON
  event_json = JSON.parse(request.body.read)

  # Retrieve the event from Stripe
  @event = Stripe::Event.retrieve(event_json['id'])

  # Only respond to `invoice.payment_succeeded` events
  if @event.type.eql?('invoice.payment_succeeded')
    # Send a receipt for the invoice 
    unless @event.data.object.subscription.nil?
      
      # Retrieve the subscription
      @subscription = Stripe::Subscription.retrieve(id: @event.data.object.subscription, expand: ['customer'])

      # Format the period start and end dates
      @period_start = Time.at(@subscription.current_period_start).getutc.strftime("%m/%d/%Y")
      @period_end = Time.at(@subscription.current_period_end).getutc.strftime("%m/%d/%Y")
      
      # Send an email receipt
      message_params = {
        from: 'EMAIL@YOUR-DOMAIN.COM', # Your domain or Mailgun Sandbox domain
        to: @subscription.customer.email, # Email address of the customer
        subject: 'Your SITE-NAME email receipt',
        text: text_email, 
        html: html_email
      }
      
      # Your domain or Mailgun Sandbox domain (e.g. sandbox123.mailgun.org)
      result = mg_client.send_message('YOUR-DOMAIN.COM', message_params).to_h!
      puts result
    end
  else 
    # Nothing to see here, return a 200
    status 200
  end
end

# Text email
def text_email
  <<-EOF
  Hi there, 

  We received payment for your SITE-NAME.COM subscription. Thank you for being a customer!

  Questions? Please contact support@SITE-NAME.COM.

  =================================================================
  SITE-NAME RECEIPT - SUBSCRIPTION for #{@subscription.customer.id}

  Subscription: #{@subscription.plan.name} plan

  Total: #{format_amount(@event.data.object.amount_due)} #{@subscription.plan.currency}

  Charged to: #{@subscription.customer.sources.first.brand} ending in #{@subscription.customer.sources.first.last4}
  Invoice ID: #{@event.data.object.id}
  Date: #{Time.now.strftime("%m/%d/%Y")}
  For service through: #{@period_start} and #{@period_end}


  SITE-NAME.COM
  3180 18th Street
  San Francisco, CA 94110
  =================================================================

  EOF
end

def html_email
  erb :html_email
end

def format_amount(amount)
  sprintf('$%0.2f', amount.to_f / 100.0).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
end