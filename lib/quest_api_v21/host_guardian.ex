defmodule QuestApiV21.HostGuardian do
  use Guardian, otp_app: :quest_api_v21

  def subject_for_token(resource, _claims) do
    # IO.inspect(resource, label: "Resource in subject_for_token")
    {:ok, to_string(resource.id)}
  end

  def build_claims(claims, resource, _opts) do
    # IO.inspect(resource, label: "Resource in build_claims")
    # IO.inspect(claims, label: "Initial claims")

    current_org = resource.current_org_id
    # IO.inspect(organization_id, label: "Organization IDs in build_claims")

    claims = Map.put(claims, "organization_id", current_org)
    # IO.inspect(claims, label: "Claims after adding organization IDs")

    {:ok, claims}
  end

  # For regernating the token after an org is created
  # For regenerating the token after an organization is updated
  def regenerate_jwt_for_host(host) do
    claims = %{}
    {:ok, updated_claims} = build_claims(claims, host, %{})

    # Note: Ensure the module is correctly specified if needed
    Guardian.encode_and_sign(QuestApiV21.HostGuardian, host, updated_claims)
  end

  def resource_from_claims(claims) do
    # IO.inspect(claims, label: "Decoded JWT Claims")

    case QuestApiV21.Hosts.list_hosts(claims["sub"]) do
      nil -> {:error, :host_not_found}
      host -> {:ok, host}
    end
  end
end
