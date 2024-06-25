defmodule QuestApiV21.SubscriptionChecker do
  @moduledoc """
  The SubscriptionChecker module handles subscription tier limits for various schemas.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Organizations.Organization

  @doc """
  Checks if the organization can create a new record based on its subscription tier and current count.
  """
  def can_create_record?(organization_id, schema_module, tier_limits) do
    with {:ok, org} <- get_organization(organization_id),
         {:ok, subscription_tier} when not is_nil(subscription_tier) <- get_subscription_tier(org),
         count <- count_records_by_organization(organization_id, schema_module),
         :ok <- check_subscription_limit(subscription_tier, count, tier_limits) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_organization(organization_id) do
    case Repo.get(Organization, organization_id) do
      nil -> {:error, :organization_not_found}
      org -> {:ok, org}
    end
  end

  defp get_subscription_tier(org) do
    case org.subscription_tier do
      nil -> {:error, :no_subscription_tier}
      plan -> {:ok, plan}
    end
  end

  defp count_records_by_organization(organization_id, schema_module) do
    Repo.aggregate(from(q in schema_module, where: q.organization_id == ^organization_id), :count, :id)
  end

  defp check_subscription_limit(subscription_tier, count, tier_limits) do
    case Map.fetch(tier_limits, subscription_tier) do
      {:ok, limit} when count < limit -> :ok
      _ -> {:error, :upgrade_subscription}
    end
  end
end
