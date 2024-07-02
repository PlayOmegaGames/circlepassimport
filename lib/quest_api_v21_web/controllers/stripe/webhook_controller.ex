defmodule QuestApiV21Web.WebhookController do
  @behaviour Stripe.WebhookHandler
  alias QuestApiV21.Organizations

  @impl true
  def handle_event(
        %Stripe.Event{
          type: type,
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = _event
      )
      when type in ["customer.subscription.updated", "invoice.payment_succeeded"] do
    update_subscription_tier(stripe_customer_id, "tier_1")
  end

  @impl true
  def handle_event(
        %Stripe.Event{
          type: "customer.subscription.deleted",
          data: %{object: %Stripe.Subscription{customer: stripe_customer_id}}
        } = _event
      ) do
    update_subscription_tier(stripe_customer_id, "tier_free")
  end

  @impl true
  def handle_event(%Stripe.Event{type: "invoice.payment_failed"} = _event) do
    IO.inspect("Invoice payment failed")
    :ok
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok

  defp update_subscription_tier(stripe_customer_id, tier) do
    case Organizations.get_organization_by_stripe_customer_id(stripe_customer_id) do
      nil ->
        IO.inspect("Organization not found for customer: #{stripe_customer_id}")
        {:error, :organization_not_found}

      %QuestApiV21.Organizations.Organization{} = organization ->
        case Organizations.update_subscription_tier(organization.id, tier) do
          {:ok, _updated_organization} ->
            IO.inspect(
              "Subscription tier updated to #{tier} for organization: #{organization.id}"
            )

            :ok

          {:error, reason} ->
            IO.inspect("Failed to update subscription tier to #{tier}: #{reason}")
            {:error, reason}
        end
    end
  end
end
