defmodule QuestApiV21Web.CheckoutController do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Organizations
  alias QuestApiV21Web.JWTUtility

  def create_checkout_session(conn, _params) do
    organization_id = JWTUtility.get_organization_id_from_jwt(conn)
    organization = Organizations.get_organization!(organization_id)

    session_params = %{
      customer: organization.stripe_customer_id,
      payment_method_types: ["card"],
      line_items: [
        %{
          price: "price_1PWM6WJ36pwPxvTOMqo9GZoW",  # Replace with your actual price ID
          quantity: 1
        }
      ],
      mode: "subscription",
      success_url: "https://client-dashboard-v2-zeta.vercel.app/dashboard",
      cancel_url: "https://client-dashboard-v2-zeta.vercel.app/dashboard"
    }

    case Stripe.Checkout.Session.create(session_params) do
      {:ok, session} ->
        # Retrieve the session to verify customer ID
        case Stripe.Checkout.Session.retrieve(session.id) do
          {:ok, retrieved_session} ->
            json(conn, %{url: retrieved_session.url,
            #For testing if the stripe customer id is correct
            #customer: retrieved_session.customer
            })

          {:error, error} ->
            json(conn, %{error: error.message})
        end

      {:error, error} ->
        json(conn, %{error: error.message})
    end
  end
end
