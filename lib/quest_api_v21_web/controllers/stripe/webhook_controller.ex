defmodule QuestApiV21Web.WebhookController do
  @behaviour Stripe.WebhookHandler
  alias QuestApiV21.Organizations
  require Logger

  @impl true
  def handle_event(
        %Stripe.Event{
          type: type,
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = event
      )
      when type in ["customer.subscription.updated", "invoice.payment_succeeded"] do
    handle_event_with_secret_check(event, fn ->
      Logger.info("Handling event type: #{type} for customer: #{stripe_customer_id}")
      handle_update_subscription_tier(stripe_customer_id, "tier_1", event)
    end)
  end

  @impl true
  def handle_event(
        %Stripe.Event{
          type: "customer.subscription.deleted",
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = event
      ) do
    handle_event_with_secret_check(event, fn ->
      Logger.info(
        "Handling event type: customer.subscription.deleted for customer: #{stripe_customer_id}"
      )

      handle_update_subscription_tier(stripe_customer_id, "tier_free", event)
    end)
  end

  @impl true
  def handle_event(%Stripe.Event{type: "invoice.payment_failed"} = event) do
    handle_event_with_secret_check(event, fn ->
      Logger.info("Invoice payment failed")
      :ok
    end)
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(event), do: :ok

  defp handle_update_subscription_tier(stripe_customer_id, tier, event) do
    if stripe_customer_id && tier do
      try do
        update_subscription_tier(stripe_customer_id, tier)
      rescue
        exception ->
          Logger.error(
            "An error occurred while updating the subscription tier: #{inspect(exception)}"
          )

          {:error, "An internal server error occurred while processing the webhook"}
      end
    else
      Logger.error("Invalid event payload: #{inspect(event)}")
      {:error, "Invalid event payload"}
    end
  end

  defp update_subscription_tier(stripe_customer_id, tier) do
    Logger.info("Updating subscription tier to #{tier} for customer: #{stripe_customer_id}")

    case Organizations.get_organization_by_stripe_customer_id(stripe_customer_id) do
      nil ->
        Logger.error("Organization not found for customer: #{stripe_customer_id}")
        {:error, :organization_not_found}

      %QuestApiV21.Organizations.Organization{} = organization ->
        case Organizations.update_subscription_tier(organization.id, tier) do
          {:ok, _updated_organization} ->
            Logger.info(
              "Subscription tier updated to #{tier} for organization: #{organization.id}"
            )

            :ok

          {:error, reason} ->
            Logger.error(
              "Failed to update subscription tier to #{tier} for organization: #{organization.id} - Reason: #{inspect(reason)}"
            )

            {:error, reason}
        end
    end
  end

  defp handle_event_with_secret_check(event, callback) do
    if webhook_secret_exists?() do
      try do
        case verify_signature(event) do
          :ok ->
            callback.()

          {:error, reason} ->
            Logger.error("Signature verification failed: #{inspect(reason)}")
            {:error, "Signature verification failed"}
        end
      rescue
        exception ->
          Logger.error("An error occurred while processing the webhook: #{inspect(exception)}")
          {:error, "An internal server error occurred while processing the webhook"}
      end
    else
      {:error, "Webhook secret not detected"}
    end
  end

  defp webhook_secret_exists? do
    secret =
      System.get_env("STRIPE_WEBHOOK_SECRET") ||
        Application.get_env(:quest_api_v21, :webhook_secret)

    if secret do
      true
    else
      Logger.error("Webhook secret not detected")
      false
    end
  end

  defp verify_signature(%{headers: headers, payload: payload}) do
    secret =
      System.get_env("STRIPE_WEBHOOK_SECRET") ||
        Application.get_env(:quest_api_v21, :webhook_secret)

    Logger.info("Verifying signature with secret: #{inspect(secret)}")
    Logger.info("Payload: #{inspect(payload)}")
    Logger.info("Headers: #{inspect(headers)}")

    signature_header = List.keyfind(headers, "stripe-signature", 0)
    Logger.info("Signature header: #{inspect(signature_header)}")

    if payload && signature_header do
      case Stripe.Webhook.construct_event(payload, signature_header, secret) do
        {:ok, _event} -> :ok
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, "Missing payload or signature header"}
    end
  end
end
