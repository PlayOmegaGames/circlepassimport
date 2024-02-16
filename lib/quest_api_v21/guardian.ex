defmodule QuestApiV21.Guardian do
  use Guardian, otp_app: :quest_api_v21

  # Import Ecto Query macros
  import Ecto.Query
  alias QuestApiV21.Repo
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Guardian

  def subject_for_token(resource, _claims) do
    IO.inspect(resource, label: "Resource in subject_for_token")
    {:ok, to_string(resource.id)}
  end

  def build_claims(claims, resource, _opts) do
    quest_ids = fetch_quest_ids_for_account(resource)
    claims = Map.put(claims, "quest_ids", quest_ids)
    {:ok, claims}
  end

  defp fetch_quest_ids_for_account(account) do
    quest_ids =
      Repo.all(
        from q in Quest,
          join: a in assoc(q, :accounts),
          # Directly use account.id here
          where: a.id == ^account.id,
          select: q.id
      )

    # IO.inspect(quest_ids, label: "Fetched quest IDs for Account")
    quest_ids
  end

  # For regernating the token after an org is created
  def regenerate_jwt_for_account(account) do
    # Or any base claims you require
    claims = %{}
    {:ok, updated_claims} = build_claims(claims, account, %{})

    Guardian.encode_and_sign(account, updated_claims)
  end

  def resource_from_claims(claims) do
    IO.inspect(claims, label: "Decoded JWT Claims")

    case QuestApiV21.Accounts.list_accounts(claims["sub"]) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
