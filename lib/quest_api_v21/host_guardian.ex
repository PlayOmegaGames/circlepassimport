defmodule QuestApiV21.HostGuardian do
  use Guardian, otp_app: :quest_api_v21
  # Import Ecto Query macros
  import Ecto.Query
  alias QuestApiV21.Repo
  alias QuestApiV21.Organizations.Organization

  def subject_for_token(resource, _claims) do
    # IO.inspect(resource, label: "Resource in subject_for_token")
    {:ok, to_string(resource.id)}
  end

  def build_claims(claims, resource, _opts) do
    # IO.inspect(resource, label: "Resource in build_claims")
    # IO.inspect(claims, label: "Initial claims")

    organization_ids = fetch_organization_ids_for_host(resource)
    # IO.inspect(organization_ids, label: "Organization IDs in build_claims")

    claims = Map.put(claims, "organization_ids", organization_ids)
    # IO.inspect(claims, label: "Claims after adding organization IDs")

    {:ok, claims}
  end

  defp fetch_organization_ids_for_host(host) do
    organization_ids =
      Repo.all(
        from o in Organization,
          join: ho in assoc(o, :hosts),
          where: ho.id == ^host.id,
          select: o.id
      )

    # Logging the fetched organization IDs
    # IO.inspect(organization_ids, label: "Fetched Organization IDs for Host")

    organization_ids
  end

  # For regernating the token after an org is created
  def regenerate_jwt_for_host(host) do
    # Or any base claims you require
    claims = %{}
    {:ok, updated_claims} = build_claims(claims, host, %{})

    Guardian.encode_and_sign(host, updated_claims)
  end

  def resource_from_claims(claims) do
    # IO.inspect(claims, label: "Decoded JWT Claims")

    case QuestApiV21.Hosts.list_hosts(claims["sub"]) do
      nil -> {:error, :host_not_found}
      host -> {:ok, host}
    end
  end
end
