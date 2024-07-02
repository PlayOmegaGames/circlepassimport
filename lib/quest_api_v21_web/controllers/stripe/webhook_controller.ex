defmodule QuestApiV21Web.WebhookController do
  @behaviour Stripe.WebhookHandler
  alias QuestApiV21.Organizations
  require Logger

  @impl true
  def handle_event(
        %Stripe.Event{
          type: type,
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = _event
      )
      when type in ["customer.subscription.updated", "invoice.payment_succeeded"] do
    Logger.info("Handling event type: #{type} for customer: #{stripe_customer_id}")
    update_subscription_tier(stripe_customer_id, "tier_1")
  end

  @impl true
  def handle_event(
        %Stripe.Event{
          type: "customer.subscription.deleted",
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = _event
      ) do
    Logger.info("Handling event type: customer.subscription.deleted for customer: #{stripe_customer_id}")
    update_subscription_tier(stripe_customer_id, "tier_free")
  end

  @impl true
  def handle_event(%Stripe.Event{type: "invoice.payment_failed"} = _event) do
    Logger.info("Invoice payment failed")
    :ok
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok

  defp update_subscription_tier(stripe_customer_id, tier) do
    Logger.info("Updating subscription tier to #{tier} for customer: #{stripe_customer_id}")

    case Organizations.get_organization_by_stripe_customer_id(stripe_customer_id) do
      nil ->
        Logger.error("Organization not found for customer: #{stripe_customer_id}")
        {:error, :organization_not_found}

      %QuestApiV21.Organizations.Organization{} = organization ->
        case Organizations.update_subscription_tier(organization.id, tier) do
          {:ok, _updated_organization} ->
            Logger.info("Subscription tier updated to #{tier} for organization: #{organization.id}")
            :ok

          {:error, reason} ->
            Logger.error("Failed to update subscription tier to #{tier} for organization: #{organization.id} - Reason: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end
end
