defmodule QuestApiV21Web.WebhookController do
  @behaviour Stripe.WebhookHandler
  alias QuestApiV21.Organizations
  require Logger

  @impl true
  def handle_event(
        %Stripe.Event{
          type: "invoice.payment_succeeded",
          data: %{object: %Stripe.Invoice{customer: stripe_customer_id}}
        } = _event
      ) do
    Logger.info("Processing invoice.payment_succeeded for customer: #{stripe_customer_id}")

    case Organizations.get_organization_by_stripe_customer_id(stripe_customer_id) do
      nil ->
        Logger.info("Organization not found for customer: #{stripe_customer_id}")
        {:error, :organization_not_found}

      %QuestApiV21.Organizations.Organization{} = organization ->
        case Organizations.update_subscription_tier(organization.id, "tier_1") do
          {:ok, _updated_organization} ->
            Logger.info("Subscription tier updated for organization: #{organization.id}")
            :ok

          {:error, reason} ->
            Logger.info("Failed to update subscription tier: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end

  @impl true
  def handle_event(%Stripe.Event{type: "invoice.payment_failed"} = _event) do
    Logger.info("Invoice payment failed")
    :ok
  end

  @impl true
  def handle_event(
        %Stripe.Event{
          type: type,
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = _event
      )
      when type in ["customer.subscription.updated", "customer.subscription.deleted"] do
    tier = if type == "customer.subscription.deleted", do: "tier_free", else: "tier_1"
    Logger.info("Processing event type: #{type} for customer: #{stripe_customer_id}")

    case Organizations.get_organization_by_stripe_customer_id(stripe_customer_id) do
      nil ->
        Logger.info("Organization not found for customer: #{stripe_customer_id}")
        {:error, :organization_not_found}

      %QuestApiV21.Organizations.Organization{} = organization ->
        case Organizations.update_subscription_tier(organization.id, tier) do
          {:ok, _updated_organization} ->
            Logger.info(
              "Subscription tier updated to #{tier} for organization: #{organization.id}"
            )

            :ok

          {:error, reason} ->
            Logger.info("Failed to update subscription tier to #{tier}: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end

  # Return HTTP 200 for unhandled events and log the event details
  @impl true
  def handle_event(event) do
    Logger.info("Unhandled event: #{inspect(event)}")
    :ok
  end
end
