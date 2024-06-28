defmodule QuestApiV21Web.WebhookController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Organizations

  @stripe_webhook_secret System.get_env("STRIPE_WEBHOOK_SECRET")
  @verify_stripe_signature Application.compile_env(:quest_api_v21, __MODULE__)[
                             :verify_stripe_signature
                           ]

  def handle(conn, _params) do
    payload = conn.body_params |> Jason.encode!()
    signature = List.first(get_req_header(conn, "stripe-signature"))

    event =
      if @verify_stripe_signature do
        case Stripe.Webhook.construct_event(payload, signature, @stripe_webhook_secret) do
          {:ok, event} -> {:ok, event}
          {:error, _reason} -> {:error, "Invalid signature"}
        end
      else
        Jason.decode(payload)
      end

    case event do
      {:ok, event} ->
        process_event(event)
        send_resp(conn, 200, "Event received")

      {:error, _reason} ->
        send_resp(conn, 400, "Invalid signature")
    end
  end

  defp process_event(%{type: type, data: %{object: object}}) do
    handle_event(type, object)
  end

  defp process_event(%{"type" => type, "data" => %{"object" => object}}) do
    handle_event(type, object)
  end

  defp handle_event("invoice.payment_succeeded", invoice) do
    customer_id = invoice["customer"]
    organization = Organizations.get_organization_by_stripe_customer_id(customer_id)

    case organization do
      nil ->
        :error

      organization ->
        Organizations.update_subscription_tier(organization.id, "tier_1")
    end
  end

  defp handle_event("customer.subscription.created", subscription) do
    customer_id = subscription["customer"]
    organization = Organizations.get_organization_by_stripe_customer_id(customer_id)

    case organization do
      nil ->
        :error

      organization ->
        date = DateTime.utc_now() |> DateTime.truncate(:second)
        Organizations.update_subscription_tier(organization.id, "tier_1")
        Organizations.update_subscription_date(organization.id, date)
    end
  end

  defp handle_event("customer.subscription.updated", subscription) do
    customer_id = subscription["customer"]
    organization = Organizations.get_organization_by_stripe_customer_id(customer_id)

    case organization do
      nil ->
        :error

      organization ->
        Organizations.update_subscription_tier(organization.id, "tier_1")
    end
  end

  defp handle_event("customer.subscription.deleted", subscription) do
    customer_id = subscription["customer"]
    organization = Organizations.get_organization_by_stripe_customer_id(customer_id)

    case organization do
      nil ->
        :error

      organization ->
        Organizations.update_subscription_tier(organization.id, "tier_free")
    end
  end

  defp handle_event(_event_type, _object) do
    :ok
  end
end
