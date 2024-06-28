defmodule QuestApiV21Web.CheckoutController do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Organizations
  alias QuestApiV21Web.JWTUtility
  alias Stripe.Customer

  def create_checkout_session(conn, _params) do
    organization_id = JWTUtility.get_organization_id_from_jwt(conn)
    organization = Organizations.get_organization!(organization_id)

    stripe_customer_id =
      case organization.stripe_customer_id do
        nil ->
          create_stripe_customer(organization)

        id ->
          id
      end

    session_params = %{
      customer: stripe_customer_id,
      payment_method_types: ["card"],
      line_items: [
        %{
          price: "price_1PWM6WJ36pwPxvTOMqo9GZoW",
          quantity: 1
        }
      ],
      mode: "subscription",
      success_url: "https://client-dashboard-v2-zeta.vercel.app/dashboard",
      cancel_url: "https://client-dashboard-v2-zeta.vercel.app/dashboard"
    }

    case Stripe.Checkout.Session.create(session_params) do
      {:ok, session} ->
        case Stripe.Checkout.Session.retrieve(session.id) do
          {:ok, retrieved_session} ->
            json(conn, %{
              url: retrieved_session.url
            })

          {:error, error} ->
            json(conn, %{error: error.message})
        end

      {:error, error} ->
        json(conn, %{error: error.message})
    end
  end

  defp create_stripe_customer(organization) do
    case Customer.create(%{email: organization.email}) do
      {:ok, customer} ->
        case Organizations.update_stripe_customer_id(organization.id, customer.id) do
          {:ok, _organization} ->
            customer.id

          {:error, _changeset} ->
            raise "Failed to update organization with new Stripe customer ID"
        end

      {:error, error} ->
        raise "Failed to create Stripe customer: #{error.message}"
    end
  end
end
