defmodule QuestApiV21.HostGuardian do
  use Guardian, otp_app: :quest_api_v21
  alias QuestApiV21.Repo
  alias QuestApiV21.Organizations.Organization

  def subject_for_token(host, _claims) do
    # Fetch organization IDs associated with the host
    organization_ids = fetch_organization_ids_for_host(host)

    # Add organization IDs to the claims
    claims = Map.put(_claims, "organization_ids", organization_ids)
    {:ok, to_string(host.id), claims}
  end

  defp fetch_organization_ids_for_host(host) do
    Repo.all(
      from o in Organization,
      join: ho in assoc(o, :hosts),
      where: ho.id == ^host.id,
      select: o.id
    )
  end

  def resource_from_claims(claims) do
    # Log the claims
    IO.inspect(claims, label: "Decoded JWT Claims")

    # Assuming the claim has a subject ("sub") that corresponds to a Host id
    # Fetch the Host from the database or cache
    case QuestApiV21.Hosts.list_hosts(claims["sub"]) do
      nil -> {:error, :host_not_found}
      host -> {:ok, host}
    end
  end
end
