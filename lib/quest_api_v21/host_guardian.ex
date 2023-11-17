defmodule QuestApiV21.HostGuardian do
  use Guardian, otp_app: :quest_api_v21

  def subject_for_token(resource, _claims) do
    # Assuming `resource` is a Host struct, and it has an `id` field
    {:ok, to_string(resource.id)}
  end


  def resource_from_claims(claims) do
    # Assuming the claim has a subject ("sub") that corresponds to a Host id
    # Fetch the Host from the database or cache
    case QuestApiV21.Hosts.list_hosts(claims["sub"]) do
      nil -> {:error, :host_not_found}
      host -> {:ok, host}
    end
  end
end
